using MapsterMapper;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity>
        where TModel : class
        where TSearch : BaseSearchObject
        where TDbEntity : class
    {
        public BaseCRUDService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public virtual async Task<TModel> InsertAsync(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            await BeforeInsertAsync(request, entity);

            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);
        }

        public virtual Task BeforeInsertAsync(TInsert request, TDbEntity entity)
        {
            return Task.CompletedTask;
        }

        public virtual async Task<TModel> UpdateAsync(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();

            var entity = await set.FindAsync(id);
            if (entity == null)
            {
                throw new Exception($"Entity with id {id} not found.");
            }

            Mapper.Map(request, entity);

            await BeforeUpdateAsync(request, entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);
        }

        public virtual Task BeforeUpdateAsync(TUpdate request, TDbEntity entity)
        {
            return Task.CompletedTask;
        }

        public virtual async Task<TModel> DeleteAsync(int id)
        {
            var set = Context.Set<TDbEntity>();

            var entity = await set.FindAsync(id);
            if (entity == null)
            {
                throw new Exception($"Entity with id {id} not found.");
            }

            Context.Remove(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);
        }
    }
}
