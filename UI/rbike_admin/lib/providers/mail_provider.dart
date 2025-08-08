import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_admin/models/mail_object.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class MailProvider extends BaseProvider<void> {
  MailProvider() : super('Mail');

  Future<void> sendMail(MailObject mail) async {
    var url = "${baseUrl}Mail";
    var headers = createHeaders();
    var body = jsonEncode(mail.toJson());
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (!isValidResponse(response)) {
      throw Exception('Failed to send mail');
    }
  }

  @override
  void fromJson(data) {}
}
