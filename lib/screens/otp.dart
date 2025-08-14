import 'package:flutter/material.dart';
import '../main.dart';
import 'home.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  const OTPScreen({super.key, required this.phone});
  @override State<OTPScreen> createState()=> _OTPScreenState();
}
class _OTPScreenState extends State<OTPScreen> {
  final _code = TextEditingController();
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('أدخل الكود')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('لقد أرسلنا رمز التحقق إلى رقم هاتفك: ${widget.phone}'),
          const SizedBox(height: 16),
          Directionality(textDirection: TextDirection.ltr,
            child: TextField(controller: _code, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '******')),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: (){
            auth.login();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> const HomeScreen(isLoggedIn: true)), (r)=>false);
          }, child: const Text('تأكيد')),
          const SizedBox(height: 8),
          TextButton(onPressed: (){}, child: const Text('إعادة إرسال الكود')),
        ]),
      ),
    );
  }
}
