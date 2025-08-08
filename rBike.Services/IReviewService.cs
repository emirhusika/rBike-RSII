using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface IReviewService : ICRUDService<Review, ReviewSearchObject, ReviewInsertRequest, ReviewInsertRequest>
    {
        Task<double> GetAverageRatingForBike(int bikeId);
        Task<Review?> GetUserReviewForBike(int bikeId, int userId);
    }
} 