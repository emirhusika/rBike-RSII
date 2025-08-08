using rBike.Model.SearchObjects;
using rBike.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        Task<PagedResult<TModel>> GetPagedAsync(TSearch search);

        Task<TModel> GetByIdAsync(int id);
    }
}
