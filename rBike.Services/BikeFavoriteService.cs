using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public class BikeFavoriteService : BaseCRUDService<Model.BikeFavorite, BikeFavoriteSearchObject, Database.BikeFavorite, BikeFavoriteInsertRequest, object>, IBikeFavoriteService
    {
        public BikeFavoriteService(RBikeContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.BikeFavorite> AddInclude(IQueryable<Database.BikeFavorite> query, BikeFavoriteSearchObject? search = null)
        {
            return query.Include(bf => bf.Bike).Include(bf => bf.User);
        }

        public override async Task<IQueryable<Database.BikeFavorite>> AddFilterAsync(
            BikeFavoriteSearchObject search,
            IQueryable<Database.BikeFavorite> query)
        {

            query = await base.AddFilterAsync(search, query);

            if (search.UserId.HasValue)
            {
                query = query.Where(bf => bf.UserId == search.UserId.Value);
            }

            if (search.BikeId.HasValue)
            {
                query = query.Where(bf => bf.BikeId == search.BikeId.Value);
            }

            return query;
        }

        public override async Task<Model.BikeFavorite> InsertAsync(BikeFavoriteInsertRequest request)
        {
            var existingFavorite = await Context.BikeFavorites
                .FirstOrDefaultAsync(bf => bf.UserId == request.UserId && bf.BikeId == request.BikeId);

            if (existingFavorite != null)
            {
                throw new InvalidOperationException("This bike is already in your favorites.");
            }

            var entity = Mapper.Map<Database.BikeFavorite>(request);
            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.BikeFavorite>(entity);
        }

        public async Task<bool> IsFavoriteAsync(int userId, int bikeId)
        {
            return await Context.BikeFavorites
                .AnyAsync(bf => bf.UserId == userId && bf.BikeId == bikeId);
        }

        public async Task<List<Model.BikeFavorite>> GetUserFavoritesAsync(int userId)
        {
            var entities = await Context.BikeFavorites
                .Where(bf => bf.UserId == userId)
                .Include(bf => bf.Bike)
                .Include(bf => bf.User)
                .ToListAsync();

            return entities.Select(e => Mapper.Map<Model.BikeFavorite>(e)).ToList();
        }

        public async Task RemoveFavoriteAsync(int userId, int bikeId)
        {
            var favorite = await Context.BikeFavorites
                .FirstOrDefaultAsync(bf => bf.UserId == userId && bf.BikeId == bikeId);

            if (favorite == null)
            {
                throw new KeyNotFoundException("Favorite not found.");
            }

            Context.BikeFavorites.Remove(favorite);
            await Context.SaveChangesAsync();
        }
    }
} 