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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscured : false,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization, // Handles Auto-Caps
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          // Interactive Eye Icon
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade400,
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
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
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