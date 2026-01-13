import 'package:flutter/material.dart';

class CyberTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isObscured; // New: Controls if text is hidden
  final VoidCallback? onEyePressed; // New: Click action for the eye
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const CyberTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isObscured = false,
    this.onEyePressed,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode (which is default for this app)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        // Dark background for inputs to match the theme
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscured : false,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization, // Handles Auto-Caps
        // Make text white in dark mode
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          // Lighter grey hints for better contrast on dark bg
          hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          // Interactive Eye Icon
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                  ),
                  onPressed: onEyePressed,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CyberButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676), // Use Neon Green from theme
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}