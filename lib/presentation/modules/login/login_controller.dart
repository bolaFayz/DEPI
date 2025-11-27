import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isObscure = true.obs;

  @override
  void onClose() {
    // TODO: implement onClose
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool signIn(){
    if(emailController.text.isEmpty || passwordController.text.isEmpty) return false;
    else{
      //connect to supabase
      return true;
    }
  }

}