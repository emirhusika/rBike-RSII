using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface ICommentService : ICRUDService<Comment, CommentSearchObject, CommentInsertRequest, CommentUpdateRequest>
    {
    }
} 