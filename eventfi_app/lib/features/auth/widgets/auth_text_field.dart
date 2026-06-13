import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class AuthTextField extends StatefulWidget {
  final String                    label;
  final String?                   hint;
  final TextEditingController     controller;
  final bool                      isPassword;
  final TextInputType             keyboardType;
  final String? Function(String?) validator;
  final Widget?                   prefixIcon;
  final bool                      readOnly;
  final VoidCallback?             onTap;
  final int?                      maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization        textCapitalization;
  final void Function(String)?    onChanged;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.hint,
    this.isPassword         = false,
    this.keyboardType       = TextInputType.text,
    this.prefixIcon,
    this.readOnly           = false,
    this.onTap,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:          widget.controller,
      obscureText:         widget.isPassword ? _obscure : false,
      keyboardType:        widget.keyboardType,
      readOnly:            widget.readOnly,
      onTap:               widget.onTap,
      maxLength:           widget.maxLength,
      inputFormatters:     widget.inputFormatters,
      textCapitalization:  widget.textCapitalization,
      validator:           widget.validator,
      onChanged:           widget.onChanged,
      style:               AppFonts.inputText,
      decoration: InputDecoration(
        labelText:   widget.label,
        hintText:    widget.hint,
        counterText: '',
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: widget.prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
