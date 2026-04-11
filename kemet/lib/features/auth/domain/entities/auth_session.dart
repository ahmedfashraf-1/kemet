class AuthSession {
  const AuthSession({
    required this.id,
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isActive,
    this.deviceToken,
    this.loginAt,
    this.lastActiveAt,
    this.isCurrentSession,
  });

  final String id;
  final String device;
  final String location;
  final DateTime lastActive;
  final bool isActive;
  final String? deviceToken;
  final DateTime? loginAt;
  final DateTime? lastActiveAt;
  final bool? isCurrentSession;
}

