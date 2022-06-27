enum AudioFormatType {
  mp3,
}

enum MediaType { audio }

class Media {
  late String name;
  late AudioFormatType format;
  late MediaType type;
  late String url;
  String id;

  Media.fromJSON(Map<String, dynamic> json, {required this.id}) {
    name = json['name'] ?? "unknown";
    format = AudioFormatType.values
        .byName(json['format'] ?? AudioFormatType.mp3.name);
    type = MediaType.values.byName(json['type'] ?? MediaType.audio.name);
    url = json['url'] ?? '';
  }
}
