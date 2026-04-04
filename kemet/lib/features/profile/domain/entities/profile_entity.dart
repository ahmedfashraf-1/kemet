class ProfileEntity {
  final String id;
  final String fullName;   // Firebase field: fullName
  final String email;      // Firebase field: email
  final String createdAt;  // Firebase field: createdAt (string)
  final int tripsCount;    
  final int savedCount;    
  final int reviewsCount;  
  final String? avatarUrl;


  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.tripsCount,
    required this.savedCount,
    required this.reviewsCount,
    this.avatarUrl,
  });
}