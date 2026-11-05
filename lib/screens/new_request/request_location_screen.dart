import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../data/request_draft.dart';
import 'new_request_screen.dart';
import 'request_confirm_screen.dart';
import 'widgets/request_step_header.dart';

/// طلب خدمة — الخطوة 3: تحديد الموقع.
class RequestLocationScreen extends StatefulWidget {
  const RequestLocationScreen({super.key, required this.draft});

  final RequestDraft draft;

  @override
  State<RequestLocationScreen> createState() => _RequestLocationScreenState();
}

class _RequestLocationScreenState extends State<RequestLocationScreen> {
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  RequestDraft get _draft => widget.draft;

  Future<void> _locate() async {
    final messenger = ScaffoldMessenger.of(context);
    void say(String m) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        say('فعّل خدمة الموقع بالجهاز');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        say('ما قدرنا نوصل للموقع، اسمح بالإذن من الإعدادات');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      setState(() {
        _draft.latitude = pos.latitude;
        _draft.longitude = pos.longitude;
        _draft.located = true;
      });
    } catch (_) {
      say('تعذّر تحديد موقعك');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'المتابعة',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RequestConfirmScreen(draft: _draft)),
          ),
          secondaryLabel: 'رجوع للخطوة السابقة',
          onSecondaryPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            children: [
              RequestStepHeader(
                step: 3,
                totalSteps: 4,
                onCancel: () => NewRequestScreen.cancelFlow(context),
              ),
              const SizedBox(height: 22),
              const Center(child: Text('تحديد الموقع', style: AppTextStyles.title24Bold)),
              const SizedBox(height: 33),
              Padding(
                padding: _labelPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الموقع التقريبي على الخريطة', style: AppTextStyles.body16Medium),
                    const SizedBox(height: 4),
                    Text(
                      'حدد مكان العمل بشكل تقريبي لاختيار مهنيين قريبين',
                      style: AppTextStyles.body12.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // TODO: خريطة حقيقية بتحتاج google_maps_flutter + مفتاح API؛ هلق صورة ثابتة.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 175,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/map_placeholder.png', fit: BoxFit.cover),
                      if (_draft.located)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 36),
                            child: Icon(Icons.location_on, size: 40, color: context.colors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _locate,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.textOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: AppTextStyles.title18,
                  ),
                  child: Text(_draft.located ? 'تم تحديد موقعك' : 'تحديد موقعي تلقائيا'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
