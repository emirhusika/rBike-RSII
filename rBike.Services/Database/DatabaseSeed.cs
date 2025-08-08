using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.Database
{
    partial class RBikeContext
    {
        partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Role>().HasData 
            (
              new Role() { RoleId = 1, Name = "Admin" },
              new Role() { RoleId = 2, Name = "User" }
            );

            modelBuilder.Entity<User>().HasData 
            (
                   new User()
                   {
                       UserId = 1,
                       FirstName = "Desktop",
                       LastName = "Admin",
                       Email = "desktopadmin@gmail.com",
                       Phone = "+38761123456",
                       Username = "desktop",
                       PasswordHash = "NZtSy9voTSWnx1AW57wE4K6zUcc=", //test123
                       PasswordSalt = "zkxJZZH8jou+KA/COdamcA==",
                       Status = true,
                       DateRegistered = new DateTime(2025, 7, 1)
                   },

                   new User()
                   {
                       UserId = 2,
                       FirstName = "Mobile",
                       LastName = "User",
                       Email = "mobileuser@gmail.com",
                       Phone = "+38762101203",
                       Username = "mobile",
                       PasswordHash = "8VLekE4eL+BYBkEjxgUFRcdNGxU=", //test123
                       PasswordSalt = "IU7jiFjxqwOdAzJe0fM+HA==",
                       Status = true,
                       DateRegistered = new DateTime(2025, 7, 1)
                   }
             );


            modelBuilder.Entity<UserRole>().HasData
            (
              new UserRole() { UserRoleId = 1, UserId = 1, RoleId = 1, ModifiedDate = new DateTime(2025, 7, 1) },
              new UserRole() { UserRoleId = 2, UserId = 2, RoleId = 2, ModifiedDate = new DateTime(2025, 7, 1) }
            );

            modelBuilder.Entity<Category>().HasData
            (
              new Category() { CategoryId = 1, Name = "MTB" },
              new Category() { CategoryId = 2, Name = "Trekking" },
              new Category() { CategoryId = 3, Name = "Triatlon" },
              new Category() { CategoryId = 4, Name = "e-Bikes" }
            );


            modelBuilder.Entity<Bike>().HasData
            (
              new Bike()
              {
                  BikeId = 1,
                  Name = "CORELLI Via Lady 1.1 24 Black/Red/Grey",
                  BikeCode = "VI-111402",
                  Price = (decimal)30.95,
                  CategoryId = 1,
                  Image = System.Convert.FromBase64String(SeedImages.Bike_mt1),
                  StateMachine = "active"
              },

              new Bike()
              {
                  BikeId = 2,
                  Name = "CROSS Areal VBR FRX SL1",
                  BikeCode = "TE-21330560",
                  Price = (decimal)35.95,
                  CategoryId = 2,
                  Image = System.Convert.FromBase64String(SeedImages.Bike_tre2),
                  StateMachine = "active"
              },

              new Bike()
              {
                  BikeId = 3,
                  Name = "Triatlon bicikl SCOTT Plasma 10 CD22",
                  BikeCode = "SC-269837022",
                  Price = (decimal)44.95,
                  CategoryId = 3,
                  Image = System.Convert.FromBase64String(SeedImages.Bike_triat3),
                  StateMachine = "active"
              },

              new Bike()
              {
                  BikeId = 4,
                  Name = "Peaklife OneSport BK5 Folding E-Bike",
                  BikeCode = "BK-5BLACK2425",
                  Price = (decimal)25.45,
                  CategoryId = 4,
                  Image = System.Convert.FromBase64String(SeedImages.Bike_ebike4),
                  StateMachine = "active"
              }

            );

            modelBuilder.Entity<EquipmentCategory>().HasData
            (
              new EquipmentCategory() { CategoryId = 1, EquipmentName = "Zvonce" },
              new EquipmentCategory() { CategoryId = 2, EquipmentName = "Bidon" },
              new EquipmentCategory() { CategoryId = 3, EquipmentName = "Nosac bidona" },
              new EquipmentCategory() { CategoryId = 4, EquipmentName = "Nogara" },
              new EquipmentCategory() { CategoryId = 5, EquipmentName = "Sajla" }
            );

            modelBuilder.Entity<Equipment>().HasData
            (
              new Equipment()
              {
                  EquipmentId = 1,
                  Name = "Zvonce FORCE Mini Steel Green",
                  Description = "Zvonce FORCE Mini Steel",
                  Price = (decimal)4.90,
                  Image = System.Convert.FromBase64String(SeedImages.Equipment_zvo1),
                  Status = "Active",
                  StockQuantity = 50,
                  EquipmentCategoryId = 1
              },

              new Equipment()
              {
                  EquipmentId = 2,
                  Name = "Bidon FORCE Stripe 0,75l Pink/White",
                  Description = "Push-pull top Prečnik boce: 74 mm Materijal: polietilen / polipropilen Težina: 87 g",
                  Price = (decimal)8.00,
                  Image = System.Convert.FromBase64String(SeedImages.Equipment_bid2),
                  Status = "Active",
                  StockQuantity = 20,
                  EquipmentCategoryId = 2
              },

              new Equipment()
              {
                  EquipmentId = 3,
                  Name = "Nosac Bidona M-WAVE C Black",
                  Description = "Nosac bidona",
                  Price = (decimal)7.55,
                  Image = System.Convert.FromBase64String(SeedImages.Equipment_nos3),
                  Status = "Active",
                  StockQuantity = 42,
                  EquipmentCategoryId = 3
              },

              new Equipment()
              {
                  EquipmentId = 4,
                  Name = "Nogara za bicikl HX-Y13-17",
                  Description = "Podesiva aluminijska nogara za bicikl Podesiva po visini Prikladna za točkove velicine 26 - 29",
                  Price = (decimal)15.00,
                  Image = System.Convert.FromBase64String(SeedImages.Equipment_nog4),
                  Status = "Active",
                  StockQuantity = 22,
                  EquipmentCategoryId = 4
              },

              new Equipment()
              {
                  EquipmentId = 5,
                  Name = "Sajla FORCE Eco na kljuc 70cm/8mm Black",
                  Description = "Duzine sajle: 70 cm, promjer: 8 mm Zakljucavanje kljuca, 2 kljuca Tezina: 95 g",
                  Price = (decimal)6.00,
                  Image = System.Convert.FromBase64String(SeedImages.Equipment_saj5),
                  Status = "Active",
                  StockQuantity = 22,
                  EquipmentCategoryId = 5
              }

            );

            modelBuilder.Entity<Order>().HasData
            (
              new Order()
              {
                  OrderId = 1,
                  UserId = 2,
                  OrderDate = new DateTime(2025, 7, 1),
                  Status = "Processed",
                  TotalAmount = (decimal)27.90,
                  OrderCode = "O-100",
                  ModifiedDate = new DateTime(2025, 7, 1)
              },
              new Order()
              {
                  OrderId = 2,
                  UserId = 2,
                  OrderDate = new DateTime(2025, 7, 1),
                  Status = "Processed",
                  TotalAmount = (decimal)30.55,
                  OrderCode = "O-101",
                  ModifiedDate = new DateTime(2025, 7, 1)
              },
              new Order()
              {
                  OrderId = 3,
                  UserId = 1,
                  OrderDate = new DateTime(2025, 7, 1),
                  Status = "Processed",
                  TotalAmount = (decimal)15.55,
                  OrderCode = "O-102",
                  ModifiedDate = new DateTime(2025, 7, 1)
              },
              new Order()
              {
                  OrderId = 4,
                  UserId = 1,
                  OrderDate = new DateTime(2025, 7, 1),
                  Status = "Processed",
                  TotalAmount = (decimal)35.45,
                  OrderCode = "O-103",
                  ModifiedDate = new DateTime(2025, 7, 1)
              }

            );

            modelBuilder.Entity<OrderItem>().HasData
            (
              new OrderItem()
              {
                  OrderItemsId = 1,
                  OrderId = 1,
                  EquipmentId = 1,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 2,
                  OrderId = 1,
                  EquipmentId = 2,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 3,
                  OrderId = 1,
                  EquipmentId = 4,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 4,
                  OrderId = 2,
                  EquipmentId = 2,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 5,
                  OrderId = 2,
                  EquipmentId = 3,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 6,
                  OrderId = 2,
                  EquipmentId = 4,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 7,
                  OrderId = 3,
                  EquipmentId = 2,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 8,
                  OrderId = 3,
                  EquipmentId = 3,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 9,
                  OrderId = 4,
                  EquipmentId = 1,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 10,
                  OrderId = 4,
                  EquipmentId = 2,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 11,
                  OrderId = 4,
                  EquipmentId = 3,
                  Quantity = 1
              },
              new OrderItem()
              {
                  OrderItemsId = 12,
                  OrderId = 4,
                  EquipmentId = 4,
                  Quantity = 1
              }

            );

        }
    }
}
