import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Controllers/TermsAndConditionController.dart';
import '../../../main.dart';

Future<TermsAndConditions> fetchTermsAndConditions() async {
  const url = 'https://us-central1-candid-cf9fc.cloudfunctions.net/getTermsAndConditions?tncFor=1';
  print('Fetching terms and conditions from: $url');

  final response = await http.get(
    Uri.parse(url),
    headers: await utils.getHeaders(),
  );

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String termsAndConditions = responseData['data']['tnc'];

    final Section section = Section(title: 'Terms and Conditions', content: termsAndConditions);

    return TermsAndConditions(sections: [section]);
  } else {
    print('Failed to fetch terms and conditions. Status code: ${response.statusCode}');
    throw Exception('Failed to load terms and conditions');
  }
}

