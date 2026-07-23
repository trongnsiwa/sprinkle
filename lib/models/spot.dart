class Spot {
  final String id;
  final String name;
  final String? imageUrl;
  final double rating;
  final String friendName;
  final String friendAvatar;

  Spot({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.friendName,
    required this.friendAvatar,
  });
}
