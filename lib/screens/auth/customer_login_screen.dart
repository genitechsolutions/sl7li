import '../../core/widgets/coming_soon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/backend/app_config.dart';
import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/field_icons.dart';
import '../../core/widgets/form/field_popup.dart';
import '../../core/widgets/form/form_label.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/dummy_data.dart';
import '../home/home_screen.dart';
import 'widgets/auth_bottom_bar.dart';
import 'widgets/auth_header.dart';

/// "دخول الزبائن" — الاسم، المدينة (قائمة منسدلة)، والحي (بحث مع اقتراحات).
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _name = TextEditingController();
  final _district = TextEditingController();
  final _districtFocus = FocusNode();
  final _termsTap = TapGestureRecognizer()..onTap = showComingSoon;
  final _privacyTap = TapGestureRecognizer()..onTap = showComingSoon;

  String? _city;
  bool _cityOpen = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _district.addListener(() => setState(() {}));
    _districtFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _district.dispose();
    _districtFocus.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  bool get _canContinue => _name.text.trim().isNotEmpty && _city != null;

  List<String> get _districtMatches {
    final query = _district.text.trim();
    if (query.isEmpty) return const [];
    return loginDistricts.where((d) => d.contains(query) && d != query).toList();
  }

  void _pickCity(String city) => setState(() {
    _city = city;
    _cityOpen = false;
  });

  void _pickDistrict(String district) {
    _district.text = district;
    _districtFocus.unfocus();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (AppConfig.mode == BackendMode.amplify) {
        await cubit.saveRegistration(
          name: _name.text,
          city: _city,
          neighborhood: _district.text.trim(),
        );
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final matches = _districtMatches;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AuthBottomBar(
          label: _isLoading ? 'جاري إنشاء الحساب...' : 'متابعة',
          isLoading: _isLoading,
          onPressed: _canContinue ? _submit : null,
          note: AuthNote(
            spans: [
              const TextSpan(text: 'بالمتابعة أنت توافق على '),
              TextSpan(
                text: 'الشروط والأحكام',
                style: AuthNote.linkStyle(context),
                recognizer: _termsTap,
              ),
              const TextSpan(text: ' و '),
              TextSpan(
                text: 'سياسة الخصوصية',
                style: AuthNote.linkStyle(context),
                recognizer: _privacyTap,
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              AuthHeader(
                title: 'دخول الزبائن',
                subtitle: 'أدخل معلوماتك',
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 53),
              const Padding(
                padding: _labelPadding,
                child: FormLabel('الاسم الكامل', isRequired: true),
              ),
              const SizedBox(height: 8),
              AppTextField(hint: 'أدخل الاسم والكنية', controller: _name),
              const SizedBox(height: 18),
              const Padding(padding: _labelPadding, child: FormLabel('المدينة', isRequired: true)),
              const SizedBox(height: 8),
              FieldPopup(
                isOpen: _cityOpen,
                onDismiss: () => setState(() => _cityOpen = false),
                panel: _CityList(selected: _city, onSelected: _pickCity),
                child: AppSelectField(
                  hint: 'اختر مدينتك',
                  value: _city,
                  isActive: _cityOpen,
                  onTap: () => setState(() => _cityOpen = !_cityOpen),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: _labelPadding,
                child: FormLabel('الحي', note: '(اختياري)'),
              ),
              const SizedBox(height: 8),
              FieldPopup(
                above: true,
                isOpen: _districtFocus.hasFocus && (matches.isNotEmpty || _district.text.trim().isNotEmpty),
                onDismiss: _districtFocus.unfocus,
                panel: FieldPopupPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final d in matches.take(4))
                          FieldPopupItem(label: d, height: 42, onTap: () => _pickDistrict(d)),
                        if (matches.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'لا توجد مناطق تطابق البحث',
                              style: AppTextStyles.body16.copyWith(color: context.colors.textSecondary),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _pickDistrict(_district.text.trim()),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'إضغط هنا لإضافة “${_district.text.trim()}”',
                                style: AppTextStyles.body16.copyWith(
                                  color: context.colors.link,
                                  decoration: TextDecoration.underline,
                                  decorationColor: context.colors.link,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                child: AppTextField(
                  hint: 'ابحث عن الحي أو المنطقة...',
                  controller: _district,
                  focusNode: _districtFocus,
                  showFocusBorder: true,
                  suffixIcon: FieldIcons.search(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// قائمة المدن المنسدلة: 6 ظاهرين، شريط تمرير على اليمين متل التصميم.
class _CityList extends StatefulWidget {
  const _CityList({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<_CityList> createState() => _CityListState();
}

class _CityListState extends State<_CityList> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FieldPopupPanel(
      accentBottom: true,
      child: SizedBox(
        height: 294,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RawScrollbar(
              controller: _scroll,
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(2),
              thumbColor: context.colors.border,
              crossAxisMargin: 5,
              mainAxisMargin: 12,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsetsDirectional.fromSTEB(13, 10, 8, 10),
                  itemCount: loginCities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 7),
                  itemBuilder: (_, i) => FieldPopupItem(
                    label: loginCities[i],
                    selected: loginCities[i] == widget.selected,
                    onTap: () => widget.onSelected(loginCities[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
