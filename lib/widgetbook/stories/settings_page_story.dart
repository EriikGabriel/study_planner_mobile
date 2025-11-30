import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_planner/pages/settings_page.dart';
import 'package:study_planner/providers/user_provider.dart';
import 'package:widgetbook/widgetbook.dart';

// Mock User for Widgetbook
class MockUser implements User {
  @override
  String? get email => 'usuario@exemplo.com';

  @override
  String? get displayName => 'Usuário Teste';

  @override
  String get uid => 'mock-uid-123';

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => throw UnimplementedError();

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  @override
  Future<void> delete() => throw UnimplementedError();

  @override
  Future<String> getIdToken([bool forceRefresh = false]) =>
      throw UnimplementedError();

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) =>
      throw UnimplementedError();

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      throw UnimplementedError();

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<void> linkWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) => throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<void> reload() => Future.value();

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) => throw UnimplementedError();

  @override
  Future<User> unlink(String providerId) => throw UnimplementedError();

  @override
  Future<void> updateEmail(String newEmail) => throw UnimplementedError();

  @override
  Future<void> updatePassword(String newPassword) => throw UnimplementedError();

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) =>
      throw UnimplementedError();

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) =>
      Future.value();

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) => throw UnimplementedError();

  @override
  MultiFactor get multiFactor => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) {
    // TODO: implement linkWithProvider
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) {
    // TODO: implement reauthenticateWithProvider
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String? displayName) {
    // TODO: implement updateDisplayName
    throw UnimplementedError();
  }

  @override
  Future<void> updatePhotoURL(String? photoURL) {
    // TODO: implement updatePhotoURL
    throw UnimplementedError();
  }

  // Add any other members required by the User interface
}

final settingsPageStory = WidgetbookComponent(
  name: 'Settings Page',
  useCases: [
    WidgetbookUseCase(
      name: 'Com Usuário Logado',
      builder: (context) {
        return ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref) => UserNotifier()..setUser(MockUser()),
            ),
          ],
          child: const SettingsPage(),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Sem Usuário (Logout)',
      builder: (context) {
        return ProviderScope(
          overrides: [userProvider.overrideWith((ref) => UserNotifier())],
          child: const SettingsPage(),
        );
      },
    ),
  ],
);
