import 'package:totem/models/date_name_ext.dart';
import 'package:totem/services/communication_provider.dart';

class SessionDataMessage {
  late final DateTime sent;
  late final CommunicationMessageType type;
  late final dynamic data;
  late final String from;

  SessionDataMessage({
    required this.sent,
    required this.type,
    required this.from,
    this.data,
  });

  SessionDataMessage.fromJson(Map<String, dynamic> json) {
    sent = DateTimeEx.fromMapValue(json['sent']) ?? DateTime.now();
    from = json['from'] ?? '';
    if (json['type'] != null) {
      type = CommunicationMessageType.values.byName(json['type']);
    } else {
      type = CommunicationMessageType.unknown;
    }
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataVal = {
      'sent': sent,
      'type': type.name,
      'from': from,
    };
    if (data != null) {
      dataVal['data'] = data;
    }
    return dataVal;
  }
}
