class Favorite {
  final String id;
  //final String userId;
  final String name;
  final String location;
  final String? icon;

  const Favorite({
    required this.id,
    required this.name,
    required this.location,
    this.icon
  });
}
