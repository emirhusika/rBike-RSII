import 'package:rbike_admin/models/bike.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/bike_provider.dart';

class LoggedBikeProvider extends BikeProvider {
  @override
  Future<SearchResult<Bike>> get({filter}) {
    return super.get(filter: filter);
  }
}
