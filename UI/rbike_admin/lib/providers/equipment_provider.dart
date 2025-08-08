import 'package:rbike_admin/models/equipment.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class EquipmentProvider extends BaseProvider<Equipment> {
  EquipmentProvider() : super("Equipment");

  @override
  Equipment fromJson(data) {
    return Equipment.fromJson(data);
  }
}
