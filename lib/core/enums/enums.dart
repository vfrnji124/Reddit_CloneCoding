// 테마 모드 정의
enum ThemeMode {
  light,
  dark,
}

// 카르마 포인트를 받는 유저의 활동과 활동에 따른 각 점수를 매칭해서 정의
// enum 타입은 타입안에 변수를 정의할 수 있으며, 변수의 값은 밸류의 뒤에 괄호 안에 값을 넘겨줄 수 있다.
enum UserKarma {
  comment(1),
  textPost(2),
  linkPost(3),
  imagePost(3),
  awardPost(5),
  deletePost(-1);

  final int karma;
  const UserKarma(this.karma);
}
