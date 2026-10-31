import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/craftsman_card.dart';
import '../../core/widgets/filter_chip_button.dart';
import '../../core/widgets/promo_banner.dart';
import '../../data/dummy_data.dart';
import '../craftsman_profile/craftsman_profile_screen.dart';
import '../new_request/new_request_screen.dart';
import 'widgets/search_top_bar.dart';
import 'widgets/suggestion_tile.dart';

/// صفحة البحث: اقتراحات (آخر عمليات البحث + الشائعة) قبل البحث، ونتائج بعده.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _padding = EdgeInsets.symmetric(horizontal: 20);
  // العناوين الفرعية بالتصميم داخلة 12 عن باقي المحتوى.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    _controller.text = query;
    _focusNode.unfocus();
    setState(() => _showResults = true);
  }

  void _fill(String query) {
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _showResults ? context.colors.surface : context.colors.background,
        body: Column(
          children: [
            SearchTopBar(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (text) {
                if (_showResults && text.isEmpty) setState(() => _showResults = false);
              },
              onSubmitted: _search,
            ),
            Expanded(child: _showResults ? _results() : _suggestions()),
          ],
        ),
      ),
    );
  }

  Widget _suggestions() {
    Widget section(String title, List<String> items, IconData icon) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: _labelPadding,
            child: Text(
              title,
              style: AppTextStyles.body16.copyWith(color: context.colors.textSecondary),
            ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            SuggestionTile(
              label: item,
              icon: icon,
              onTap: () => _search(item),
              onFill: () => _fill(item),
            ),
        ],
      );
    }

    return ListView(
      padding: _padding.copyWith(top: 20, bottom: 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        section('عمليات البحث الأخيرة:', recentSearches, Icons.history_rounded),
        const SizedBox(height: 15),
        section('عمليات البحث الشائعة:', popularSearches, Icons.search_rounded),
      ],
    );
  }

  Widget _results() {
    return ListView(
      padding: _padding.copyWith(top: 12, bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        Row(
          spacing: 10,
          children: [
            FilterChipButton(label: 'تصنيف المهني', onTap: () {}), // TODO: open filter
            FilterChipButton(label: 'المنطقة', onTap: () {}), // TODO: open filter
            FilterChipButton(label: 'التقييم', onTap: () {}), // TODO: open filter
          ],
        ),
        const SizedBox(height: 21),
        const Padding(
          padding: _labelPadding,
          child: Text('أفضل المهنيين المطابقين', style: AppTextStyles.title18Medium),
        ),
        const SizedBox(height: 12),
        PromoBanner(
          title: 'اختر أفضل المهنيين',
          subtitle: 'حدد حتى 5 مهنيين مخصصين لإرسال طلبك لهم بشكل خاص',
          buttonLabel: 'اختيار المهنيين',
          onPressed: () => Navigator.push(context, NewRequestScreen.route()),
        ),
        const SizedBox(height: 13),
        for (final craftsman in searchResults)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CraftsmanCard(
              craftsman: craftsman,
              color: context.colors.background,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CraftsmanProfileScreen(profile: sampleCraftsmanProfile),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
