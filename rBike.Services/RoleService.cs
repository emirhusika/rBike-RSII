using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using MapsterMapper;

namespace rBike.Services
{
    public class RoleService : BaseCRUDService<Model.Role, RoleSearchObject, Database.Role, RoleInsertRequest, RoleInsertRequest>, IRoleService
    {
        public RoleService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
} 