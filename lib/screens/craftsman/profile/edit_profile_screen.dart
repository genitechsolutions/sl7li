import '../../../core/widgets/coming_soon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/backend/json_utils.dart';
import '../../../core/device_location.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_action_bar.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/photo_source.dart';
import '../../../core/widgets/form/app_checkbox.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/app_toggle.dart';
import '../../../core/widgets/form/field_icons.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../core/widgets/form/phone_field.dart';
import '../../../data/craftsman_signup.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../cubits/load_view.dart';
import '../../../cubits/professional_profile_cubit.dart';
import '../../../data/dummy_data.dart';
import '../../../data/repositories/professional_profile_repository.dart';
import '../signup/signup_step2_screen.dart';
import '../widgets/signup_scaffold.dart';

/// "الملف الشخصي" عند المهني: بيحمّل الملف الحقيقي، وزر الحفظ بيتفعّل بأول تعديل.
class EditCraftsmanProfileScreen extends StatelessWidget {
  const EditCraftsmanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: LoadView<ProfessionalProfileCubit, ProfessionalProfile>(
        onInit: (c) => c.load(force: true),
        builder: (_, p) => _EditForm(profile: p),
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({required this.profile});

  final ProfessionalProfile profile;

  @override
  State<_EditForm> createState() => _EditState();
}

class _EditState extends State<_EditForm> {
  ProfessionalProfile get _p => widget.profile;

  late final _d = _seedDraft();

  CraftsmanSignupDraft _seedDraft() {
    final d = CraftsmanSignupDraft()
      ..businessName = _p.businessName
      ..city = _p.cityCode == null ? null : placeName(_p.cityCode!)
      ..transport = _p.hasTransport == null
          ? null
          : _p.hasTransport!
          ? craftsmanTransportOptions.first
          : craftsmanTransportOptions.last
      ..workTimes = _p.workingHoursType
      ..hasTools = _p.hasTools ?? false
      ..districts.addAll([for (final c in _p.areaCodes) placeName(c)])
      ..services.addAll(_p.serviceNames.take(craftsmanMaxServices));
    // الخلفية ما بتخزّن التخصصات الدقيقة بهالشكل: نعتبر كل تخصصات الخدمة مختارة.
    for (final s in d.services) {
      d.specialties[s] = {...?craftsmanSpecialtiesByService[s]};
    }
    return d;
  }

  late final _name = TextEditingController(text: _d.businessName);
  late final _phone = TextEditingController(
    text: context.read<ProfileCubit>().state.data?.localPhone ?? '',
  );
  late final _bio = TextEditingController(text: _p.description);
  late final _years = TextEditingController(
    text: _p.experienceYears?.toString() ?? '',
  );
  late final _address = TextEditingController(text: _p.workshopAddress);
  final _district = TextEditingController();

  late String _active = _d.services.isEmpty ? '' : _d.services.first;
  final _touched = <String>{};
  double? _lat;
  double? _lng;
  String? _avatar;
  bool _saving = false;

