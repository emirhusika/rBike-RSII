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
    [Authorize]
    public class RoleController : BaseCRUDController<Role, RoleSearchObject, RoleInsertRequest, RoleInsertRequest>
    {
        public RoleController(IRoleService service) : base(service) { }
    }
} 