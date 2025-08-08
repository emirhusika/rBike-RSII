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
    public class BikeController : BaseCRUDController<Bike, BikeSearchObject, BikeInsertRequest, BikeUpdateRequest>
    {

        public BikeController(IBikeService service)
        : base(service)
        {
        }

        [HttpPut("{id}/activate")]
        public async Task<Bike> ActivateAsync(int id)
        {
            return await (_service as IBikeService).ActivateAsync(id);
        }

        [HttpPut("{id}/edit")]
        public async Task<Bike> EditAsync(int id)
        {
            return await (_service as IBikeService).EditAsync(id);
        }

        [HttpPut("{id}/hide")]
        public async Task<Bike> HideAsync(int id)
        {
            return await (_service as IBikeService).HideAsync(id);
        }

        [HttpGet("{id}/allowedActions")]
        public async Task<List<string>> AllowedActionsAsync(int id)
        {
            return await (_service as IBikeService).AllowedActionsAsync(id);
        }


    }
}
