using Mapster;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.Mappings
{
    public static class MapsterConfig
    {
        public static void RegisterMappings()
        {
            TypeAdapterConfig<Database.Reservation, Model.Reservation>
                .NewConfig()
                .Map(dest => dest.BikeName, src => src.Bike.Name)
                .Map(dest => dest.Username, src => src.User.Username);

            TypeAdapterConfig<Database.BikeFavorite, Model.BikeFavorite>
                .NewConfig()
                .Map(dest => dest.BikeName, src => src.Bike.Name)
                .Map(dest => dest.Username, src => src.User.Username);

            TypeAdapterConfig<Database.Review, Model.Review>
                .NewConfig()
                .Map(dest => dest.Username, src => src.User.Username)
                .Map(dest => dest.BikeName, src => src.Bike.Name)
                .Map(dest => dest.Date, src => src.Date);

            TypeAdapterConfig<Database.Comment, Model.Comment>
                .NewConfig()
                .Map(dest => dest.BikeName, src => src.Bike.Name)
                .Map(dest => dest.Username, src => src.User.Username)
                .Map(dest => dest.DateAdded, src => src.DateAdded);

            TypeAdapterConfig<Database.Equipment, Model.Equipment>
                .NewConfig()
                .Map(dest => dest.EquipmentId, src => src.EquipmentId)
                .Map(dest => dest.Name, src => src.Name)
                .Map(dest => dest.Description, src => src.Description)
                .Map(dest => dest.Price, src => src.Price)
                .Map(dest => dest.Image, src => src.Image)
                .Map(dest => dest.Status, src => src.Status)
                .Map(dest => dest.StockQuantity, src => src.StockQuantity)
                .Map(dest => dest.EquipmentCategoryId, src => src.EquipmentCategoryId)
                .Map(dest => dest.EquipmentCategoryName, src => src.EquipmentCategory != null ? src.EquipmentCategory.EquipmentName : null);

            TypeAdapterConfig<Database.EquipmentCategory, Model.EquipmentCategory>
                .NewConfig()
                .Map(dest => dest.CategoryId, src => src.CategoryId)
                .Map(dest => dest.EquipmentName, src => src.EquipmentName);

            // Order mappings to break circular reference
            TypeAdapterConfig<Database.Order, Model.Order>
                .NewConfig()
                .Map(dest => dest.OrderItems, src => src.OrderItems)
                .Map(dest => dest.UserId, src => src.UserId)
                .Map(dest => dest.Username, src => src.User != null ? src.User.Username : null)
                .Map(dest => dest.User, src => src.User != null ? new Model.User
                {
                    UserId = src.User.UserId,
                    Username = src.User.Username,
                    FirstName = src.User.FirstName,
                    LastName = src.User.LastName,
                    Email = src.User.Email,
                    Phone = src.User.Phone,
                    Status = src.User.Status,
                    DateRegistered = src.User.DateRegistered
                } : null);

            TypeAdapterConfig<Database.OrderItem, Model.OrderItem>
                .NewConfig()
                .Map(dest => dest.OrderItemsId, src => src.OrderItemsId)
                .Map(dest => dest.OrderId, src => src.OrderId)
                .Map(dest => dest.EquipmentId, src => src.EquipmentId)
                .Map(dest => dest.Quantity, src => src.Quantity)
                .Map(dest => dest.Equipment, src => new Model.Equipment
                {
                    EquipmentId = src.Equipment.EquipmentId,
                    Name = src.Equipment.Name,
                    Description = src.Equipment.Description,
                    Price = src.Equipment.Price,
                    Image = src.Equipment.Image,
                    Status = src.Equipment.Status,
                    StockQuantity = src.Equipment.StockQuantity,
                    EquipmentCategoryId = src.Equipment.EquipmentCategoryId,
                    EquipmentCategoryName = src.Equipment.EquipmentCategory.EquipmentName,
                    OrderItems = new List<Model.OrderItem>() // Empty list to prevent circular reference
                })
                .Ignore(dest => dest.Order); // Ignore Order navigation property to prevent circular reference

            TypeAdapterConfig<UserInsertRequest, Database.User>
                .NewConfig()
                .Ignore(dest => dest.UserRoles);
        }
    }
}
