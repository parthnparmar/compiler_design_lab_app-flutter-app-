/// Simple in-memory session — stores logged-in user data.
/// Replace with shared_preferences for persistence across app restarts.
class AuthSession {
  static Map<String, dynamic>? _user;

  static bool get isLoggedIn => _user != null;
  static Map<String, dynamic>? get user => _user;
  static String get username  => _user?['username']  ?? '';
  static String get firstname => _user?['firstname'] ?? '';
  static String get lastname  => _user?['lastname']  ?? '';
  static String get email     => _user?['email']     ?? '';

  static void login(Map<String, dynamic> userData) => _user = userData;
  static void logout() => _user = null;
}
