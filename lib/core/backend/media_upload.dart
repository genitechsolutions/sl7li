import 'dart:io';

import 'backend_exception.dart';
import 'graphql_documents.dart';
import 'graphql_gateway.dart';
import 'json_utils.dart';

/// بيرفع ملف محلي لـ S3 عبر رابط موقّع وبيرجع مفتاحه. [type]: image/offer/portfolio/profile/government-id.
Future<String> uploadMedia(
  GraphQlGateway gateway,
  String path, {
  String type = 'image',
  String contentType = 'image/jpeg',
}) async {
  final name = path.split(RegExp(r'[/\\]')).last;
  final data = await gateway.run(
    Gql.generateUploadUrl,
    variables: {'fileType': type, 'fileName': name, 'contentType': contentType},
    mutation: true,
  );
  final up = asMap(data['generateUploadUrlSecure']);
  throwIfBackendError(up);
  final url = str(up, 'uploadUrl');
  final key = str(up, 's3Key');
  if (url == null || key == null) throw const BackendException('تعذّر رفع الصورة');
  final bytes = await File(path).readAsBytes();
  final client = HttpClient();
  try {
    final req = await client.putUrl(Uri.parse(url));
    req.headers.contentType = ContentType.parse(contentType);
    req.add(bytes);
    final res = await req.close();
    await res.drain<void>();
    if (res.statusCode >= 300) throw const BackendException('تعذّر رفع الصورة');
  } on SocketException {
    throw const BackendException('تعذّر الاتصال بالإنترنت');
  } finally {
    client.close();
  }
  return key;
}

bool isLocalPhoto(String p) => !p.startsWith('assets/');
