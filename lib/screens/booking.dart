import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/store.dart';

const kSlotTimes = ['18:30','19:30','20:30'];
bool allowedDay(DateTime d) => {6,7,2,3,4}.contains(d.weekday);

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override State<BookingScreen> createState()=> _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = _today();
  String? _selectedTime;
  String _visitType = 'كشف جديد';
  final _name = TextEditingController();
  final _phone = TextEditingController();

  static DateTime _today(){ final n=DateTime.now(); return DateTime(n.year,n.month,n.day); }

  @override void initState(){ super.initState(); _selectedDate = _nextAllowed(_today()); }

  DateTime _nextAllowed(DateTime from){
    var d = from;
    if (d.isBefore(_today())) d = _today();
    while(!allowedDay(d)) { d = d.add(const Duration(days: 1)); }
    return DateTime(d.year, d.month, d.day);
  }

  String _slotId(DateTime d, String t){
    final date = DateFormat('yyyyMMdd').format(d);
    final time = t.replaceAll(':','');
    return '${date}_$time';
  }

  void _goPrevDay(){
    var prev = _selectedDate.subtract(const Duration(days: 1));
    if (prev.isBefore(_today())) { prev = _today(); }
    setState(()=> _selectedDate = _nextAllowed(prev));
  }
  void _goNextDay(){ setState(()=> _selectedDate = _nextAllowed(_selectedDate.add(const Duration(days: 1)))); }

  Color _colorForSlot(String t){
    switch(t){
      case '18:30': return const Color(0xFF0EA5A6); // تركواز
      case '19:30': return const Color(0xFF8E0D2A); // نبيتي
      case '20:30': return const Color(0xFF0D47A1); // أزرق
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context){
    final df = DateFormat('EEEE d MMMM','ar_EG');
    return Scaffold(
      appBar: AppBar(title: const Text('حجز المواعيد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('اختر اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              FilledButton.tonal(onPressed: _goPrevDay, child: const Text('اليوم السابق')),
              const SizedBox(width: 8),
              Text(df.format(_selectedDate), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              FilledButton.tonal(onPressed: _goNextDay, child: const Text('اليوم التالي')),
            ]),
            const SizedBox(height: 16),
            const Text('اختر الوقت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 10, children: kSlotTimes.map((t){
              final sid = _slotId(_selectedDate, t);
              final remaining = bookingStore.remainingFor(sid);
              final full = remaining <= 0;
              final selected = (t == _selectedTime);
              return SizedBox(
                width: 120, height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: full ? Colors.grey : (selected ? _colorForSlot(t).withOpacity(0.85) : _colorForSlot(t)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: full ? null : (){ setState(()=> _selectedTime = t); },
                  child: Text(
                    full ? '$t (مكتمل)' : '$t (متاح: $remaining/3)',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
            const Text('نوع الزيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _visitType,
              items: ['كشف جديد','إعادة','جلسة','استشارة'].map((e)=> DropdownMenuItem(value:e, child: Text(e))).toList(),
              onChanged: (v)=> setState(()=> _visitType = v!),
            ),
            const SizedBox(height: 16),
            const Text('البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'الاسم')),
            const SizedBox(height: 8),
            Directionality(textDirection: TextDirection.ltr,
              child: TextField(controller: _phone, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Phone (+02...)')),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 56,
              child: FilledButton(
                onPressed: (_selectedTime==null || _name.text.trim().isEmpty || _phone.text.trim().isEmpty)
                  ? null
                  : (){
                      final b = Booking(
                        date: _selectedDate, time: _selectedTime!, type: _visitType,
                        name: _name.text.trim(), phone: _phone.text.trim(),
                      );
                      bookingStore.addBooking(b);
                      showDialog(context: context, builder: (_)=> AlertDialog(
                        title: const Text('تم حجز موعدك بنجاح'),
                        content: Text('التاريخ: ${DateFormat('y/M/d','ar_EG').format(_selectedDate)}\nالوقت: ${_selectedTime}\nالخدمة: $_visitType'),
                        actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إغلاق'))],
                      ));
                    },
                child: const Text('تأكيد الحجز'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
