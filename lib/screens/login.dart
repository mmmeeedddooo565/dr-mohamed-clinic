import 'package:flutter/material.dart';
import 'otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=> _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('دخول')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 16),
          Image.asset('assets/logo.png', height: 90, errorBuilder: (_, __, ___)=> const SizedBox.shrink()),
          const SizedBox(height: 24),
          const Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Directionality(textDirection: TextDirection.ltr,
            child: TextField(controller: _phone, keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '+02 01xxxxxxxxx')),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> OTPScreen(phone: _phone.text)));
          }, child: const Text('إرسال الكود'))
        ]),
      ),
    );
  }
}
