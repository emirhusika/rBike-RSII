using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<TModel, TSearch> : ControllerBase where TSearch : BaseSearchObject
    {
        protected IService<TModel, TSearch> _service;
        public BaseController(IService<TModel, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual async Task<PagedResult<TModel>> GetList([FromQuery] TSearch searchObject)
        {
            return await _service.GetPagedAsync(searchObject); 
        }

        [HttpGet("{id}")]
        public virtual async Task<TModel> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
