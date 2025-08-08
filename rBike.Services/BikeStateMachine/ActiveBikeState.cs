using MapsterMapper;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.BikeStateMachine
{
    public class ActiveBikeState : BaseBikeState
    {
        public ActiveBikeState(RBikeContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<Model.Bike> HideAsync(int id)
        {
            var set = Context.Set<Database.Bike>();
            var entity = await set.FindAsync(id);

            if (entity == null)
            {
                throw new Exception("Bike not found");
            }

            entity.StateMachine = "hidden";
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.Bike>(entity);
        }

        public override Task<List<string>> AllowedActionsAsync(Database.Bike entity)
        {
            var allowedActions = new List<string>() { nameof(HideAsync) };
            return Task.FromResult(allowedActions);
        }
    }
}
