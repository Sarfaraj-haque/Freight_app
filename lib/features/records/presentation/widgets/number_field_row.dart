import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

class NumberFieldRow extends StatelessWidget {
  const NumberFieldRow({
    super.key,
    required this.leftLabel,
    required this.leftHint,
    required this.leftController,
    required this.leftSuffix,
    required this.rightLabel,
    required this.rightHint,
    required this.rightController,
    required this.rightSuffix,
    this.isDecimal = false,
  });

  final String leftLabel, leftHint, leftSuffix;
  final TextEditingController leftController;
  final String rightLabel, rightHint, rightSuffix;
  final TextEditingController rightController;
  final bool isDecimal;

  @override
  Widget build(BuildContext context) {
    final formatters = isDecimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ]
        : <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

    return Row(
      children: [
        Expanded(
          child: AppTextField(
            label: leftLabel,
            hint: leftHint,
            controller: leftController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: formatters,
            suffix: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 12, 0),
              child: Text(leftSuffix,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextField(
            label: rightLabel,
            hint: rightHint,
            controller: rightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: formatters,
            suffix: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 12, 0),
              child: Text(rightSuffix,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ),
      ],
    );
  }
}
