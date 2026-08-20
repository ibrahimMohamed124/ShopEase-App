class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'http://192.168.8.106:3000';

  /// كل الفيتشرز (auth, catalog, cart, wishlist, reviews) أصلاً بقت live
  /// دايمًا زي ما اتفقنا. الـflag ده لسه مستخدم بس في SearchCubit
  /// (بيحدد لو هيستخدم ApiDataService ولا MockDataService).
  static const bool useApi = true;
}