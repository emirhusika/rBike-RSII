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
    public interface ICategoryService : ICRUDService<Category, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {

    }
}
