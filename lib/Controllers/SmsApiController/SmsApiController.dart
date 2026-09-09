import 'package:http/http.dart' as http;

class SmsApiController {
  Future<void> sendSms(String mobileNumber, String message) async {
    String apiUrl = '<API_URL>';
    Uri apiUri = Uri.parse(apiUrl);
    var response = await http.post(
      apiUri,
      body: {
        'mobileNumber': mobileNumber,
        'message': message,
      },
    );
    if (response.statusCode == 200) {
      print('SMS sent successfully');
    } else {
      print('Failed to send SMS');
      throw Exception('Failed to send SMS');
    }
  }
}
