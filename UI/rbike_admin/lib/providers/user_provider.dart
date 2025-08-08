import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_admin/providers/base_provider.dart';
import 'package:rbike_admin/models/user.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    var url = "$baseUrl$end/login?username=$username&password=$password";
    var uri = Uri.parse(url);

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    var response = await http.post(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      throw Exception("Neispravni podaci");
    } else {
      throw Exception("Login failed: ${response.statusCode}");
    }
  }

  bool hasAdminRole(Map<String, dynamic> userData) {
    var userRoles = userData['userRoles'] as List<dynamic>;
    return userRoles.any(
      (role) => role['role'] != null && role['role']['name'] == 'Admin',
    );
  }

  Future<User> updateStatus(int userId, bool status) async {
    var url = "$baseUrl$end/$userId/status";
    var uri = Uri.parse(url);

    var headers = createHeaders();

    var response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update user status: \\${response.body}");
    }
  }

  Future<User?> getUserByUsername(String username) async {
    final result = await get(filter: {'username': username});
    if (result.result.isNotEmpty) {
      return result.result.first;
    }
    return null;
  }

  Future<void> changePassword(int userId, String oldPassword, String newPassword, String confirmPassword) async {
    var url = "$baseUrl$end/$userId/change-password";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    var response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      String message = 'Failed to change password.';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map && errors['ERROR'] is List && errors['ERROR'].isNotEmpty) {
            message = errors['ERROR'][0];
          }
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }
      throw Exception(message);
    }
  }
}
