class Race {
  Race({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    required this.date,
    required this.distance,
    required this.images,
  });

  String id;
  String name;
  String? description;
  String location;
  DateTime date;
  double distance;
  List<String> images;

  Race copyWith({
    String? id,
    String? name,
    String? location,
    DateTime? date,
    double? distance,
    List<String>? images,
    String? description,
  }) {
    return Race(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      date: date ?? this.date,
      distance: distance ?? this.distance,
      images: images ?? this.images,
      description: description ?? this.description,
    );
  }
}