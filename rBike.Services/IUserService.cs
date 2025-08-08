using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Model.User Login(string username, string password);
        Task<Model.User> UpdateStatusAsync(int userId, bool status);
        Task<Model.User> ChangePasswordAsync(int userId, string oldPassword, string newPassword, string confirmPassword);
        Task<Model.User> RegisterAsync(UserInsertRequest request);
    }
}
