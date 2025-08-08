using MapsterMapper;
using rBike.Model.SearchObjects;
using rBike.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using rBike.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace rBike.Services
{
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
    {
        public RBikeContext Context { get; set; }

        public IMapper Mapper { get; set; }

        public BaseService(RBikeContext context, IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public async Task<PagedResult<TModel>> GetPagedAsync(TSearch search)
        {
            var query = Context.Set<TDbEntity>().AsQueryable();

            query = await AddFilterAsync(search, query);

            query = AddInclude(query, search);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<TModel>>(list);

            return new PagedResult<TModel>
            {
                ResultList = result,
                Count = count
            };
        }

        public virtual async Task<IQueryable<TDbEntity>> AddFilterAsync(TSearch search, IQueryable<TDbEntity> query)
        {
            return await Task.FromResult(query);
        }

        public virtual IQueryable<TDbEntity> AddInclude(IQueryable<TDbEntity> query, TSearch? search = null)
        {
            return query;
        }


        public async Task<TModel> GetByIdAsync(int id)
        {
            var entity = await Context.Set<TDbEntity>().FindAsync(id);

            if (entity != null)
            {
                return Mapper.Map<TModel>(entity);
            }
            else
            {
                throw new Exception("Entity not found.");
            }
        }


    }
}
