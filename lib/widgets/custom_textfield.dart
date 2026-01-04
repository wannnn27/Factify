import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final String? errorText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.isPassword = false,
    this.isObscure = false,
    this.onToggleVisibility,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.suffix,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (opsional)
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // TextField
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF00C9A7).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isObscure,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            style: TextStyle(
              color: widget.enabled ? Colors.black87 : Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: widget.enabled 
                  ? Colors.white 
                  : Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: widget.maxLines! > 1 ? 16 : 16,
              ),
              
              // PREFIX ICON
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused 
                            ? const Color(0xFF00C9A7) 
                            : Colors.grey[400],
                        size: 22,
                      ),
                    )
                  : null,
              
              // SUFFIX ICON
              suffixIcon: _buildSuffixIcon(),
              
              // ERROR TEXT
              errorText: widget.errorText,
              errorStyle: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
              ),
              
              // BORDER
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00C9A7),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B6B),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B6B),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              
              // Counter text styling
              counterStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Jika ada custom suffix, gunakan itu
    if (widget.suffix != null) {
      return widget.suffix;
    }
    
    // Jika password field, tampilkan toggle visibility
    if (widget.isPassword && widget.onToggleVisibility != null) {
      return IconButton(
        icon: Icon(
          widget.isObscure 
              ? Icons.visibility_off_outlined 
              : Icons.visibility_outlined,
          color: _isFocused 
              ? const Color(0xFF00C9A7) 
              : Colors.grey[400],
          size: 22,
        ),
        onPressed: widget.onToggleVisibility,
      );
    }
    
    // Jika controller ada dan ada text, tampilkan clear button
    if (widget.controller != null && 
        widget.controller!.text.isNotEmpty && 
        !widget.readOnly &&
        widget.enabled) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.grey[400],
          size: 20,
        ),
        onPressed: () {
          widget.controller!.clear();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
        },
      );
    }
    
    return null;
  }
}

// VARIANT: TextField dengan validation FormField
class CustomFormTextField extends FormField<String> {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  @override
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  CustomFormTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    super.validator,
    super.onSaved,
    String? initialValue,
  }) : super(
          initialValue: controller != null ? controller.text : (initialValue ?? ''),
          builder: (FormFieldState<String> state) {
            return _CustomFormTextFieldWidget(
              state: state,
              controller: controller,
              hintText: hintText,
              labelText: labelText,
              isPassword: isPassword,
              prefixIcon: prefixIcon,
              keyboardType: keyboardType,
              maxLines: maxLines,
              maxLength: maxLength,
              enabled: enabled,
              inputFormatters: inputFormatters,
            );
          },
        );
}

class _CustomFormTextFieldWidget extends StatefulWidget {
  final FormFieldState<String> state;
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomFormTextFieldWidget({
    required this.state,
    this.controller,
    required this.hintText,
    this.labelText,
    required this.isPassword,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    required this.enabled,
    this.inputFormatters,
  });

  @override
  State<_CustomFormTextFieldWidget> createState() => _CustomFormTextFieldWidgetState();
}

class _CustomFormTextFieldWidgetState extends State<_CustomFormTextFieldWidget> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      labelText: widget.labelText,
      isPassword: widget.isPassword,
      isObscure: widget.isPassword ? _isObscure : false,
      onToggleVisibility: widget.isPassword 
          ? () => setState(() => _isObscure = !_isObscure)
          : null,
      prefixIcon: widget.prefixIcon,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      errorText: widget.state.errorText,
      onChanged: (value) {
        widget.state.didChange(value);
      },
    );
  }
}