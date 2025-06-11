class Category {
  final String id;
  final String name;
  final String description;
  final String logo;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? "",
      description: data['description'] ?? "",
      logo: data['logo'] ?? "",
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  Category copyWith(String? name, String? description, String? logo) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      createdAt: createdAt,
    );
  }
}
