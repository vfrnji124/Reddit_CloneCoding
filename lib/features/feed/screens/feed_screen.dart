import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/core/common/error_text.dart';
import 'package:reddit_tutorial/core/common/loader.dart';
import 'package:reddit_tutorial/core/common/post_card.dart';
import 'package:reddit_tutorial/features/auth/controller/auth_controller.dart';
import 'package:reddit_tutorial/features/community/controller/community_controller.dart';
import 'package:reddit_tutorial/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    if(!isGuest) {
      // 유저가 참여한 커뮤니티 state를 먼저 fetch
    return ref.watch(userCommunitiesProvider).when(
        data: (communities) {
          // 각 커뮤니티에 포함된 post를 fetch해서 ListView로 rendering
          return ref.watch(userPostsProvider(communities)).when(
              data: (data) {
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final post = data[index];
                      return PostCard(post: post);
                    });
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader());
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
    } else{
      return ref.watch(userCommunitiesProvider).when(
          data: (communities) {
            // 각 커뮤니티에 포함된 post를 fetch해서 ListView로 rendering
            return ref.watch(guestPostsProvider).when(
                data: (data) {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = data[index];
                        return PostCard(post: post);
                      });
                },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader());
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader());
    }
  }
}
