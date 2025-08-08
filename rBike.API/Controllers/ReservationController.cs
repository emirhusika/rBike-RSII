using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ReservationController : BaseCRUDController<Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateStatusRequest>
    {
        private readonly IReservationService _service;

        public ReservationController(IReservationService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("calendar")]
        public async Task<IActionResult> GetReservationsForDate([FromQuery][BindRequired] int bikeId, [FromQuery][BindRequired] DateTime date)
        {
            var reservations = await _service.GetReservationsForDateAsync(bikeId, date);
            return Ok(reservations);
        }

        [HttpGet("active")]
        public async Task<IActionResult> GetActiveReservations([FromQuery] ReservationSearchObject search)
        {
            var result = await _service.GetActiveReservations(search);
            return Ok(result);
        }

        [HttpGet("completed")]
        public async Task<IActionResult> GetCompletedReservations([FromQuery] ReservationSearchObject search)
        {
            var result = await _service.GetCompletedReservations(search);
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = "User,Admin")]
        public override async Task<Reservation> InsertAsync([FromBody] ReservationInsertRequest request)
        {
            return await base.InsertAsync(request);
        }

        [HttpPut("{id}/accept")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Accept(int id)
        {
            try
            {
                await _service.AcceptReservationAsync(id);
                return Ok(new { message = "Reservation accepted." });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Reservation not found." });
            }
        }

        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Reject(int id)
        {
            try
            {
                await _service.RejectReservationAsync(id);
                return Ok(new { message = "Reservation rejected." });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Reservation not found." });
            }
        }
    }
}
