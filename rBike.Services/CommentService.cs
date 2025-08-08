using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;

namespace rBike.Services
{
    public class CommentService : BaseCRUDService<Model.Comment, CommentSearchObject, Database.Comment, CommentInsertRequest, CommentUpdateRequest>, ICommentService
    {
        public CommentService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task BeforeInsertAsync(CommentInsertRequest request, Database.Comment entity)
        {
            entity.DateAdded = DateTime.Now;
            entity.Status = "active";
            await base.BeforeInsertAsync(request, entity);
        }

        public override async Task<IQueryable<Database.Comment>> AddFilterAsync(CommentSearchObject search, IQueryable<Database.Comment> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (search?.BikeId != null)
                filteredQuery = filteredQuery.Where(c => c.BikeId == search.BikeId);

            if (search?.UserId != null)
                filteredQuery = filteredQuery.Where(c => c.UserId == search.UserId);

            if (search?.Status != null)
                filteredQuery = filteredQuery.Where(c => c.Status == search.Status);

            return filteredQuery;
        }

        public override IQueryable<Database.Comment> AddInclude(IQueryable<Database.Comment> query, CommentSearchObject? search = null)
        {
            return query.Include(c => c.User).Include(c => c.Bike);
        }
    }
} 