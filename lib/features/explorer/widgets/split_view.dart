import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class SplitView extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;

  const SplitView({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: leftPanel,
        ),
        Container(
          width: 1,
          color: AppColors.borderDark,
        ),
        Expanded(
          child: rightPanel,
        ),
      ],
    );
  }
}
