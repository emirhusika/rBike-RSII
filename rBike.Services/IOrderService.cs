using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface IOrderService : ICRUDService<Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        Task<Order> UpdateOrderStatusAsync(int orderId, string status);
        Task<string> GenerateOrderCodeAsync();
    }
} 