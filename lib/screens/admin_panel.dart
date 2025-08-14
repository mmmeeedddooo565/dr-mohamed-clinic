import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/store.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override State<AdminPanelScreen> createState()=> _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  DateTime _day = _today();
  static DateTime _today(){ final n=DateTime.now(); return DateTime(n.year,n.month,n.day); }

  @override void initState(){ super.initState(); _tab=TabController(length:3, vsync:this); }

  @override Widget build(BuildContext context){
    final df = DateFormat('y/M/d','ar_EG');
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة إدارة العيادة'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [ Tab(text:'الحجوزات'), Tab(text:'الإشعارات'), Tab(text:'الإعدادات') ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // الحجوزات
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children:[
                FilledButton.tonal(onPressed: (){ setState(()=> _day=_day.subtract(const Duration(days:1))); }, child: const Text('اليوم السابق')),
                const SizedBox(width:8),
                Text(df.format(_day)),
                const SizedBox(width:8),
                FilledButton.tonal(onPressed: (){ setState(()=> _day=_day.add(const Duration(days:1))); }, child: const Text('اليوم التالي')),
              ]),
              const SizedBox(height:12),
              Expanded(child: AnimatedBuilder(
                animation: bookingStore,
                builder: (_, __){
                  final items = bookingStore.bookingsForDay(_day);
                  if(items.isEmpty) return const Center(child: Text('لا توجد حجوزات لهذا اليوم'));
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __)=> const Divider(),
                    itemBuilder: (_, i){
                      final b = items[i];
                      return ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text('${b.time} — ${b.type} — ${b.status}'),
                        subtitle: Text('المريض: ${b.name} — ${b.phone}'),
                        trailing: Wrap(spacing:8, children: [
                          TextButton(onPressed: (){ bookingStore.confirmBooking(b); }, child: const Text('تأكيد')),
                          TextButton(onPressed: (){ bookingStore.cancelBooking(b); }, child: const Text('إلغاء')),
                        ]),
                      );
                    },
                  );
                },
              ))
            ]),
          ),
          // الإشعارات
          _NotificationsTab(),
          // الإعدادات
          _SettingsTab(),
        ],
      ),
    );
  }
}

class _NotificationsTab extends StatefulWidget {
  @override State<_NotificationsTab> createState()=> _NotificationsTabState();
}
class _NotificationsTabState extends State<_NotificationsTab> {
  final _msg = TextEditingController();
  @override Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('إرسال إشعار للمستخدمين'), const SizedBox(height:8),
        TextField(controller: _msg, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'نص الإشعار')),
        const SizedBox(height: 8),
        FilledButton(onPressed: (){
          if(_msg.text.trim().isEmpty) return;
          bookingStore.sendNotification(_msg.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإشعار (تجريبي).')));
          _msg.clear();
        }, child: const Text('إرسال')),
        const SizedBox(height: 16),
        const Text('السجل:'),
        const SizedBox(height: 8),
        Expanded(child: AnimatedBuilder(
          animation: bookingStore,
          builder: (_, __){
            final items = bookingStore.sentNotifications.reversed.toList();
            if(items.isEmpty) return const Center(child: Text('لا توجد إشعارات بعد'));
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __)=> const Divider(),
              itemBuilder: (_, i){
                final n = items[i];
                return ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: Text(n.message),
                  subtitle: Text(DateFormat('y/M/d HH:mm','ar_EG').format(n.when)),
                );
              },
            );
          },
        ))
      ]),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({super.key});
  @override Widget build(BuildContext context){
    return const Center(child: Text('إعدادات إضافية ستضاف لاحقًا (مثل إغلاق اليوم، ضبط السعة، إلخ).'));
  }
}
