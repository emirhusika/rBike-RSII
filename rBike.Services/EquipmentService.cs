using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Constants;
using rBike.Services.Database;
using MapsterMapper;

namespace rBike.Services
{
    public class EquipmentService : BaseCRUDService<Model.Equipment, EquipmentSearchObject, Database.Equipment, EquipmentUpsertRequest, EquipmentUpsertRequest>, IEquipmentService
    {
        private static readonly string ModelPath = Path.Combine(Directory.GetCurrentDirectory(), "MLModels", "equipment_model.zip");
        private static readonly MLContext mlContext = new MLContext();
        private static ITransformer model = null;
        private static readonly object isLocked = new();

        public EquipmentService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<IQueryable<Database.Equipment>> AddFilterAsync(EquipmentSearchObject search, IQueryable<Database.Equipment> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.Name));
            }

            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                filteredQuery = filteredQuery.Where(x => x.Status == search.Status);
            }

            if (search?.EquipmentCategoryId != null)
            {
                filteredQuery = filteredQuery.Where(x => x.EquipmentCategoryId == search.EquipmentCategoryId);
            }

            return filteredQuery;
        }

        public override IQueryable<Database.Equipment> AddInclude(IQueryable<Database.Equipment> query, EquipmentSearchObject? search = null)
        {
            query = query.Include(x => x.EquipmentCategory);
            return base.AddInclude(query, search);
        }

        public override async Task<Model.Equipment> InsertAsync(EquipmentUpsertRequest request)
        {
            var entity = Mapper.Map<Database.Equipment>(request);
            entity.Status = EquipmentStatuses.Active;

            await BeforeInsertAsync(request, entity);

            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.Equipment>(entity);
        }

        public override async Task<Model.Equipment> UpdateAsync(int id, EquipmentUpsertRequest request)
        {
            var set = Context.Set<Database.Equipment>();

            var entity = await set.FindAsync(id);
            if (entity == null)
                throw new Exception($"Equipment with id {id} not found.");

            var currentStatus = entity.Status;
            Mapper.Map(request, entity);

            if (string.IsNullOrWhiteSpace(request.Status))
                entity.Status = currentStatus;
            else if (!EquipmentStatuses.IsValid(request.Status))
                throw new Exception($"Invalid status: {request.Status}. Valid statuses are: {string.Join(", ", EquipmentStatuses.All)}");

            await BeforeUpdateAsync(request, entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.Equipment>(entity);
        }

        //Recommender
        public List<Model.Equipment> Recommend(int equipmentId)
        {
            lock (isLocked)
            {
                if (model == null)
                {
                    if (File.Exists(ModelPath))
                    {
                        using var stream = File.OpenRead(ModelPath);
                        model = mlContext.Model.Load(stream, out _);
                    }
                    else
                    {
                        TrainAndSaveModel();
                    }
                }
            }

            var allEquipment = Context.Equipment
                .Where(e => e.EquipmentId != equipmentId)
                .Include(e => e.EquipmentCategory)
                .ToList();

            if (allEquipment == null || allEquipment.Count == 0)
            {
                return new List<Model.Equipment>();
            }

            var predictionEngine = mlContext.Model.CreatePredictionEngine<EquipmentEntry, EquipmentPrediction>(model);

            var scored = allEquipment
                .Select(e => new
                {
                    Equipment = e,
                    Score = predictionEngine.Predict(new EquipmentEntry
                    {
                        EquipmentID = (uint)equipmentId,
                        CoPurchasedEquipmentID = (uint)e.EquipmentId
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Take(3)
                .Select(x => x.Equipment)
                .ToList();

            if (scored == null || scored.Count == 0)
            {
                return new List<Model.Equipment>();
            }

            return Mapper.Map<List<Model.Equipment>>(scored);
        }


        private void TrainAndSaveModel()
        {
            var orders = Context.Orders
                .Where(o => o.Status == "Processed")
                .Include(o => o.OrderItems)
                .ToList();

            var data = new List<EquipmentEntry>();

            foreach (var order in orders)
            {
                var items = order.OrderItems.Select(oi => oi.EquipmentId).Distinct().ToList();
                foreach (var itemId in items)
                {
                    foreach (var coItemId in items.Where(x => x != itemId))
                    {
                        data.Add(new EquipmentEntry
                        {
                            EquipmentID = (uint)itemId,
                            CoPurchasedEquipmentID = (uint)coItemId,
                            Label = 1f
                        });
                    }
                }
            }

            var trainData = mlContext.Data.LoadFromEnumerable(data);

            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(EquipmentEntry.EquipmentID),
                MatrixRowIndexColumnName = nameof(EquipmentEntry.CoPurchasedEquipmentID),
                LabelColumnName = nameof(EquipmentEntry.Label),
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.025,
                NumberOfIterations = 100,
                C = 0.00001
            };

            var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);

            model = estimator.Fit(trainData);

            var modelDir = Path.GetDirectoryName(ModelPath);
            if (!Directory.Exists(modelDir))
                Directory.CreateDirectory(modelDir);

            mlContext.Model.Save(model, trainData.Schema, ModelPath);
        }


        private class EquipmentEntry
        {
            [KeyType(count: 100000)]
            public uint EquipmentID { get; set; }

            [KeyType(count: 100000)]
            public uint CoPurchasedEquipmentID { get; set; }

            public float Label { get; set; } = 1f;
        }

        private class EquipmentPrediction
        {
            public float Score { get; set; }
        }
    }
}