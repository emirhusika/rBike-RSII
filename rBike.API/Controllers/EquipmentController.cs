using System;
using System.Collections.Generic;
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
    public class EquipmentController : BaseCRUDController<Equipment, EquipmentSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        public EquipmentController(IEquipmentService service) : base(service)
        { }

        [AllowAnonymous]
        [HttpGet("{id}/recommend")]
        public List<Model.Equipment> Recommend(int id)
        {
            return (_service as IEquipmentService).Recommend(id);
        }
    }
} 