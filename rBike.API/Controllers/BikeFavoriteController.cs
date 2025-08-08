using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BikeFavoriteController : BaseCRUDController<BikeFavorite, BikeFavoriteSearchObject, BikeFavoriteInsertRequest, object>
    {
        private readonly IBikeFavoriteService _service;

        public BikeFavoriteController(IBikeFavoriteService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("check/{bikeId}")]
        public async Task<IActionResult> IsFavorite(int bikeId, [FromQuery] int userId)
        {
            var isFavorite = await _service.IsFavoriteAsync(userId, bikeId);
            return Ok(new { isFavorite });
        }

        [HttpGet("user")]
        public async Task<IActionResult> GetUserFavorites([FromQuery] int userId)
        {
            var favorites = await _service.GetUserFavoritesAsync(userId);
            return Ok(favorites);
        }

        [HttpDelete("remove/{bikeId}")]
        public async Task<IActionResult> RemoveFavorite(int bikeId, [FromQuery] int userId)
        {
            try
            {
                await _service.RemoveFavoriteAsync(userId, bikeId);
                return Ok(new { message = "Favorite removed successfully." });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Favorite not found." });
            }
        }

        [HttpPost]
        [Authorize(Roles = "User,Admin")]
        public override async Task<BikeFavorite> InsertAsync([FromBody] BikeFavoriteInsertRequest request)
        {
            return await base.InsertAsync(request);
        }
    }
} 