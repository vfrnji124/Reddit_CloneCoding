import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/core/common/error_text.dart';
import 'package:reddit_tutorial/core/common/loader.dart';
import 'package:reddit_tutorial/core/common/sign_in_button.dart';
import 'package:reddit_tutorial/features/auth/controller/auth_controller.dart';
import 'package:reddit_tutorial/features/community/controller/community_controller.dart';
import 'package:reddit_tutorial/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({
    Key? key,
  }) : super(key: key);

  // 버튼을 눌렀을 때 CreateCommunityScreen 스크린으로 이동을 실행하는 함수
  // UI / Logic 둘을 서로 구분하기 위해 라우팅 관련 함수를 별도로 작업하는 게 좋다.
  void navigateToCreateCommunity(BuildContext context) {
    // Routemaster 기능을 이용한 페이지 이동 방법
    // push 인자로 router 안에서 스크린과 매칭한 라우팅 이름을 넣어준다.
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignInButton()
                : ListTile(
                    title: const Text('Create a community'),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            if (!isGuest)
              // Future 또는 Stream 타입을 리턴하는 프로바이더의 상태를 사용할 때는 when 메소드를 사용한다.
              ref.watch(userCommunitiesProvider).when(
                  data: (communities) => Expanded(
                        // ListView는 Column이나 Row안에 쓰일 때 사이즈를 지정해줘야 한다.
                        child: ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final community = communities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              // r/를 앞에 붙이면 레딧에서 리스트스타일로 표시된다.
                              title: Text('r/${community.name}'),
                              onTap: () {
                                navigateToCommunity(context, community);
                              },
                            );
                          },
                        ),
                      ),
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader()),
          ],
        ),
      ),
    );
  }
}
