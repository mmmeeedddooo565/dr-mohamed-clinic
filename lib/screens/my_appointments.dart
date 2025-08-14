import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});
  @override Widget build(BuildContext context){
    final items = [
      {'date':'2025/08/15','time':'18:30','type':'كشف جديد','status':'محجوز'},
      {'date':'2025/08/17','time':'19:30','type':'جلسة','status':'محجوز'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i){
          final it = items[i];
          return ListTile(
            leading: const Icon(Icons.event_available),
            title: Text('${it['date']} - ${it['time']}'),
            subtitle: Text('${it['type']} — الحالة: ${it['status']}'),
          );
        },
        separatorBuilder: (_, __)=> const Divider(),
        itemCount: items.length,
      ),
    );
  }
}
