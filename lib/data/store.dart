import 'package:flutter/material.dart';

class Booking {
  Booking({
    required this.date,
    required this.time,
    required this.type,
    required this.name,
    required this.phone,
    this.status = 'محجوز',
  });

  final DateTime date;
  final String time;
  final String type;
  final String name;
  final String phone;
  String status;
}

class NotificationItem {
  NotificationItem({required this.message, required this.when});
  final String message;
  final DateTime when;
}

class BookingStore extends ChangeNotifier {
  final List<Booking> _bookings = [];
  final List<NotificationItem> _notifications = [];
  final Map<String,int> _capacity = {}; // slotId -> count

  List<Booking> bookingsForDay(DateTime day){
    return _bookings.where((b) =>
      b.date.year==day.year && b.date.month==day.month && b.date.day==day.day
    ).toList();
  }

  int remainingFor(String slotId){
    final booked = _capacity[slotId] ?? 0;
    return 3 - booked;
  }

  void addBooking(Booking b){
    _bookings.add(b);
    final id = _slotId(b.date, b.time);
    _capacity[id] = (_capacity[id] ?? 0) + 1;
    notifyListeners();
  }

  void cancelBooking(Booking b){
    _bookings.remove(b);
    final id = _slotId(b.date, b.time);
    final c = (_capacity[id] ?? 1) - 1;
    _capacity[id] = c < 0 ? 0 : c;
    notifyListeners();
  }

  void confirmBooking(Booking b){
    b.status = 'مؤكد';
    notifyListeners();
  }

  void sendNotification(String msg){
    _notifications.add(NotificationItem(message: msg, when: DateTime.now()));
    notifyListeners();
  }

  List<NotificationItem> get sentNotifications => List.unmodifiable(_notifications);

  String _slotId(DateTime d, String t){
    final date = '${d.year.toString().padLeft(4,'0')}${d.month.toString().padLeft(2,'0')}${d.day.toString().padLeft(2,'0')}';
    final time = t.replaceAll(':','');
    return '${date}_$time';
  }
}

final bookingStore = BookingStore();
