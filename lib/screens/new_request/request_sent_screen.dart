import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/request_draft.dart';
import 'new_request_screen.dart';
import 'widgets/request_step_header.dart';
import 'widgets/success_illustration.dart';

/// "تم إرسال طلبك بنجاح" — بعد إرسال الطلب.
class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key});

  /// افتح صفحة النجاح وسكّر كل اللي فوق الرئيسية (خطوات الطلب، البحث...).
  static void open(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RequestSentScreen()),
      (route) => route.isFirst,
    );
  }

  /// بيرسل الطلب للخلفية؛ إذا نجح بيفتح صفحة النجاح، وإلا بيعرض الخطأ. بيرجّع true عند النجاح.
  static Future<bool> submit(BuildContext context, RequestDraft draft) async {
    final cubit = context.read<MyRequestsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await cubit.create(draft);
    } on BackendException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
      return false;
    } on Object {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('تعذّر إرسال الطلب، حاول مرة ثانية')),
        );
      return false;
    }
    if (context.mounted) open(context);
    return true;
  }

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen> {
  final _supportTap = TapGestureRecognizer()
    ..onTap = () {}; // TODO: open customer support

  static const _steps = [
    'تم إشعار المهنيين بوجود طلب خدمة جديد',
    'تصل العروض عادة خلال 10 - 60 دقيقة',
    'ستصلك إشعارات عند وصول عرض جديد',
  ];

  @override
  void dispose() {
    _supportTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = AppTextStyles.body16.copyWith(
      color: context.colors.textSecondary,
    );
    final lineStyle = secondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'وضع طلب أخر',
          onPressed: () =>
              Navigator.pushReplacement(context, NewRequestScreen.route()),
          secondaryLabel: 'إغلاق',
          onSecondaryPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            children: [
              RequestStepHeader(
                step: 5,
                totalSteps: 4,
                subtitle: 'تم إرسال الطلب',
                actionLabel: 'العودة للصفحة الرئيسية',
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 53),
              const Center(child: SuccessIllustration()),
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'تم إرسال طلبك بنجاح',
                  style: AppTextStyles.title22Bold,
                ),
              ),
              const SizedBox(height: 10),
              Center(child: Text('ما هي الخطوة التالية؟', style: secondary)),
              const SizedBox(height: 8),
              for (final step in _steps)
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: lineStyle,
                  ),
                ),
              const SizedBox(height: 23),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Text.rich(
                  TextSpan(
                    style: lineStyle.copyWith(height: 1.5),
                    children: [
                      const TextSpan(
                        text: 'بعض الطلبات قد تستغرق وقتا أطول يرجى الانتظار ',
                      ),
                      TextSpan(
                        text: '3\u00A0أيام',
                        style: TextStyle(color: context.colors.textPrimary),
                      ),
                      const TextSpan(text: ' كحد أقصى, ويمكنك التواصل مع '),
                      TextSpan(
                        text: 'خدمة العملاء',
                        recognizer: _supportTap,
                        style: TextStyle(
                          color: context.colors.link,
                          decoration: TextDecoration.underline,
                          decorationColor: context.colors.link,
                        ),
                      ),
                      const TextSpan(text: ' في حال تأخر العروض أكثر من ذلك'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
