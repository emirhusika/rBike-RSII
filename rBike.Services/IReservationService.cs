using rBike.Model;
using rBike.Model.Requests;
using rBike.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services
{
    public interface IReservationService : ICRUDService<Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateStatusRequest>
    {
        Task<List<Reservation>> GetReservationsForDateAsync(int bikeId, DateTime date);
        Task<bool> IsTimeSlotAvailableAsync(int bikeId, DateTime start, DateTime end);
        Task UpdateReservationStatusAsync(int id, string status);
        Task AcceptReservationAsync(int id);
        Task RejectReservationAsync(int id);
        Task<PagedResult<Model.Reservation>> GetActiveReservations(ReservationSearchObject? searchObject = null);

        Task<PagedResult<Model.Reservation>> GetCompletedReservations(ReservationSearchObject? searchObject = null);
    }
}
