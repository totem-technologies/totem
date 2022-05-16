enum CommunicationDeviceType {
  camera,
  microphone,
  speakers,
}

class CommunicationDevice {
  final String name;
  final dynamic id;
  final CommunicationDeviceType type;

  CommunicationDevice(
      {required this.name, required this.id, required this.type});
}
