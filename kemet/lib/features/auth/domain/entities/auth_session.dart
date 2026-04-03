class AuthSession {
  const AuthSession({
    required this.id,
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isActive,
  });

  final String id;
  final String device;
  final String location;
  final DateTime lastActive;
  final bool isActive;
}

