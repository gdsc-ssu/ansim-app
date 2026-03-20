import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/screens/alarm/alarm_screen.dart';
import 'package:ansim_app/screens/map/map_screen.dart';
import 'package:ansim_app/screens/map/map_view_model.dart';
import 'package:ansim_app/screens/mypage/mypage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: const _NavigationContent(),
    );
  }
}

class _NavigationContent extends StatelessWidget {
  const _NavigationContent();

  static const List<Widget> _screens = [
    MapScreen(),
    AlarmScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return Scaffold(
      // IndexedStack은 화면 전환 시 이전 상태를 보존해줍니다 (지도 위치 등)
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentIndex,
        onTap: (index) => viewModel.changeTab(index),

        selectedItemColor: AnsimColor.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: AnsimTextStyle.buttonB1,
        unselectedLabelStyle: AnsimTextStyle.buttonB1,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/map_off.svg'),
            activeIcon: SvgPicture.asset('assets/icons/map.svg'),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/alarm_off.svg'),
            activeIcon: SvgPicture.asset('assets/icons/alarm.svg'),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/mypage_off.svg'),
            activeIcon: SvgPicture.asset('assets/icons/mypage.svg'),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}