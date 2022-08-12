class SystemVideo {
  int videoSize = 500;
  int frameRate = 24;
  int bitRate = 500;
  SystemVideo();

  SystemVideo.fromJson(Map<String, dynamic> json) {
    videoSize = json['videoSize'] as int;
    frameRate = json['frameRate'] as int;
    bitRate = json['bitRate'] as int;
  }

  Map<String, dynamic> toJson() {
    return {
      'videoSize': videoSize,
      'frameRate': frameRate,
      'bitRate': bitRate,
    };
  }
}
