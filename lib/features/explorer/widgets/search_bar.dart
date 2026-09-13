import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.isNotEmpty;

    return Container(
      height: 36,
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search directory...',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 101, 101, 101),
          ),

          prefixIcon: hasText
              ? SizedBox(
                  width: 40,
                  height: 36,
                  child: Center(
                    child: Material(
                      color: Color(0xffefefef),
                      child: InkWell(
                        onTap: _clearSearch,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: AppSpacing.iconSizeSmall,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Icon(
                  Icons.search,
                  size: AppSpacing.iconSizeSmall,
                  color: Colors.black,
                ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 36,
          ),

          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            borderSide: const BorderSide(
              color: AppColors.borderDark,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            borderSide: const BorderSide(
              color: AppColors.borderDark,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),

        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
