import 'package:flutter/material.dart';
import 'package:rbike_mobile/providers/user_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  String? errorMsg;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      await UserProvider().insert({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'status': true,
        'userRoles': [
          {'roleId': 2},
        ],
      });
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Registracija uspješna'),
                content: const Text(
                  'Sada se možete prijaviti sa svojim podacima.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      String err = e.toString().replaceFirst('Exception: ', '');
      if (err.contains('Username is already taken')) {
        err = 'Korisničko ime je već zauzeto';
      } else if (err.contains('Email is already taken')) {
        err = 'Email je već zauzet';
      }
      setState(() {
        errorMsg = err;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
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
                    decoration: const InputDecoration(labelText: 'Prezime'),
                    onChanged: (v) => lastName = v,
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Prezime je obavezno'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Korisničko ime',
                    ),
                    onChanged: (v) => username = v,
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Korisničko ime je obavezno'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (v) => email = v,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final emailRegex = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000*',
                      );
                      if (!emailRegex.hasMatch(v)) return 'Email nije ispravan';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    onChanged: (v) => phone = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Lozinka'),
                    obscureText: true,
                    onChanged: (v) => password = v,
                    validator:
                        (v) =>
                            v == null || v.length < 6
                                ? 'Lozinka mora imati najmanje 6 karaktera'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Potvrda lozinke',
                    ),
                    obscureText: true,
                    onChanged: (v) => confirmPassword = v,
                    validator:
                        (v) => v != password ? 'Lozinke se ne poklapaju' : null,
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
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Registruj se'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
