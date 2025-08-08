using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface IRoleService : ICRUDService<Role, RoleSearchObject, RoleInsertRequest, RoleInsertRequest>
    {
    }
} 