class SystemVideo {
  int videoSize = 500;
  int frameRate = 24;
  int bitRate = 500;
  int lowResSize = 360;
  int lowResFrameRate = 24;
  int lowResBitRate = 300;
  SystemVideo();

  SystemVideo.fromJson(Map<String, dynamic> json) {
    videoSize = json['videoSize'] as int? ?? videoSize;
    frameRate = json['frameRate'] as int? ?? frameRate;
    bitRate = json['bitRate'] as int? ?? bitRate;
    lowResSize = json['lowResSize'] as int? ?? lowResSize;
    lowResFrameRate = json['lowResFrameRate'] as int? ?? lowResFrameRate;
    lowResBitRate = json['lowResBitRate'] as int? ?? lowResBitRate;
  }

  Map<String, dynamic> toJson() {
    return {
      'videoSize': videoSize,
      'frameRate': frameRate,
      'bitRate': bitRate,
      'lowResSize': lowResSize,
      'lowResFrameRate': lowResFrameRate,
      'lowResBitRate': lowResBitRate,
    };
  }
}
