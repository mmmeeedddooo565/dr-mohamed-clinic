import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_panel.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override State<AdminLoginScreen> createState()=> _AdminLoginScreenState();
}
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pass = TextEditingController(); final _pass2 = TextEditingController();
  bool _first=false; bool _loading=true;
  @override void initState(){ super.initState(); _init(); }
  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString('admin_password');
    setState((){ _first = (saved==null || saved.isEmpty); _loading=false; });
  }
  Future<void> _set() async {
    if(_pass.text.length<4 || _pass.text!=_pass2.text){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل كلمة مرور صحيحة وتطابق التأكيد (4 أحرف على الأقل)'))); return;
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setString('admin_password', _pass.text);
    if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const AdminPanelScreen()));
  }
  Future<void> _login() async {
    final sp = await SharedPreferences.getInstance(); final saved = sp.getString('admin_password')??'';
    if(_pass.text==saved){ if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const AdminPanelScreen())); }
    else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور غير صحيحة'))); }
  }
  @override Widget build(BuildContext context){
    if(_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(_first? 'إنشاء كلمة مرور مدير' : 'دخول المدير')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if(_first)...[
            const Text('عيّن كلمة مرور المدير لأول مرة:'), const SizedBox(height:12),
            TextField(obscureText:true, decoration: const InputDecoration(border: OutlineInputBorder(), labelText:'كلمة المرور'), controller:_pass),
            const SizedBox(height:12),
            TextField(obscureText:true, decoration: const InputDecoration(border: OutlineInputBorder(), labelText:'تأكيد كلمة المرور'), controller:_pass2),
            const SizedBox(height:16),
            FilledButton(onPressed:_set, child: const Text('حفظ')),
          ] else ...[
            const Text('أدخل كلمة مرور المدير:'), const SizedBox(height:12),
            TextField(obscureText:true, decoration: const InputDecoration(border: OutlineInputBorder(), labelText:'كلمة المرور'), controller:_pass),
            const SizedBox(height:16),
            FilledButton(onPressed:_login, child: const Text('دخول')),
          ],
        ]),
      ),
    );
  }
}
