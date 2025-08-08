using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;

namespace rBike.Services
{
    public class ReviewService : BaseCRUDService<Model.Review, ReviewSearchObject, Database.Review, ReviewInsertRequest, ReviewInsertRequest>, IReviewService
    {
        public ReviewService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<Model.Review> InsertAsync(ReviewInsertRequest request)
        {
            var existingReview = await Context.Reviews
                .FirstOrDefaultAsync(r => r.BikeId == request.BikeId && r.UserId == request.UserId);

            if (existingReview != null)
            {
                
                existingReview.Rating = request.Rating;
                existingReview.Date = DateTime.Now;
                await Context.SaveChangesAsync();
                return Mapper.Map<Model.Review>(existingReview);
            }

            return await base.InsertAsync(request);
        }

        public override async Task BeforeInsertAsync(ReviewInsertRequest request, Database.Review entity)
        {
            entity.Date = DateTime.Now;
            await base.BeforeInsertAsync(request, entity);
        }

        public override async Task<IQueryable<Database.Review>> AddFilterAsync(ReviewSearchObject search, IQueryable<Database.Review> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (search?.BikeId != null)
                filteredQuery = filteredQuery.Where(r => r.BikeId == search.BikeId);

            if (search?.UserId != null)
                filteredQuery = filteredQuery.Where(r => r.UserId == search.UserId);

            return filteredQuery;
        }

        public override IQueryable<Database.Review> AddInclude(IQueryable<Database.Review> query, ReviewSearchObject? search = null)
        {
            return query.Include(r => r.User).Include(r => r.Bike);
        }

        public async Task<double> GetAverageRatingForBike(int bikeId)
        {
            var reviews = await Context.Reviews
                .Where(r => r.BikeId == bikeId)
                .ToListAsync();

            if (!reviews.Any())
                return 0;

            return reviews.Average(r => r.Rating);
        }

        public async Task<Model.Review?> GetUserReviewForBike(int bikeId, int userId)
        {
            var review = await Context.Reviews
                .Include(r => r.User)
                .Include(r => r.Bike)
                .FirstOrDefaultAsync(r => r.BikeId == bikeId && r.UserId == userId);

            if (review == null) return null;

            return Mapper.Map<Model.Review>(review);
        }
    }
} 