  bool get _dirty => _touched.isNotEmpty || _avatar != null;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => _touched.add('name'));
    _bio.addListener(() => _touched.add('bio'));
    _years.addListener(() => _touched.add('years'));
    _address.addListener(() => _touched.add('address'));
    _district.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _bio, _years, _address, _district]) {
      c.dispose();
    }
    super.dispose();
  }

  void _change(VoidCallback fn, [String key = 'other']) => setState(() {
    fn();
    _touched.add(key);
  });

  Future<void> _pickAvatar() async {
    final picked = await pickPhotos(max: 1);
    if (picked.isNotEmpty && mounted) setState(() => _avatar = picked.first);
  }

  Future<void> _locate() async {
    final messenger = ScaffoldMessenger.of(context);
    final pos = await currentDeviceLocation(
      (m) => messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(m))),
    );
    if (pos != null && mounted) {
      _change(() {
        _lat = pos.lat;
        _lng = pos.lng;
      }, 'location');
    }
  }

  ProfessionalEdits _edits() => ProfessionalEdits(
    businessName: _touched.contains('name') ? _name.text.trim() : null,
    description: _touched.contains('bio') ? _bio.text.trim() : null,
    experienceYears: _touched.contains('years')
        ? int.tryParse(
            _years.text.replaceAllMapped(
              RegExp('[٠-٩]'),
              (m) => '${m[0]!.codeUnitAt(0) - 0x0660}',
            ),
          )
        : null,
    hasTools: _touched.contains('tools') ? _d.hasTools : null,
    hasTransport: _touched.contains('transport')
        ? _d.transport != craftsmanTransportOptions.last
        : null,
    workingHoursType: _touched.contains('workTimes') ? _d.workTimes : null,
    cityCode: _touched.contains('city') && _d.city != null
        ? placeCode(_d.city!)
        : null,
    areaCodes: _touched.contains('districts')
        ? [for (final x in _d.districts) placeCode(x)]
        : null,
    workshopAddress: _touched.contains('address') ? _address.text.trim() : null,
    latitude: _lat,
    longitude: _lng,
    serviceNames: _touched.contains('services') ? [..._d.services] : null,
  );

  Future<void> _save() async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<ProfessionalProfileCubit>();
    setState(() => _saving = true);
    try {
      if (_avatar != null) await cubit.saveAvatar(_avatar!);
      await cubit.save(_edits());
      nav.pop();
    } on BackendException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    } on Object {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذّر الحفظ، حاول مرة ثانية')));
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> onPicked,
    String key,
  ) async {
    final v = await showOptionsSheet(context, title: title, options: options);
    if (v != null) _change(() => onPicked(v), key);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = craftsmanSpecialtiesByService[_active] ?? const <String>[];
    final chosen = _d.specialties.putIfAbsent(_active, () => {});
    final q = _district.text.trim();
    final matches = q.isEmpty
        ? const <String>[]
        : loginDistricts
              .where((x) => x.contains(q) && !_d.districts.contains(x))
              .take(4)
              .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'حفظ التغييرات',
          onPressed: _dirty && !_saving ? _save : null,
          secondaryLabel: 'إلغاء',
          sideBySide: true,
          onSecondaryPressed: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الملف الشخصي',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Center(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: AppImage(
                              _avatar ??
                                  _p.imageUrl ??
                                  'assets/images/profile_avatar.png',
                              width: 96,
                              height: 96,
                            ),
                          ),
                          PositionedDirectional(
                            start: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _pickAvatar,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/ic_edit_badge.svg',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('الاسم الكامل'),
                    AppTextField(hint: 'الاسم الكامل', controller: _name),
                    top: 54,
                  ),
                  ...signupField(
                    const FormLabel('الرقم'),
                    // TODO: تغيير الرقم بيحتاج رمز تأكيد (Cognito)؛ هلق للعرض بس.
                    IgnorePointer(
                      child: PhoneField(
                        controller: _phone,
                        inline: true,
                        restrictInput: true,
                        onCountryTap: showCountryNotice,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 4,
                    ),
                    child: Text(
                      'تغيير رقم الهاتف سيتطلب إدخال رمز تأكيد',
                      style: AppTextStyles.body12.copyWith(color: colors.error),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('نبذة عن خبرتك ومهاراتك'),
                    AppTextField(
                      hint: 'نبذة مختصرة عن خدماتك وخبراتك...',
                      controller: _bio,
                      minLines: 4,
                    ),
                    top: 36,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الخدمات التي تقدمها',
                          style: AppTextStyles.body16Medium,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SignupStep2Screen(draft: _d, editing: true),
                              ),
                            );
                            setState(() {
                              _touched.add('services');
                              if (!_d.services.contains(_active) &&
                                  _d.services.isNotEmpty) {
                                _active = _d.services.first;
                              }
                            });
                          },
                          child: Text(
                            'تعديل',
                            style: AppTextStyles.body12.copyWith(
                              fontSize: 13,
                              color: colors.link,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.link,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in _d.services)
                        GestureDetector(
                          onTap: () => setState(() => _active = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: s == _active
                                  ? colors.primary
                                  : colors.background,
                              borderRadius: BorderRadius.circular(43),
                              border: Border.all(
                                color: s == _active
                                    ? colors.primary
                                    : colors.border,
                              ),
                            ),
                            child: Text(
                              s,
                              style: AppTextStyles.title18Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: s == _active
                                    ? colors.textOnPrimary
                                    : colors.primaryContent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'تخصصاتك ضمن $_active',
                      style: AppTextStyles.body16.copyWith(color: colors.link),
                    ),
                  ),
                  for (final o in options)
                    if (chosen.contains(o))
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            _change(() => chosen.remove(o), 'specialties'),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(o, style: AppTextStyles.body16),
                              ),
                              const AppCheckbox(value: true),
                            ],
                          ),
                        ),
                      ),
                  ...signupField(
                    const FormLabel('سنوات الخبرة'),
                    AppTextField(
                      hint: 'أدخل عدد سنوات خبرتك',
                      controller: _years,
                    ),
                    top: 24,
                  ),
                  ...signupField(
                    const FormLabel('هل تملك وسيلة مواصلات؟'),
                    AppSelectField(
                      hint: 'اختر وسيلة مواصلات',
                      value: _d.transport,
                      onTap: () => _pick(
                        'وسيلة المواصلات',
                        craftsmanTransportOptions,
                        (v) => _d.transport = v,
                        'transport',
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('أوقات العمل المفضلة'),
                    AppSelectField(
                      hint: 'اختر أوقات عملك المناسبة',
                      value: _d.workTimes,
                      onTap: () => _pick(
                        'أوقات العمل',
                        craftsmanWorkTimeOptions,
                        (v) => _d.workTimes = v,
                        'workTimes',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'أمتلك جميع الأدوات اللازمة',
                            style: AppTextStyles.body16Medium,
                          ),
                        ),
                        AppToggle(
                          value: _d.hasTools,
                          onChanged: (v) =>
                              _change(() => _d.hasTools = v, 'tools'),
                        ),
                      ],
                    ),
                  ),
                  ...signupField(
                    const FormLabel('المدينة'),
                    AppSelectField(
                      hint: 'اختر مدينتك',
                      value: _d.city,
                      onTap: () => _pick(
                        'المدينة المخدمة',
                        loginCities,
                        (v) => _d.city = v,
                        'city',
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('الحي'),
                    AppTextField(
                      hint: 'ابحث عن الحي أو المنطقة...',
                      controller: _district,
                      suffixIcon: FieldIcons.search(),
                    ),
                  ),
                  for (final m in matches)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _change(() {
                        _d.districts.add(m);
                        _district.clear();
                      }, 'districts'),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(m, style: AppTextStyles.body16),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.body16Medium,
                        children: [
                          const TextSpan(text: 'المناطق المختارة '),
                          TextSpan(
                            text: '(${_d.districts.length})',
                            style: AppTextStyles.body12.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in _d.districts)
                        GestureDetector(
                          onTap: () => _change(
                            () => _d.districts.remove(d),
                            'districts',
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 18,
                                  color: colors.textOnPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  d,
                                  style: AppTextStyles.body16Medium.copyWith(
                                    color: colors.textOnPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  ...signupField(
                    const FormLabel('عنوان الورشة'),
                    AppTextField(hint: 'عنوان الورشة', controller: _address),
                    top: 24,
                  ),
                  ...signupField(
                    const FormLabel('موقع الورشة على الخريطة'),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 175,
                            width: double.infinity,
                            // TODO: خريطة حقيقية (google_maps_flutter بموافقة)
                            child: Image.asset(
                              'assets/images/map_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _locate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'تحديد موقعي تلقائيا',
                              style: AppTextStyles.title18Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
