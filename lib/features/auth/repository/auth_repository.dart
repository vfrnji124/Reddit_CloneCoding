import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_tutorial/core/constants/constants.dart';
import 'package:reddit_tutorial/core/constants/firebase_constants.dart';
import 'package:reddit_tutorial/core/failure.dart';
import 'package:reddit_tutorial/core/providers/firebase_providers.dart';
import 'package:reddit_tutorial/core/type_defs.dart';
import 'package:reddit_tutorial/models/user_model.dart';


// authControllerProvider에 authRepository를 제공하기 위한 Provider
final authRepositoryProvider = Provider(
      (ref) =>
      AuthRepository(
        firestore: ref.read(firestoreProvider),
        firebaseAuth: ref.read(authProvider),
        googleSignIn: ref.read(googleSignInProvider),
      ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // private variable 의 초기화는 생성자를 사용할 수 없다.
  // 생성자에서 public variable 을 정의하고, 이를 private variable 로 넘겨준다.
  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })
      : _firestore = firestore,
        _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  // firestore 안에서 user data path
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  // 로그인, 로그아웃 등의 로그인 상태 변화에 대한 값을 listening, 값을 반환
  Stream<User?> get authStatChange => _firebaseAuth.authStateChanges();


  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      // 구글 계정으로 로그인하는 방법
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential;
      if (isFromLogin) {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } else {
        userCredential =
        await _firebaseAuth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      // 구글 계정으로 처음 로그인한 유저인 경우만 UserModel을 새로 생성
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'No Name',
            profilePic:
            userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: [
              'til',
            ]);
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else{
        // 신규 유저가 아니면 userCredential 정보를 통해 기존 유저 정보를 찾아서 userModel을 반환한다.
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  // User id를 이용해서 FireStore에 저장된 유저 정보를 가져와 UserModel을 반환하는 함수
  Stream<UserModel> getUserData(String uid) {
    // snapshots로 반환하면 Stream을 반환한다.
    // Stream은 이터러블처럼 map 메소드로 반환하게 될 값들에 대해 mapping이 가능하다.
    // 가져온 정보를 UserModel 타입으로 반환한다.
    return _users.doc(uid).snapshots().map(
            (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      // 게스트로 로그인할 경우 Firebase의 아래 로그인 기능을 이용한다.
      var userCredential = await _firebaseAuth.signInAnonymously();
      UserModel userModel = UserModel(
          name: 'Guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: false,
          karma: 0,
          awards: []);
      // Firestore에 uid를 이름으로 하는 doc에 유저 정보를 저장
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
