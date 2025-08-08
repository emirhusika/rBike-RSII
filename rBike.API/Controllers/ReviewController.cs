using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseCRUDController<Review, ReviewSearchObject, ReviewInsertRequest, ReviewInsertRequest>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService service) : base(service)
        {
            _reviewService = service;
        }

        [HttpGet("average/{bikeId}")]
        public async Task<ActionResult<double>> GetAverageRating(int bikeId)
        {
            try
            {
                var average = await _reviewService.GetAverageRatingForBike(bikeId);
                return Ok(average);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("user/{bikeId}/{userId}")]
        public async Task<ActionResult<Review?>> GetUserReview(int bikeId, int userId)
        {
            try
            {
                var review = await _reviewService.GetUserReviewForBike(bikeId, userId);
                return Ok(review);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
} 