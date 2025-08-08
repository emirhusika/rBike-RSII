using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.BikeStateMachine
{
    public class InitialBikeState : BaseBikeState
    {
        public InitialBikeState(Database.RBikeContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<Bike> InsertAsync(BikeInsertRequest request)
        {
            var set = Context.Set<Database.Bike>();
            var entity = Mapper.Map<Database.Bike>(request);
            entity.StateMachine = "draft";
            await set.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Bike>(entity);
        }

        public override Task<List<string>> AllowedActionsAsync(Database.Bike entity)
        {
            var allowedActions = new List<string>() { nameof(InsertAsync) };
            return Task.FromResult(allowedActions);
        }
    }
}
