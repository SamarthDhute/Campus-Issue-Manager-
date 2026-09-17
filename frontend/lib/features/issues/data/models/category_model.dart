class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final bool active;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.active = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
    };
  }
}
