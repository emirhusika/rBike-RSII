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
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("[controller]")]
    public class EquipmentCategoryController : BaseCRUDController<EquipmentCategory, EquipmentCategorySearchObject, EquipmentCategoryUpsertRequest, EquipmentCategoryUpsertRequest>
    {
        public EquipmentCategoryController(IEquipmentCategoryService service) : base(service)
        {
        }
    }
} 