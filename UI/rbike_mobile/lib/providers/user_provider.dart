import 'package:rbike_mobile/models/user.dart';
import 'package:rbike_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super('User');

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User?> getUserByUsername(String username) async {
    final result = await get(filter: {'Username': username});
    if (result.count > 0) {
      return result.result.first;
    }
    return null;
  }

  @override
  Future<User> update(int id, [dynamic data]) async {
    return await super.update(id, data);
  }

  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl$end/$userId/change-password');
    final headers = createHeaders();
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode < 299) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception(
        jsonDecode(response.body)['error'] ??
            'Greška prilikom promjene lozinke',
      );
    } else {
      throw Exception('Greška prilikom promjene lozinke');
    }
  }

  @override
  Future<User> insert([dynamic data]) async {
    final url = Uri.parse('${baseUrl}User/register');
    final headers = createHeaders();
    final body = jsonEncode(data);
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode < 299) {
      return fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      String message = 'Greška prilikom registracije';
      try {
        final resp = jsonDecode(response.body);
        if (resp is Map && resp['error'] != null) {
          message = resp['error'];
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }
      throw Exception(message);
    } else {
      throw Exception('Greška prilikom registracije');
    }
  }

  Future<User?> login(String username, String password) async {
    final url = Uri.parse('${baseUrl}User/login?username=$username&password=$password');
    String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    final headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 204) {
      throw Exception("Neispravni podaci");
    } else {
      throw Exception("Login failed: \\${response.statusCode}");
    }
  }
}
