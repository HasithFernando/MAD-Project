import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const PasswordTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.borderRadius,
    this.controller,
    this.keyboardType = TextInputType.visiblePassword,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.textColor ??
                Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: TextStyle(
            color: widget.textColor ??
                Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.hintColor ?? Theme.of(context).hintColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              borderSide: BorderSide(
                color: widget.borderColor ?? Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              borderSide: BorderSide(
                color: widget.borderColor ?? Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              borderSide: BorderSide(
                color: widget.borderColor ?? Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            // Add suffix icon to toggle password visibility
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage in your app:
class PasswordWidgetExample extends StatelessWidget {
  PasswordWidgetExample({Key? key}) : super(key: key);

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Field Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PasswordTextField(
          labelText: 'Password',
          hintText: 'Enter your password',
          controller: _passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ),
    );
  }
}
