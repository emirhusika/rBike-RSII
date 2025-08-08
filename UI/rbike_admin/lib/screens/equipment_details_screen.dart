import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/equipment.dart';
import 'package:rbike_admin/models/equipment_category.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/equipment_provider.dart';
import 'package:rbike_admin/providers/equipment_category_provider.dart';
import 'package:rbike_admin/providers/utils.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/screens/equipment_list_screen.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  Equipment? equipment;
  EquipmentDetailsScreen({super.key, this.equipment});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late EquipmentProvider equipmentProvider;
  late EquipmentCategoryProvider equipmentCategoryProvider;
  SearchResult<EquipmentCategory>? categoryResult;
  bool isLoading = true;
  String? _base64Image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    equipmentProvider = context.read<EquipmentProvider>();
    equipmentCategoryProvider = context.read<EquipmentCategoryProvider>();

    super.initState();

    _initialValue = {
      'name': widget.equipment?.name ?? '',
      'description': widget.equipment?.description ?? '',
      'price': widget.equipment?.price?.toString() ?? '',
      'stockQuantity': widget.equipment?.stockQuantity?.toString() ?? '',
      'equipmentCategoryId':
          widget.equipment?.equipmentCategoryId?.toString() ?? '',
    };

    if (widget.equipment?.image != null) {
      _base64Image = widget.equipment!.image;
    }

    initForm();
  }

  Future initForm() async {
    categoryResult = await equipmentCategoryProvider.get();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Detalji opreme",
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 248, 248),
              const Color.fromARGB(255, 73, 70, 70),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [isLoading ? Container() : _buildForm(), _saveRow()],
          ),
        ),
      ),
      actionButton: ElevatedButton(
        onPressed: _showAddCategoryDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16),
            SizedBox(width: 4),
            Text("Dodaj kategoriju"),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Naziv *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    name: "name",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Naziv je obavezan';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FormBuilderDropdown(
                    name: "equipmentCategoryId",
                    decoration: InputDecoration(
                      labelText: "Kategorija *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items:
                        categoryResult?.result
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.categoryId.toString(),
                                child: Text(item.equipmentName ?? ""),
                              ),
                            )
                            .toList() ??
                        [],
                    validator: (value) {
                      if (value == null || value.toString().isEmpty) {
                        return 'Kategorija je obavezna';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Količina na stanju *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    name: "stockQuantity",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Količina je obavezna';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Količina mora biti broj';
                      }
                      if (int.parse(value) < 0) {
                        return 'Količina ne može biti negativna';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Cijena *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    name: "price",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Cijena je obavezna';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Cijena mora biti broj';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Cijena mora biti veća od 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "Opis",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              name: "description",
              maxLines: 3,
            ),
            SizedBox(height: 16),

            _buildImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Slika *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 46, 44, 44),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        if (_base64Image != null) ...[
          // Image preview
          Container(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageFromString(_base64Image!),
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.edit),
                      label: Text("Promijeni sliku"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _base64Image = null;
                        });
                      },
                      icon: Icon(Icons.delete),
                      label: Text("Ukloni sliku"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  "Nema odabrane slike",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text("Odaberi sliku"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      setState(() {
        _base64Image = base64Image;
      });
    }
  }

  Widget _saveRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text("Spremi"),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => EquipmentListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text("Odustani"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_base64Image == null) {
      MyDialogs.showError(context, 'Slika je obavezna!');
      return;
    }

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      var formData = _formKey.currentState!.value;

      var request = {
        'name': formData['name'],
        'description': formData['description'],
        'price': double.parse(formData['price']),
        'status': widget.equipment?.status ?? 'Active',
        'stockQuantity': int.parse(formData['stockQuantity']),
        'equipmentCategoryId': int.parse(formData['equipmentCategoryId']),
        'image': _base64Image,
      };

      try {
        if (widget.equipment?.equipmentId != null) {
          await equipmentProvider.update(
            widget.equipment!.equipmentId!,
            request,
          );
        } else {
          await equipmentProvider.insert(request);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => EquipmentListScreen()),
        );
      } catch (e) {
        MyDialogs.showError(context, 'Greška: $e');
      }
    }
  }

  void _showAddCategoryDialog() {
    final _categoryFormKey = GlobalKey<FormBuilderState>();
    String? _categoryName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dodaj novu kategoriju'),
          content: FormBuilder(
            key: _categoryFormKey,
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: 'Naziv kategorije',
                border: OutlineInputBorder(),
              ),
              name: 'categoryName',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Naziv je obavezan';
                }
                return null;
              },
              onChanged: (value) {
                _categoryName = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_categoryFormKey.currentState?.saveAndValidate() ?? false) {
                  try {
                    await equipmentCategoryProvider.insert({
                      'equipmentName': _categoryName,
                    });
                    Navigator.of(context).pop();
                    await initForm();
                    setState(() {});
                  } catch (e) {
                    MyDialogs.showError(context, 'Greška: $e');
                  }
                }
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }
}
