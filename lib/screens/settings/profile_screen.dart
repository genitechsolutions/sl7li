import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/feature_cubits.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/field_icons.dart';
import '../../core/widgets/form/form_label.dart';
import '../../core/widgets/form/phone_field.dart';

/// "الملف الشخصي": تعديل الاسم والرقم والمدينة والحي.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _district = TextEditingController(text: 'مركز المدينة');

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileCubit>().state.data;
    if (p != null) {
      _name.text = p.name;
      _phone.text = p.localPhone;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _district.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        // TODO: حفظ التغييرات الحقيقي (API)
        bottomNavigationBar: AppBottomActionBar(
          label: 'حفظ التغييرات',
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/profile_avatar.png',
                                width: 96,
                                height: 96,
                              ),
                            ),
                            PositionedDirectional(
                              start: 0,
                              bottom: 0,
                              // TODO: اختيار صورة حقيقي (image_picker)
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel('الاسم الكامل'),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(hint: 'الاسم الكامل', controller: _name),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel('الرقم'),
                    ),
                    const SizedBox(height: 8),
                    PhoneField(
                      controller: _phone,
                      inline: true,
                      restrictInput: true,
                      onCountryTap: () {}, // TODO: pick country code
                    ),
                    Padding(
                      padding: _labelPadding.add(
                        const EdgeInsetsDirectional.only(top: 4),
                      ),
                      child: Text(
                        'تغيير رقم الهاتف سيتطلب إدخال رمز تأكيد',
                        style: AppTextStyles.body12.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel('المدينة'),
                    ),
                    const SizedBox(height: 8),
                    // TODO: قائمة المدن (متل شاشة دخول الزبائن)
                    AppSelectField(
                      hint: 'المدينة',
                      value: 'دمشق',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel('الحي'),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      hint: 'الحي',
                      controller: _district,
                      suffixIcon: FieldIcons.search(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
