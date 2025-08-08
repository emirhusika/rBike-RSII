using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.BikeStateMachine
{
    public class BaseBikeState
    {
        public RBikeContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseBikeState(RBikeContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Task<Model.Bike> InsertAsync(BikeInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<Model.Bike> UpdateAsync(int id, BikeUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<Model.Bike> ActivateAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<Model.Bike> HideAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<Model.Bike> EditAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

     
        public virtual Task<List<string>> AllowedActionsAsync(Database.Bike entity)
        {
            throw new UserException("Method not allowed");
        }

        public async Task<BaseBikeState> CreateStateAsync(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return await Task.FromResult(ServiceProvider.GetService<InitialBikeState>());
                case "draft":
                    return await Task.FromResult(ServiceProvider.GetService<DraftBikeState>());
                case "active":
                    return await Task.FromResult(ServiceProvider.GetService<ActiveBikeState>());
                case "hidden":
                    return await Task.FromResult(ServiceProvider.GetService<HiddenBikeState>());
                default:
                    throw new Exception("State not recognized");
            }
        }
    }
}

//initial, draft, active, hidden