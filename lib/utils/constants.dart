class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  
  // ============ AUTH ENDPOINTS ============
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  
  // ============ PROFILE ENDPOINTS ============
  static const String profile = '/profile';
  static const String deviceTokens = '/device-tokens';
  
  // ============ REPORT ENDPOINTS ============
  static const String reportsWeekly = '/reports/weekly';
  
  // ============ MOOD CHECKIN ENDPOINTS ============
  static const String pemicu = '/pemicu';
  static const String checkin = '/checkin';
  static const String dashboard = '/dashboard';
  
  // ============ PREMIUM ENDPOINTS ============
  static const String premiumStatus = '/premium/status';
  static const String premiumPlans = '/premium/plans';
  static const String premiumSubscribe = '/premium/subscribe';
  static const String premiumCancel = '/premium/cancel';
  
  // ============ FRIENDSHIP ENDPOINTS ============
  static const String friends = '/friends';
  static const String friendsAdd = '/friends/add';
  static const String friendsSearch = '/friends/search';
  
  // ============ CONTENT ENDPOINTS ============
  static const String konten = '/konten';
  
  // ============ SETTINGS ENDPOINTS ============
  static const String settings = '/settings';
  static const String settingsNotification = '/settings/notification';
  static const String settingsPrivacy = '/settings/privacy';
  
  // ============ CHAT ENDPOINTS ============
  static const String chat = '/chat';
  static const String chatSend = '/chat/send';
  static const String chatUnreadCount = '/chat/unread/count';
  static const String chatUnreadList = '/chat/unread/list';
  static const String chatRead = '/chat/read';
  
  // ============ PAYMENT ENDPOINTS ============
  static const String paymentPlans = '/payment/plans';
  static const String paymentCreate = '/payment/create';
  static const String paymentStatus = '/payment/status';
  static const String paymentSimulate = '/payment/simulate';
  static const String paymentCancel = '/payment/cancel';
  static const String paymentHistory = '/payment/history';
  
  // ============ TIMEOUTS ============
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}