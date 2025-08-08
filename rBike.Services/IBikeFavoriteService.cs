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
    public interface IBikeFavoriteService : ICRUDService<BikeFavorite, BikeFavoriteSearchObject, BikeFavoriteInsertRequest, object>
    {
        Task<bool> IsFavoriteAsync(int userId, int bikeId);
        Task<List<BikeFavorite>> GetUserFavoritesAsync(int userId);
        Task RemoveFavoriteAsync(int userId, int bikeId);
    }
} 