using MapsterMapper;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public class CategoryService : BaseCRUDService<Model.Category, CategorySearchObject, Database.Category, CategoryUpsertRequest, CategoryUpsertRequest>, ICategoryService
    {
        public CategoryService(RBikeContext context, IMapper mapper)
        : base(context, mapper)
        { }

    }
}
