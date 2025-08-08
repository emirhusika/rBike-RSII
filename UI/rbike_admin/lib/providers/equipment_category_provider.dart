import 'package:rbike_admin/models/equipment_category.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class EquipmentCategoryProvider extends BaseProvider<EquipmentCategory> {
  EquipmentCategoryProvider() : super("EquipmentCategory");

  @override
  EquipmentCategory fromJson(data) {
    return EquipmentCategory.fromJson(data);
  }
}
