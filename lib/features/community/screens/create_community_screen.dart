import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/core/common/loader.dart';
import 'package:reddit_tutorial/features/community/controller/community_controller.dart';

// TextFormField 위젯을 사용할 경우 컨트를러의 dispose 작업을 해야하므로
// ConsumerStatefulWidget 타입을 상속하도록 한다.
// StatefulWidget 타입이 context 값을 아무데서나 사용할 수 있는 것처럼
// ConsumerStatefulWidget 타입은 ref 키워드를 선언하지 않아도 아무데서나 사용할 수 있다.

// 스크린을 새로 생성하면 페이지 라우팅 방법을 정의해주도록 한다.
class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final TextEditingController communityNameController = TextEditingController();

  @override
  void dispose() {
    communityNameController.dispose();
    super.dispose();
  }

  void createCommunity() {
    // text.trim() : 문자열 뒷부분에 불필요한 띄어쓰기 부분을 알아서 제거
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a community'),
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Community name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: communityNameController,
                    decoration: const InputDecoration(
                      hintText: 'r/Community_name',
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18.0),
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    // 버튼이 눌리면 파이어베이스를 호출해서 커뮤니티에 대한 데이터베이스를 생성하도록 한다.
                    onPressed: createCommunity,
                    // style 안에서 minimumSize 파라미터에 버튼의 사이즈를 정의하도록 한다.
                    // 박스의 모서리를 둥글게 만드는 것도 styleFrom 안에 shape 파라미터에 지정해준다.
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Create Community',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
