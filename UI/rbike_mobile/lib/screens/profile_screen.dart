import 'package:flutter/material.dart';
import 'package:rbike_mobile/models/user.dart';
import 'package:rbike_mobile/providers/user_provider.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:rbike_mobile/providers/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final username = AuthProvider.username;
    if (username != null) {
      final user = await UserProvider().getUserByUsername(username);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moj profil')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : _user == null
                  ? const Text('Nije moguće učitati podatke o korisniku.')
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child:
                            (_user?.image != null && _user!.image!.isNotEmpty)
                                ? ClipOval(
                                  child: imageFromString(_user!.image!),
                                )
                                : Icon(Icons.person, size: 48),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Ime', _user?.firstName ?? ''),
                      _buildInfoRow('Prezime', _user?.lastName ?? ''),
                      _buildInfoRow('Korisničko ime', _user?.username ?? ''),
                      _buildInfoRow('Email', _user?.email ?? ''),
                      _buildInfoRow(
                        'Datum registracije',
                        _user?.dateRegistered?.toLocal().toString().split(
                              ' ',
                            )[0] ??
                            '',
                      ),
                      _buildInfoRow('Telefon', _user?.phone ?? ''),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Uredi'),
                        onPressed: () {
                          _showEditProfileDialog();
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock),
                        label: const Text('Promijeni lozinku'),
                        onPressed: () {
                          _showChangePasswordDialog();
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Promijeni sliku'),
                        onPressed: () {
                          _showChangeImageDialog();
                        },
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditProfileDialog() async {
    final _formKey = GlobalKey<FormState>();
    String firstName = _user?.firstName ?? '';
    String lastName = _user?.lastName ?? '';
    String email = _user?.email ?? '';
    String phone = _user?.phone ?? '';
    bool isLoading = false;
    String? errorMsg;
    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Icon(Icons.edit, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Uredi profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: firstName,
                            decoration: const InputDecoration(labelText: 'Ime'),
                            onChanged: (v) => firstName = v,
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Ime je obavezno'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: lastName,
                            decoration: const InputDecoration(
                              labelText: 'Prezime',
                            ),
                            onChanged: (v) => lastName = v,
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Prezime je obavezno'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            onChanged: (v) => email = v,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000*',
                              );
                              if (!emailRegex.hasMatch(v))
                                return 'Email nije ispravan';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefon',
                            ),
                            onChanged: (v) => phone = v,
                          ),
                          if (errorMsg != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMsg!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: const Text('Odustani'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setState(() => isLoading = true);
                                      try {
                                        await UserProvider()
                                            .update(_user!.userId!, {
                                              'firstName': firstName,
                                              'lastName': lastName,
                                              'email': email,
                                              'phone': phone,
                                              'status': _user!.status,
                                              'image': _user!.image,
                                            });
                                        Navigator.of(context).pop();
                                        await _loadUser();
                                        _showSuccessDialog(
                                          'Profil je uspješno ažuriran.',
                                        );
                                      } catch (e) {
                                        setState(() {
                                          errorMsg = e.toString().replaceFirst(
                                            'Exception: ',
                                            '',
                                          );
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                          child: const Text('Spremi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() async {
    final _formKey = GlobalKey<FormState>();
    String oldPassword = '';
    String newPassword = '';
    String confirmPassword = '';
    bool isLoading = false;
    String? errorMsg;
    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber[50],
                          child: Icon(
                            Icons.lock,
                            color: Colors.amber[800],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Promijeni lozinku',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Stara lozinka',
                            ),
                            obscureText: true,
                            onChanged: (v) => oldPassword = v,
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Obavezno polje'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nova lozinka',
                            ),
                            obscureText: true,
                            onChanged: (v) => newPassword = v,
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Obavezno polje'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Ponovi novu lozinku',
                            ),
                            obscureText: true,
                            onChanged: (v) => confirmPassword = v,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Obavezno polje';
                              if (v != newPassword)
                                return 'Unesene lozinke se ne poklapaju';
                              return null;
                            },
                          ),
                          if (errorMsg != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMsg!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: const Text('Odustani'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      if (newPassword != confirmPassword) {
                                        setState(() {
                                          errorMsg =
                                              'Unesene lozinke se ne poklapaju';
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      setState(() => isLoading = true);
                                      try {
                                        await UserProvider().changePassword(
                                          _user!.userId!,
                                          oldPassword,
                                          newPassword,
                                          confirmPassword,
                                        );
                                        Navigator.of(context).pop();
                                        _showSuccessDialog(
                                          'Lozinka je uspješno promijenjena.',
                                        );
                                      } catch (e) {
                                        setState(() {
                                          errorMsg = e.toString().replaceFirst(
                                            'Exception: ',
                                            '',
                                          );
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                          child: const Text('Spremi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Uspjeh'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showChangeImageDialog() async {
    String? newImageBase64 = _user?.image;
    bool isLoading = false;
    String? errorMsg;

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Promijeni sliku',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            child:
                                (newImageBase64?.isNotEmpty ?? false)
                                    ? ClipOval(
                                      child: imageFromString(newImageBase64!),
                                    )
                                    : Icon(Icons.person, size: 60),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.blue),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image);
                                if (result != null &&
                                    result.files.single.path != null) {
                                  File file = File(result.files.single.path!);
                                  List<int> imageBytes =
                                      await file.readAsBytes();
                                  String base64Image = base64Encode(imageBytes);
                                  setState(() {
                                    newImageBase64 = base64Image;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMsg!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: const Text('Odustani'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    setState(() => isLoading = true);
                                    try {
                                      await UserProvider()
                                          .update(_user!.userId!, {
                                            'firstName': _user!.firstName,
                                            'lastName': _user!.lastName,
                                            'email': _user!.email,
                                            'phone': _user!.phone,
                                            'status': _user!.status,
                                            'image': newImageBase64,
                                          });
                                      Navigator.of(context).pop();
                                      await _loadUser();
                                      _showSuccessDialog(
                                        'Slika je uspješno ažurirana.',
                                      );
                                    } catch (e) {
                                      setState(() {
                                        errorMsg = e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        );
                                        isLoading = false;
                                      });
                                    }
                                  },
                          child: const Text('Spremi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
