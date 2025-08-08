using System;
using System.Collections.Generic;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;

namespace rBike.Services
{
    public interface IEquipmentService : ICRUDService<Equipment, EquipmentSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        List<Equipment> Recommend(int id);
    }
} 