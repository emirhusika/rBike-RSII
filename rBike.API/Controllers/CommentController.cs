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
    public class CommentController : BaseCRUDController<Comment, CommentSearchObject, CommentInsertRequest, CommentUpdateRequest>
    {
        private readonly ICommentService _commentService;

        public CommentController(ICommentService service) : base(service)
        {
            _commentService = service;
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Comment> DeleteAsync(int id)
        {
            try
            {
                
                var updateRequest = new CommentUpdateRequest { Status = "deleted" };
                var result = await _commentService.UpdateAsync(id, updateRequest);
                return result;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }
} 