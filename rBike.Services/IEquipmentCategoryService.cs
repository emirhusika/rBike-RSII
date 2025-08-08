using System;
using System.Collections.Generic;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface IEquipmentCategoryService : ICRUDService<EquipmentCategory, EquipmentCategorySearchObject, EquipmentCategoryUpsertRequest, EquipmentCategoryUpsertRequest>
    {
    }
} 