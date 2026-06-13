import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) _ctrl.text = widget.initialValue!;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  48,
      margin:  const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      decoration: BoxDecoration(
        color:        AppColors.surface3,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged:  widget.onChanged,
        style:      AppFonts.inputText,
        decoration: InputDecoration(
          filled:       false,
          hintText:     'Search events, venues, cities...',
          hintStyle:    AppFonts.hintText,
          contentPadding: EdgeInsets.zero,
          border:       InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size:  20,
          ),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textHint, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
        ),
        onTap: () => setState(() {}),
      ),
    );
  }
}
