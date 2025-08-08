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
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService service)
        : base(service) { }

        [HttpPost("login")]
        [AllowAnonymous]
        public Model.User Login(string username, string password)
        {
            return (_service as IUserService).Login(username, password);
        }

        public class UserStatusUpdateRequest
        {
            public bool Status { get; set; }
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UserStatusUpdateRequest request)
        {
            var user = await (_service as IUserService).UpdateStatusAsync(id, request.Status);
            return Ok(user);
        }

        [HttpPost("{id}/change-password")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] rBike.Model.Requests.ChangePasswordRequest request)
        {
            var user = await (_service as IUserService).ChangePasswordAsync(id, request.OldPassword, request.NewPassword, request.ConfirmPassword);
            return Ok(user);
        }

        [HttpPost]
        [Authorize]
        public override async Task<Model.User> InsertAsync([FromBody] UserInsertRequest request)
        {
            
            return await base.InsertAsync(request);
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] UserInsertRequest request)
        {
            try
            {
                request.UserRoles = new List<UserRoleInsertRequest> { new UserRoleInsertRequest { RoleId = 2 } };
                var user = await (_service as IUserService).RegisterAsync(request);
                return Ok(user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
