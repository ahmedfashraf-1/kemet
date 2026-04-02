class Review {
  final String id;
  //final String userId;
  //final String landmarkId;
  final String placeName;
  final String date;
  //final String comment;
  final double rating;

  String? placeIcon;
//  final DateTime createdAt;

  Review({
    required this.id,
    required this.placeName,
    required this.date,
    required this.rating,
    
  });
}
