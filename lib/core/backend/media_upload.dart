import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'backend_exception.dart';
import 'graphql_documents.dart';
import 'graphql_gateway.dart';
import 'json_utils.dart';

/// بيرفع ملف محلي (أو blob بالويب) لـ S3 عبر رابط موقّع وبيرجع مفتاحه.
/// [type]: image/offer/portfolio/profile/government-id.
Future<String> uploadMedia(
  GraphQlGateway gateway,
  String path, {
  String type = 'image',
  String contentType = 'image/jpeg',
  String? fileName,
}) async {
  final name = fileName ?? path.split(RegExp(r'[/\\]')).last;
  final data = await gateway.run(
    Gql.generateUploadUrl,
    variables: {'fileType': type, 'fileName': name, 'contentType': contentType},
    mutation: true,
  );
  final up = asMap(data['generateUploadUrlSecure']);
  throwIfBackendError(up);
  final url = str(up, 'uploadUrl');
  final key = str(up, 's3Key');
  if (url == null || key == null) throw const BackendException('تعذّر رفع الملف');
  final bytes = await XFile(path).readAsBytes();
  try {
    final res = await http.put(Uri.parse(url), headers: {'Content-Type': contentType}, body: bytes);
    if (res.statusCode >= 300) throw const BackendException('تعذّر رفع الملف');
  } on http.ClientException {
    throw const BackendException('تعذّر الاتصال بالإنترنت');
  }
  return key;
}

bool isLocalPhoto(String p) => !p.startsWith('assets/');
