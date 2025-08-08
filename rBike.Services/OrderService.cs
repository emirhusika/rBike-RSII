using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Constants;
using rBike.Services.Database;

namespace rBike.Services
{
    public class OrderService : BaseCRUDService<Model.Order, OrderSearchObject, Database.Order, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        public OrderService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<Model.Order> InsertAsync(OrderInsertRequest insert)
        {
            var entity = new Database.Order
            {
                UserId = insert.UserId,
                OrderDate = DateTime.Now,
                Status = OrderStatuses.Pending,
                TotalAmount = insert.TotalAmount,
                TransactionNumber = insert.TransactionNumber,
                DeliveryAddress = insert.DeliveryAddress,
                City = insert.City,
                PostalCode = insert.PostalCode,
                OrderCode = await GenerateOrderCodeAsync(),
                ModifiedDate = DateTime.Now
            };

            Context.Orders.Add(entity);
            await Context.SaveChangesAsync();

            foreach (var item in insert.OrderItems)
            {
                var orderItem = new Database.OrderItem
                {
                    OrderId = entity.OrderId,
                    EquipmentId = item.EquipmentId,
                    Quantity = item.Quantity
                };
                Context.OrderItems.Add(orderItem);
            }

            await Context.SaveChangesAsync();

            var completeOrder = await Context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Equipment)
                .ThenInclude(e => e.EquipmentCategory)
                .FirstOrDefaultAsync(o => o.OrderId == entity.OrderId);

            return Mapper.Map<Model.Order>(completeOrder);
        }

        public override async Task<Model.Order> UpdateAsync(int id, OrderUpdateRequest update)
        {
            var entity = await Context.Orders.FindAsync(id);
            if (entity == null)
                throw new Exception("Order not found");


            entity.Status = update.Status;
            if (update.TransactionNumber != null)
                entity.TransactionNumber = update.TransactionNumber;

            entity.ModifiedDate = DateTime.Now;


            await Context.SaveChangesAsync();

            var completeOrder = await Context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Equipment)
                .ThenInclude(e => e.EquipmentCategory)
                .FirstOrDefaultAsync(o => o.OrderId == id);


            return Mapper.Map<Model.Order>(completeOrder);
        }

        public async Task<Model.Order> UpdateOrderStatusAsync(int orderId, string status)
        {
            if (!OrderStatuses.IsValid(status))
                throw new Exception("Invalid order status");

            var entity = await Context.Orders.FindAsync(orderId);
            if (entity == null)
                throw new Exception("Order not found");

            entity.Status = status;
            entity.ModifiedDate = DateTime.Now;

            await Context.SaveChangesAsync();

            var completeOrder = await Context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Equipment)
                .ThenInclude(e => e.EquipmentCategory)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            return Mapper.Map<Model.Order>(completeOrder);
        }

        public async Task<string> GenerateOrderCodeAsync()
        {
            var lastOrder = await Context.Orders
                .OrderByDescending(o => o.OrderId)
                .FirstOrDefaultAsync();

            if (lastOrder == null || string.IsNullOrEmpty(lastOrder.OrderCode))
            {
                return "O-100";
            }

            var lastNumber = int.Parse(lastOrder.OrderCode.Substring(2));
            return $"O-{lastNumber + 1}";
        }

        public override IQueryable<Database.Order> AddInclude(IQueryable<Database.Order> query, OrderSearchObject? search = null)
        {
            return query.Include(o => o.User)
                       .Include(o => o.OrderItems)
                       .ThenInclude(oi => oi.Equipment)
                       .ThenInclude(e => e.EquipmentCategory);
        }

        public override async Task<IQueryable<Database.Order>> AddFilterAsync(OrderSearchObject search, IQueryable<Database.Order> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (search?.OrderCode != null)
                filteredQuery = filteredQuery.Where(o => o.OrderCode!.Contains(search.OrderCode));

            if (search?.Username != null)
                filteredQuery = filteredQuery.Where(o => o.User.Username.Contains(search.Username));

            if (search?.Status != null)
                filteredQuery = filteredQuery.Where(o => o.Status == search.Status);

            if (search?.UserId.HasValue == true)
                filteredQuery = filteredQuery.Where(o => o.UserId == search.UserId);

            if (search?.OrderDateFrom.HasValue == true)
                filteredQuery = filteredQuery.Where(o => o.OrderDate >= search.OrderDateFrom.Value);

            if (search?.OrderDateTo.HasValue == true)
                filteredQuery = filteredQuery.Where(o => o.OrderDate <= search.OrderDateTo.Value);

            return filteredQuery;
        }
    }
}