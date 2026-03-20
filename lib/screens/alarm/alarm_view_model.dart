import 'package:ansim_app/constansts/colors.dart';
import 'package:flutter/material.dart';

class AlarmItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String timeAgo;
  final String subtitle;
  final String location;
  final bool isUnread;

  const AlarmItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.timeAgo,
    required this.subtitle,
    required this.location,
    required this.isUnread,
  });

  AlarmItem copyWith({bool? isUnread}) => AlarmItem(
        id: id,
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        timeAgo: timeAgo,
        subtitle: subtitle,
        location: location,
        isUnread: isUnread ?? this.isUnread,
      );
}

class AlarmViewModel extends ChangeNotifier {
  bool isLoading = false;

  List<AlarmItem> _items = [];

  List<AlarmItem> get items => _items;

  int get unreadCount => _items.where((e) => e.isUnread).length;

  void markAsRead(String id) {
    _items = _items.map((e) => e.id == id ? e.copyWith(isUnread: false) : e).toList();
    notifyListeners();
  }

  void markAllAsRead() {
    _items = _items.map((e) => e.copyWith(isUnread: false)).toList();
    notifyListeners();
  }

  String _nowLabel() {
    final t = DateTime.now().toUtc().add(const Duration(hours: 9)); // KST
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void addEmergencyAlarm({required String markerId, required String hazardTypeLabel}) {
    final now = _nowLabel();
    final item = AlarmItem(
      id: 'emergency_$markerId',
      icon: Icons.warning_rounded,
      iconColor: AnsimColor.critical,
      iconBackgroundColor: const Color(0xFFFFEBEE),
      title: '긴급 위험 알림',
      timeAgo: now,
      subtitle: '$hazardTypeLabel 위험 지점 3m 이내에 있습니다. 즉시 대피하세요.',
      location: '',
      isUnread: true,
    );
    _items = [item, ..._items];
    notifyListeners();
  }

  void addNearbyAlarm({required String markerId, required String hazardTypeLabel}) {
    final now = _nowLabel();
    final item = AlarmItem(
      id: 'nearby_$markerId',
      icon: Icons.location_on_rounded,
      iconColor: AnsimColor.warning,
      iconBackgroundColor: const Color(0xFFFFF3E0),
      title: '주변 위험 감지',
      timeAgo: now,
      subtitle: '$hazardTypeLabel 위험 지점 5m 이내에 있습니다. 주의하세요.',
      location: '',
      isUnread: true,
    );
    _items = [item, ..._items];
    notifyListeners();
  }
}
