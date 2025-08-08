using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {
        protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;

        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
        }

        [HttpPost]
        public virtual async Task<TModel> InsertAsync(TInsert request)
        {
            return await _service.InsertAsync(request);
        }

        [HttpPut("{id}")]
        public virtual async Task<TModel> UpdateAsync(int id, TUpdate request)
        {         
            return await _service.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        public virtual async Task<TModel> DeleteAsync(int id)
        {
            return await _service.DeleteAsync(id);
        }


    }
}
