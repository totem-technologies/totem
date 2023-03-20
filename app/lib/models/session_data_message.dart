import 'package:totem/models/date_name_ext.dart';
import 'package:totem/services/communication_provider.dart';

class SessionDataMessage {
  static const int defaultDuration = 5000; // in milliseconds

  late final DateTime sent;
  late final CommunicationMessageType type;
  late final dynamic data;
  late final String from;
  late final int? expiration; // in milliseconds

  SessionDataMessage({
    required this.sent,
    required this.type,
    required this.from,
    this.data,
    this.expiration = defaultDuration,
  });

  bool get expired {
    if (expiration != null) {
      return DateTime.now().difference(sent).inMilliseconds > expiration!;
    }
    return true;
  }

  SessionDataMessage.fromJson(Map<String, dynamic> json) {
    sent = DateTimeEx.fromMapValue(json['sent']) ?? DateTime.now();
    from = json['from'] ?? '';
    if (json['type'] != null) {
      try {
        type = CommunicationMessageType.values.byName(json['type']);
      } catch (e) {
        type = CommunicationMessageType.unknown;
      }
    } else {
      type = CommunicationMessageType.unknown;
    }
    data = json['data'];
    expiration = json['expiration'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataVal = {
      'sent': sent,
      'type': type.name,
      'from': from,
    };
    if (expiration != null) {
      dataVal['expiration'] = expiration;
    }
    if (data != null) {
      dataVal['data'] = data;
    }
    return dataVal;
  }
}
