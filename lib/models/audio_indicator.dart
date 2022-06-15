class CommunicationAudioVolumeInfo {
  final int uid;
  final int volume;
  final bool speaking;

  CommunicationAudioVolumeInfo({
    required this.uid,
    required this.volume,
    required this.speaking,
  });

  bool get local => uid == 0;
}

class CommunicationAudioVolumeIndication {
  final int totalVolume;
  final List<CommunicationAudioVolumeInfo> speakers;

  CommunicationAudioVolumeIndication(
      {required this.totalVolume, required this.speakers});

  // Get a speaker's info by uid. Pass paritipant.me the me parameter.
  CommunicationAudioVolumeInfo? getSpeaker(String? uid, bool me) {
    if (uid == null) {
      return null;
    }
    for (var speaker in speakers) {
      if (speaker.uid.toString() == uid) {
        return speaker;
      }
      if (me && speaker.uid == 0) {
        return speaker;
      }
    }
    return null;
  }
}
