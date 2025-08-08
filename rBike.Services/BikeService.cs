using MapsterMapper;
using Microsoft.Extensions.Logging;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.BikeStateMachine;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static rBike.Services.BikeStateMachine.BaseBikeState;

namespace rBike.Services
{
    public class BikeService : BaseCRUDService<Model.Bike, BikeSearchObject, Database.Bike, BikeInsertRequest, BikeUpdateRequest>, IBikeService
    {
        ILogger<BikeService> _logger;
        public BaseBikeState BaseBikeState { get; set; }

        public BikeService(RBikeContext context, IMapper mapper, BaseBikeState baseBikeState, ILogger<BikeService> logger)
        : base(context, mapper)
        {
            BaseBikeState = baseBikeState;
            _logger = logger;
        }

        public override async Task<IQueryable<Database.Bike>> AddFilterAsync(BikeSearchObject search, IQueryable<Database.Bike> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));
            }

            if (!string.IsNullOrWhiteSpace(search?.BikeCode))
            {
                filteredQuery = filteredQuery.Where(x => x.BikeCode == search.BikeCode);
            }

            if (!string.IsNullOrWhiteSpace(search?.StateMachine))
            {
                filteredQuery = filteredQuery.Where(x => x.StateMachine == search.StateMachine);
            }

            return filteredQuery;
        }

        public override async Task<Model.Bike> InsertAsync(BikeInsertRequest request)
        {
            var state = await BaseBikeState.CreateStateAsync("initial");
            return await state.InsertAsync(request);
        }

        public override async Task<Model.Bike> UpdateAsync(int id, BikeUpdateRequest request)
        {
            var entity = await GetByIdAsync(id);
            var state = await BaseBikeState.CreateStateAsync(entity.StateMachine);
            return await state.UpdateAsync(id, request);
        }

        public async Task<Model.Bike> ActivateAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            var state = await BaseBikeState.CreateStateAsync(entity.StateMachine);
            return await state.ActivateAsync(id);
        }

        public async Task<Model.Bike> EditAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            var state = await BaseBikeState.CreateStateAsync(entity.StateMachine);
            return await state.EditAsync(id);
        }

        public async Task<Model.Bike> HideAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            var state = await BaseBikeState.CreateStateAsync(entity.StateMachine);
            return await state.HideAsync(id);
        }

        public async Task<List<string>> AllowedActionsAsync(int id)
        {
            _logger.LogInformation($"Allowed actions called for: {id}");

            if (id <= 0)
            {
                var state = await BaseBikeState.CreateStateAsync("initial");
                return await state.AllowedActionsAsync(null);
            }
            else
            {
                var entity = await Context.Bikes.FindAsync(id);
                var state = await BaseBikeState.CreateStateAsync(entity.StateMachine);
                return await state.AllowedActionsAsync(entity);
            }
        }
    }
}
