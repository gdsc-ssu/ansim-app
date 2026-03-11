import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/screens/map/map_screen.dart';
import 'package:ansim_app/screens/map/map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  // 각 탭에 들어갈 실제 화면 리스트
  static const List<Widget> _screens = [
    MapScreen(),           // 0번: 지도
    Center(child: Text('알림 화면')), // 1번: 알림 (추후 제작)
    Center(child: Text('마이페이지')), // 2번: 프로필 (추후 제작)
  ];

  @override
  Widget build(BuildContext context) {
    // ViewModel의 상태를 구독하여 현재 인덱스를 가져옴
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
        selectedLabelStyle: AnsimTextStyle.buttonB3,
        unselectedLabelStyle: AnsimTextStyle.buttonB3,
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