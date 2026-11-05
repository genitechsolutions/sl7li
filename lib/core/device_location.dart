import 'package:geolocator/geolocator.dart';

/// موقع الجهاز الحالي؛ [say] بيستقبل رسالة عربية إذا تعذّر.
Future<({double lat, double lng})?> currentDeviceLocation(
  void Function(String) say,
) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      say('فعّل خدمة الموقع بالجهاز');
      return null;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      say('ما قدرنا نوصل للموقع، اسمح بالإذن من الإعدادات');
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    say('تعذّر تحديد موقعك');
    return null;
  }
}
