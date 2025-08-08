import 'package:rbike_mobile/models/bike.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/bike_provider.dart';

class LoggedBikeProvider extends BikeProvider {
  @override
  Future<SearchResult<Bike>> get({filter}) {
    return super.get(filter: filter);
  }
}
