import 'package:flutter/material.dart';

class CustomTextFormFieldField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isObscured;
  final TextInputType keyboardType;
  final Widget icon;

  const CustomTextFormFieldField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isObscured = false,
    required this.keyboardType,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          hintStyle: const TextStyle(fontSize: 14),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black),
          suffixIcon: icon,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
