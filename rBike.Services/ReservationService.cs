using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using rBike.Services.Constants;
using rBike.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateStatusRequest>, IReservationService
    {
        public ReservationService(RBikeContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Reservation> AddInclude(IQueryable<Database.Reservation> query, ReservationSearchObject? search = null)
        {
            return query.Include(r => r.Bike).Include(r => r.User);
        }

        public override async Task<IQueryable<Database.Reservation>> AddFilterAsync(
        ReservationSearchObject search,
        IQueryable<Database.Reservation> query)
        {

            query = await base.AddFilterAsync(search, query);

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.Date.HasValue)
            {
                var date = search.Date.Value.Date;
                query = query.Where(r =>
                    r.StartDateTime.Date <= date &&
                    r.EndDateTime.Date >= date);
            }

            return query; 
        }

        public override async Task<Model.Reservation> InsertAsync(ReservationInsertRequest request)
        {
            var entity = Mapper.Map<Database.Reservation>(request);

            entity.CreatedAt = DateTime.UtcNow;

            bool available = await IsTimeSlotAvailableAsync(request.BikeId, request.StartDateTime, request.EndDateTime);
            if (!available)
                throw new InvalidOperationException("The selected time slot is already reserved.");

            entity.Status = ReservationStatuses.Active;

            await Context.AddAsync(entity);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.Reservation>(entity);
        }

       
        public async Task<List<Model.Reservation>> GetReservationsForDateAsync(int bikeId, DateTime date)
        {
            var intervalStart = date.Date;
            var intervalEnd = intervalStart.AddDays(7); 

            var entities = await Context.Reservations
                .Where(r => r.BikeId == bikeId &&
                            r.StartDateTime < intervalEnd &&
                            r.EndDateTime > intervalStart &&
                            (r.Status == ReservationStatuses.Active || r.Status == ReservationStatuses.Processed))
                .ToListAsync();

            return entities.Select(e => Mapper.Map<Model.Reservation>(e)).ToList(); ;
        }

        public async Task<bool> IsTimeSlotAvailableAsync(int bikeId, DateTime start, DateTime end)
        {
            return !await Context.Reservations.AnyAsync(r =>
                r.BikeId == bikeId &&
                r.StartDateTime < end &&
                r.EndDateTime > start &&
                (r.Status == ReservationStatuses.Active || r.Status == ReservationStatuses.Processed));
        }

        public async Task UpdateReservationStatusAsync(int id, string status)
        {
            if (!ReservationStatuses.IsValid(status))
                throw new ArgumentException("Invalid reservation status.");

            var entity = await Context.Reservations.FindAsync(id)
                         ?? throw new KeyNotFoundException("Reservation not found.");

            entity.Status = status;
            await Context.SaveChangesAsync();
        }

        public async Task AcceptReservationAsync(int id)
        {
            await UpdateReservationStatusAsync(id, ReservationStatuses.Processed);
        }

        public async Task RejectReservationAsync(int id)
        {
            await UpdateReservationStatusAsync(id, ReservationStatuses.Rejected);
        }

        public async Task<PagedResult<Model.Reservation>> GetActiveReservations(ReservationSearchObject? searchObject = null)
        {
            IQueryable<Database.Reservation> query = Context.Reservations
                .Where(r => r.Status == ReservationStatuses.Active);

            if (searchObject?.Date.HasValue == true)
            {
                query = query.Where(r => r.StartDateTime.Date == searchObject.Date.Value.Date);
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
            {
                query = query.Where(r => r.User.Username.Contains(searchObject.Username));
            }

            query = query.Include(r => r.Bike).Include(r => r.User)
                         .OrderByDescending(r => r.ReservationId);

            int count = await query.CountAsync();

            if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true)
            {
                query = query.Skip((searchObject.Page.Value - 1) * searchObject.PageSize.Value)
                             .Take(searchObject.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<Model.Reservation>>(list);

            return new PagedResult<Model.Reservation>
            {
                ResultList = result,
                Count = count
            };
        }

        public async Task<PagedResult<Model.Reservation>> GetCompletedReservations(ReservationSearchObject? searchObject = null)
        {
            IQueryable<Database.Reservation> query = Context.Reservations
                .Where(r => r.Status == ReservationStatuses.Processed || r.Status == ReservationStatuses.Rejected)
                .Include(r => r.Bike)
                .Include(r => r.User)
                .OrderByDescending(r => r.ReservationId);

            if (searchObject?.Date.HasValue == true)
            {
                query = query.Where(r => r.StartDateTime.Date == searchObject.Date.Value.Date);
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
            {
                query = query.Where(r => r.User.Username.Contains(searchObject.Username));
            }

            int count = await query.CountAsync();

            if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true)
            {
                query = query.Skip((searchObject.Page.Value - 1) * searchObject.PageSize.Value)
                             .Take(searchObject.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<Model.Reservation>>(list);

            return new PagedResult<Model.Reservation>
            {
                ResultList = result,
                Count = count
            };
        }
    }
}
