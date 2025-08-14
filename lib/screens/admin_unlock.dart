import 'dart:async';
import 'package:flutter/material.dart';
import 'admin_login.dart';

class AdminUnlockLogo extends StatefulWidget {
  final Widget child;
  const AdminUnlockLogo({super.key, required this.child});
  @override State<AdminUnlockLogo> createState()=> _AdminUnlockLogoState();
}
class _AdminUnlockLogoState extends State<AdminUnlockLogo>{
  Timer? _t; bool _down=false; static const _hold=Duration(seconds:5);
  void _start(){ _t?.cancel(); _t = Timer(_hold, (){ if(mounted && _down){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const AdminLoginScreen())); } }); }
  @override void dispose(){ _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext ctx){
    return GestureDetector(
      onLongPressDown: (_){ _down=true; _start(); },
      onLongPressUp: (){ _down=false; _t?.cancel(); },
      onLongPressCancel: (){ _down=false; _t?.cancel(); },
      child: widget.child,
    );
  }
}
