using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        ILogger<UserService> _logger;
        public UserService(RBikeContext context, IMapper mapper, ILogger<UserService> logger) : base(context, mapper)
        {
            _logger = logger;
        }

        public override async Task<IQueryable<Database.User>> AddFilterAsync(UserSearchObject searchObject, IQueryable<Database.User> query)
        {
            query = await base.AddFilterAsync(searchObject, query);

            if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
            {
                query = query.Where(x => x.FirstName.StartsWith(searchObject.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
            {
                query = query.Where(x => x.LastName.StartsWith(searchObject.LastNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.Email))
            {
                query = query.Where(x => x.Email == searchObject.Email);
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
            {
                query = query.Where(x => x.Username == searchObject.Username);
            }

            if (searchObject.IsUserRoleIncluded == true)
            {
                query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);
            }

            query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role).AsQueryable();


            return query;
        }

        public override async Task BeforeInsertAsync(UserInsertRequest request, Database.User entity)
        {
            _logger.LogInformation($"Adding user: {entity.Username}");

            if (request.Password != request.ConfirmPassword)
            {
                throw new Exception("Password and ConfirmPassword must match");
            }

            
            if (Context.Users.Any(u => u.Username == request.Username))
                throw new Exception("Username is already taken.");

            
            if (!string.IsNullOrWhiteSpace(request.Email) && Context.Users.Any(u => u.Email == request.Email))
                throw new Exception("Email is already taken.");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);

            
            if (request.Status == null)
                entity.Status = true;
            else
                entity.Status = request.Status;

            
            if (request.DateRegistered == null)
                entity.DateRegistered = DateTime.Now;
            else
                entity.DateRegistered = request.DateRegistered;

            
            if (request.UserRoles != null && request.UserRoles.Count > 0)
            {
                foreach (var userRoleReq in request.UserRoles)
                {
                    var userRole = new UserRole
                    {
                        User = entity,
                        RoleId = userRoleReq.RoleId,
                        ModifiedDate = DateTime.Now
                    };
                    entity.UserRoles.Add(userRole);
                }
            }

            await base.BeforeInsertAsync(request, entity);
        }

        public override async Task<Model.User> InsertAsync(UserInsertRequest request)
        {
            var entity = Mapper.Map<Database.User>(request);

            await BeforeInsertAsync(request, entity);
            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.User>(entity);
        }

        public async Task<Model.User> RegisterAsync(UserInsertRequest request)
        {
            var entity = Mapper.Map<Database.User>(request);
            await BeforeInsertAsync(request, entity);
            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();
            return Mapper.Map<Model.User>(entity);
        }

        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);

            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public override async Task BeforeUpdateAsync(UserUpdateRequest request, Database.User entity)
        {
            await base.BeforeUpdateAsync(request, entity);

            if (request.Status == null)
            {
                var currentEntity = await Context.Users.FindAsync(entity.UserId);
                if (currentEntity != null)
                {
                    entity.Status = currentEntity.Status;
                }
            }

            if (request.Password != null)
            {
                if (request.Password != request.ConfirmPassword)
                {
                    throw new Exception("Password and ConfirmPassword must match");
                }

                entity.PasswordSalt =  GenerateSalt();
                entity.PasswordHash =  GenerateHash(entity.PasswordSalt, request.Password);
            }
        }

        public Model.User Login(string username, string password)
        {
            var entity = Context.Users.Include(x => x.UserRoles).ThenInclude(y => y.Role).FirstOrDefault(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
            {
                return null;
            }

            return this.Mapper.Map<Model.User>(entity);
        }

        public async Task<Model.User> UpdateStatusAsync(int userId, bool status)
        {
            var entity = await Context.Users.FindAsync(userId);
            if (entity == null)
                throw new Exception("User not found");
            entity.Status = status;
            await Context.SaveChangesAsync();
            return Mapper.Map<Model.User>(entity);
        }

        public override async Task<Model.User> UpdateAsync(int id, UserUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.FirstName))
                throw new Exception("First name cannot be empty");
            if (string.IsNullOrWhiteSpace(request.LastName))
                throw new Exception("Last name cannot be empty");

            if (!string.IsNullOrWhiteSpace(request.Email))
            {
                try
                {
                    var addr = new System.Net.Mail.MailAddress(request.Email);
                    if (addr.Address != request.Email)
                        throw new Exception();
                }
                catch
                {
                    throw new Exception("Email is not valid.");
                }
            }

            return await base.UpdateAsync(id, request);
        }

        public async Task<Model.User> ChangePasswordAsync(int userId, string oldPassword, string newPassword, string confirmPassword)
        {
            var entity = await Context.Users.FindAsync(userId);
            if (entity == null)
                throw new Exception("User not found.");

            var oldHash = GenerateHash(entity.PasswordSalt, oldPassword);
            if (oldHash != entity.PasswordHash)
                throw new Exception("Old password is incorrect.");

            if (string.IsNullOrWhiteSpace(newPassword) || newPassword.Length < 6)
                throw new Exception("New password must be at least 6 characters long.");

            if (newPassword != confirmPassword)
                throw new Exception("New password and confirmation do not match.");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, newPassword);
            await Context.SaveChangesAsync();
            return Mapper.Map<Model.User>(entity);
        }

    }
}
