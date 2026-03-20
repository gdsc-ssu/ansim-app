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

  List<AlarmItem> _items = const [
    AlarmItem(
      id: '1',
      icon: Icons.warning_rounded,
      iconColor: AnsimColor.critical,
      iconBackgroundColor: Color(0xFFFFEBEE),
      title: '긴급 위험 알림',
      timeAgo: '방금',
      subtitle: '내 위치 300m 이내에 싱크홀이 보고되었습니다.',
      location: '강동구 천호대로 42길',
      isUnread: true,
    ),
    AlarmItem(
      id: '2',
      icon: Icons.location_on_rounded,
      iconColor: AnsimColor.warning,
      iconBackgroundColor: Color(0xFFFFF3E0),
      title: '주변 위험 감지',
      timeAgo: '10분 전',
      subtitle: '내 경로 근처에 도로 파손이 신고되었어요.',
      location: '강남구 역삼동',
      isUnread: false,
    ),
    AlarmItem(
      id: '3',
      icon: Icons.check_circle_rounded,
      iconColor: AnsimColor.resolved,
      iconBackgroundColor: Color(0xFFF1F8E9),
      title: '처리 완료',
      timeAgo: '2시간 전',
      subtitle: '역삼동 도로 파손 신고가 처리 완료되었습니다.',
      location: '강남구 역삼동',
      isUnread: false,
    ),
    AlarmItem(
      id: '4',
      icon: Icons.location_on_rounded,
      iconColor: AnsimColor.textHint,
      iconBackgroundColor: AnsimColor.bgSecondary,
      title: '주변 위험 감지',
      timeAgo: '어제',
      subtitle: '송파구 삼실동에서 시설물 위험이 감지되었어요.',
      location: '송파구 삼실동',
      isUnread: false,
    ),
  ];

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
}
