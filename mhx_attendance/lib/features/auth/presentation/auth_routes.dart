abstract final class AuthRoutes {
  static const login = '/login';
  static const loginEmail = '/login/email';
  static const register = '/register';
  static const locked = '/locked';
  static const unauthorized = '/unauthorized';
  static const homeSuper = '/home/super';
  static const homeLocal = '/home/local';
  static const homeUser = '/home/user';

  static const publicRoutes = {login, loginEmail, register};
}
