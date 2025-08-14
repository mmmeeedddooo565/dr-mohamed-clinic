import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<int> allowedWeekdays = [
  DateTime.saturday,
  DateTime.sunday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday
];

const List<String> slotTimes = ['18:30', '19:30', '20:30'];
const int capacityPerSlot = 3;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String _visitType = 'كشف';
  bool _dayClosed = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      setState(() => _dayClosed = sp.getBool('day_closed') ?? false);
    });
  }

  bool _isAllowedDay(DateTime d) => allowedWeekdays.contains(d.weekday);

  bool _isPastDay(DateTime d) {
    final today = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  Future<int> _currentCountFor(DateTime d, String t) async {
    final sp = await SharedPreferences.getInstance();
    final key = 'count_${DateFormat('yyyyMMdd').format(d)}_$t';
    return sp.getInt(key) ?? 0;
  }

  Future<void> _incrementCount(DateTime d, String t) async {
    final sp = await SharedPreferences.getInstance();
    final key = 'count_${DateFormat('yyyyMMdd').format(d)}_$t';
    final c = sp.getInt(key) ?? 0;
    await sp.setInt(key, c + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز موعد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اختر اليوم', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13a6b3),
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: now.add(const Duration(days: 60)),
                    initialDate: now,
                    selectableDayPredicate: (d) => _isAllowedDay(d) && !_isPastDay(d),
                    locale: const Locale('ar', 'EG'),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Text(
                  _selectedDate == null
                      ? 'اختر التاريخ'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(height: 12),
              const Text('اختيار الميعاد',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: slotTimes.map((t) {
                  final isSel = t == _selectedTime;
                  return ChoiceChip(
                    label: Text(t, textDirection: TextDirection.ltr),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedTime = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('نوع الزيارة',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: _visitType,
                items: const ['كشف', 'إعادة', 'جلسة', 'استشارة']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _visitType = v ?? 'كشف'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFF8E0D2A),
                ),
                onPressed:
                    (_selectedDate == null || _selectedTime == null)
                        ? null
                        : () async {
                            if (_dayClosed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('الحجز مغلق اليوم')),
                              );
                              return;
                            }
                            final c = await _currentCountFor(
                                _selectedDate!, _selectedTime!);
                            if (c >= capacityPerSlot) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('الموعد ممتلئ، اختر ميعادًا آخر')),
                              );
                              return;
                            }
                            await _incrementCount(
                                _selectedDate!, _selectedTime!);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تأكيد الحجز')),
                            );
                            Navigator.pop(context);
                          },
                child: const Text('تأكيد الحجز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
