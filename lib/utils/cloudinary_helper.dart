import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryHelper {
  static const String cloudName = 'dytoelskh';
  static const String apiKey = '798176284587252';
  static const String apiSecret = 'rT2MswML3eI1hkTnBaV9OGZv0I8';

  /// Uploads a file to Cloudinary and returns the secure URL
  static Future<String?> uploadFile(String filePath, {String resourceType = 'auto'}) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      // 1. Generate Signature
      // Parameters to sign must be sorted alphabetically.
      // Since we only send timestamp (file is not signed, api_key is not signed), it's just:
      final stringToSign = 'timestamp=$timestamp$apiSecret';
      final bytes = utf8.encode(stringToSign);
      final digest = sha1.convert(bytes);
      final signature = digest.toString();

      // 2. Prepare Multipart Request
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      // 3. Send Request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        // Return the secure URL from Cloudinary
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary Upload Failed: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Exception: $e');
      return null;
    }
  }
}
