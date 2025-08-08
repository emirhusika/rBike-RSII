using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services;
using rBike.Services.Constants;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class OrderController : BaseCRUDController<Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly IOrderService _service;

        public OrderController(IOrderService service) : base(service)
        {
            _service = service;
        }

        [HttpPost]
        [Authorize(Roles = "User,Admin")]
        public override async Task<Order> InsertAsync([FromBody] OrderInsertRequest request)
        {
            return await base.InsertAsync(request);
        }

        [HttpPut("{id}/status")]
        [Authorize(Roles = "Admin")]
        public async Task<Order> UpdateStatusAsync(int id, [FromBody] string status)
        {
            return await _service.UpdateOrderStatusAsync(id, status);
        }

        [HttpPut("{id}/process")]
        [Authorize(Roles = "Admin")]
        public async Task<Order> ProcessOrderAsync(int id)
        {
            return await _service.UpdateOrderStatusAsync(id, OrderStatuses.Processed);
        }

        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Admin")]
        public async Task<Order> RejectOrderAsync(int id)
        {
            return await _service.UpdateOrderStatusAsync(id, OrderStatuses.Rejected);
        }

        [HttpGet("user/{userId}")]
        [Authorize(Roles = "User,Admin")]
        public async Task<PagedResult<Order>> GetUserOrders(int userId, [FromQuery] OrderSearchObject search)
        {
            search.UserId = userId;
            return await _service.GetPagedAsync(search);
        }

        [HttpGet("pending")]
        [Authorize(Roles = "Admin")]
        public async Task<PagedResult<Order>> GetPendingOrders([FromQuery] OrderSearchObject search)
        {
            search.Status = OrderStatuses.Pending;
            return await _service.GetPagedAsync(search);
        }

        [HttpGet("processed")]
        [Authorize(Roles = "Admin")]
        public async Task<PagedResult<Order>> GetProcessedOrders([FromQuery] OrderSearchObject search)
        {
            search.Status = OrderStatuses.Processed;
            return await _service.GetPagedAsync(search);
        }

        [HttpGet("rejected")]
        [Authorize(Roles = "Admin")]
        public async Task<PagedResult<Order>> GetRejectedOrders([FromQuery] OrderSearchObject search)
        {
            search.Status = OrderStatuses.Rejected;
            return await _service.GetPagedAsync(search);
        }
    }
} 