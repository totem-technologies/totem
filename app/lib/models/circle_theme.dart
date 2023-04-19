class CircleTheme {
  late final String ref;
  late final String name;
  late final String description;
  late final String image;
  late final String bannerImage;

  CircleTheme.fromJson(final Map<String, dynamic> data, {required this.ref}) {
    assert(data['name'] != null);
    name = data['name'];
    description = data['description'] ?? "";
    image = data['image'] ?? "";
    bannerImage = data['bannerImage'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'bannerImage': bannerImage,
    };
  }
}
