using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    //[AllowAnonymous]
    public class CategoryController : BaseCRUDController<Category, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        public CategoryController(ICategoryService service)
        : base(service)
        {
        }

        [Authorize(Roles = "Admin")]
        public override async Task<Category> InsertAsync(CategoryUpsertRequest request)
        {
            return await base.InsertAsync(request);
        }

        [AllowAnonymous]
        public override async Task<PagedResult<Category>> GetList([FromQuery] CategorySearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

    }
}