import 'package:rbike_mobile/models/bike.dart';
import 'package:rbike_mobile/providers/base_provider.dart';

class BikeProvider extends BaseProvider<Bike> {
  BikeProvider() : super("Bike");

  @override
  Bike fromJson(data) {
    // TODO: implement fromJson
    return Bike.fromJson(data);
  }
}
