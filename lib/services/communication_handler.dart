import 'package:flutter/cupertino.dart';

typedef JoinedCircleCallback = void Function(
    String sessionId, String sessinUserId);

class CommunicationHandler {
  CommunicationHandler({this.joinedCircle, this.leaveCircle});
  JoinedCircleCallback? joinedCircle;
  VoidCallback? leaveCircle;
}
