import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/bike.dart';
import 'package:rbike_admin/models/category.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/bike_provider.dart';
import 'package:rbike_admin/providers/category_provider.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/screens/bike_list_screen.dart';

class BikeDetailsScreen extends StatefulWidget {
  Bike? bike;
  BikeDetailsScreen({super.key, this.bike});

  @override
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late BikeProvider bikeProvider;
  late CategoryProvider categoryProvider;
  SearchResult<Category>? categoryResult;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    bikeProvider = context.read<BikeProvider>();
    categoryProvider = context.read<CategoryProvider>();

    super.initState();

    _initialValue = {
      'bikeCode': widget.bike?.bikeCode ?? '',
      'name': widget.bike?.name ?? '',
      'price': widget.bike?.price?.toString() ?? '',
      'categoryId': widget.bike?.categoryId?.toString() ?? '',
    };

    if (widget.bike?.image != null) {
      _base64Image = widget.bike!.image;
    }

    initForm();
  }

  Future initForm() async {
    categoryResult = await categoryProvider.get();

    print("cr ${categoryResult?.result}");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Detalji",
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
        child: Column(
          children: [isLoading ? Container() : _buildForm(), _saveRow()],
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Naziv",
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
                SizedBox(width: 10),
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Šifra",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    name: "bikeCode",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Šifra je obavezna';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown(
                    name: "categoryId",
                    decoration: InputDecoration(
                      labelText: "Kategorija",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items:
                        categoryResult?.result
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.categoryId.toString(),
                                child: Text(item.name ?? ""),
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
                SizedBox(width: 10),
                Expanded(
                  child: FormBuilderTextField(
                    decoration: InputDecoration(
                      labelText: "Cijena",
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
                      final regex = RegExp(r'^\d+(\.\d{2})$');
                      if (!regex.hasMatch(value)) {
                        return 'Cijena mora biti u formatu npr. 20.00 (koristite tačku, ne zarez)';
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
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Odaberite sliku",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.image_outlined),
                          title: Text("Select image"),
                          trailing: Icon(Icons.file_upload_outlined),
                          onTap: getImage,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_image != null || widget.bike?.image != null)
                        Center(
                          child: Container(
                            height: 300,
                            width: 600,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              image: DecorationImage(
                                image:
                                    _image != null
                                        ? FileImage(_image!)
                                        : MemoryImage(
                                              base64Decode(widget.bike!.image!),
                                            )
                                            as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                var request = Map.from(_formKey.currentState!.value);
                request["image"] = _base64Image;

                try {
                  if (widget.bike == null) {
                    await bikeProvider.insert(request);

                    _formKey.currentState?.reset();
                    _image = null;
                    _base64Image = null;

                    _initialValue = {
                      'bikeCode': '',
                      'name': '',
                      'price': '',
                      'categoryId': '',
                    };

                    setState(() {});

                    MyDialogs.showSuccess(
                      context,
                      'Bicikl uspješno dodan!',
                      () {},
                    );
                  } else {
                    await bikeProvider.update(widget.bike!.bikeId!, request);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => BikeListScreen()),
                    );

                    MyDialogs.showSuccess(
                      context,
                      'Bicikl uspješno ažuriran!',
                      () {},
                    );
                  }
                } catch (e) {
                  print("Error during save: $e");
                  String msg = e.toString();
                  if (msg.contains('Method not allowed')) {
                    msg = "Ne možete editovati biciklo koje nije u draft state";
                  }
                  MyDialogs.showError(context, 'Greška: $msg');
                }
              } else {
                MyDialogs.showError(
                  context,
                  'Molimo popunite sva obavezna polja',
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text("Sačuvaj"), SizedBox(width: 8), Icon(Icons.save)],
            ),
          ),
        ],
      ),
    );
  }

  File? _image;
  String? _base64Image;

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());

      setState(() {});
    }
  }

  void _showAddCategoryDialog() {
    final categoryFormKey = GlobalKey<FormBuilderState>();
    final categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dodaj novu kategoriju'),
          content: Container(
            width: 400,
            child: FormBuilder(
              key: categoryFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'categoryName',
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      labelText: 'Naziv kategorije',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Molimo unesite naziv kategorije';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryFormKey.currentState?.saveAndValidate() ?? false) {
                  try {
                    final newCategory = await categoryProvider.insert({
                      'name': categoryNameController.text.trim(),
                    });

                    await initForm();

                    setState(() {});

                    Navigator.of(context).pop();

                    MyDialogs.showSuccess(
                      context,
                      'Kategorija uspješno dodana!',
                      () {},
                    );
                  } catch (e) {
                    MyDialogs.showError(
                      context,
                      'Greška pri dodavanju kategorije: ${e.toString()}',
                    );
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
