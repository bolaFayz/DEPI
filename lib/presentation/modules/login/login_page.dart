import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared widgets/custom_text_form_field.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Login',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge!.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Welcome Back",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                CustomTextFormFieldField(
                  controller: controller.emailController,
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  icon: Icon(Icons.email),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return CustomTextFormFieldField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    keyboardType: TextInputType.text,
                    isObscured: controller.isObscure.value,
                    icon: IconButton(
                      onPressed: () {
                        controller.isObscure.toggle();
                      },
                      icon: controller.isObscure.value
                          ? Icon(Icons.lock)
                          : Icon(Icons.lock_open_sharp),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // CustomElevatedButton(text: 'SIGN IN', onPressed: (){
                //   controller.signIn();
                // })
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      controller.signIn();
                    },
                    child: Text(
                      'SIGN IN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
