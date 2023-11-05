import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/core/constants/constants.dart';
import 'package:reddit_tutorial/features/auth/controller/auth_controller.dart';
import 'package:reddit_tutorial/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_tutorial/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_tutorial/features/home/drawers/profile_drawer.dart';
import 'package:reddit_tutorial/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    // Scaffold 위젯의 drawer 파라미터에 연결된 위젯을 여는 방법
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    // 오른쪽 끝에서 왼쪽으로 스와이프했을 때 열리는 Drawer
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    // 게스트 여하에 따라 기능을 보여줄지 말지 구분하기 위한 변수
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            // Drawer 위젯을 열 때 Scaffold 위젯의 context 값과 다른 context 값을 전달해야 한다.
            // context 값을 새로 생성하는 방법으로 Builder 위젯을 사용하는 방법이 있다.
            // context 가 뜻하는 내용에 대해 좀 더 깊은 이해가 필요하다.
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchCommunityDelegate(ref: ref));
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
          // CircleAvatar 위젯을 IconButton 위젯으로 감싸주면 크기도 Icon 사이즈로 줄어든다
          Builder(
            builder: (context) {
              return IconButton(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                onPressed: () => displayEndDrawer(context),
              );
            }
          )
        ],
      ),
      // Scaffold 위젯의 drawer 파라미터에 Drawer 위젯을 연결하면
      // 화면 왼쪽 끝에서 오른쪽으로 스와이프 할 때 Drawer 위젯을 열 수 있다.
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      body: Constants.tabWidgets[_page],
      bottomNavigationBar: isGuest
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.backgroundColor,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
              ],
              onTap: onPageChanged,
              currentIndex: _page,
            ),
    );
  }
}
