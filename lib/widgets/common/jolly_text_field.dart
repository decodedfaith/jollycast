import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JollyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final TextAlign textAlign;

  const JollyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: isPassword,
              textAlign: textAlign,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
