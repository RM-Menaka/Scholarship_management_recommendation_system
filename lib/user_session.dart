class UserSession {
  static int? userId;
  static String? role;

  static void setUser(int id, String userRole) {
    userId = id;
    role = userRole;
  }

  static void clear() {
    userId = null;
    role = null;
  }
}