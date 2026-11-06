import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/field_icons.dart';
import '../../data/service_names.dart';
import '../new_request/new_request_screen.dart';

/// كل الخدمات بقائمة ببحث؛ اختيار خدمة بيفتح طلب خدمة بها.
class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final _query = TextEditingController();
  final _services = allServices();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim();
    final shown = [
      for (final s in _services)
        if (q.isEmpty || s.name.contains(q)) s,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  spacing: 12,
                  children: [
                    AppIconButton(
                      icon: 'assets/icons/ic_arrow_back.svg',
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(child: Text('كل الخدمات', style: AppTextStyles.title20Medium)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: AppTextField(
                  hint: 'ابحث عن خدمة',
                  controller: _query,
                  suffixIcon: FieldIcons.search(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد خدمات مطابقة',
                          style: AppTextStyles.body16.copyWith(color: context.colors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          MediaQuery.paddingOf(context).bottom + 16,
                        ),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: shown.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ServiceTile(
                          name: shown[i].name,
                          onTap: () => Navigator.pushReplacement(
                            context,
                            NewRequestScreen.route(serviceId: shown[i].id),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(name, style: AppTextStyles.body16)),
            Icon(Icons.chevron_left, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
