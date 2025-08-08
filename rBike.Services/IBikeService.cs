using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public interface IBikeService : ICRUDService<Bike, BikeSearchObject, BikeInsertRequest, BikeUpdateRequest>
    {
        Task<Bike> ActivateAsync(int id);
        Task<Bike> EditAsync(int id);
        Task<Bike> HideAsync(int id);
        Task<List<string>> AllowedActionsAsync(int id);
    }
}
