using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Database;
using MapsterMapper;

namespace rBike.Services
{
    public class EquipmentCategoryService : BaseCRUDService<Model.EquipmentCategory, EquipmentCategorySearchObject, Database.EquipmentCategory, EquipmentCategoryUpsertRequest, EquipmentCategoryUpsertRequest>, IEquipmentCategoryService
    {
        public EquipmentCategoryService(RBikeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<IQueryable<Database.EquipmentCategory>> AddFilterAsync(EquipmentCategorySearchObject search, IQueryable<Database.EquipmentCategory> query)
        {
            var filteredQuery = await base.AddFilterAsync(search, query);

            if (!string.IsNullOrWhiteSpace(search?.EquipmentName))
            {
                filteredQuery = filteredQuery.Where(x => x.EquipmentName.Contains(search.EquipmentName));
            }

            return filteredQuery;
        }

        public override IQueryable<Database.EquipmentCategory> AddInclude(IQueryable<Database.EquipmentCategory> query, EquipmentCategorySearchObject? search = null)
        {
            query = query.Include(x => x.Equipment);
            return base.AddInclude(query, search);
        }
    }
} 