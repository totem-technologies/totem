import 'package:flutter_device_type/flutter_device_type.dart';

class DeviceType {
  static bool isPhone() {
    return Device.get().isPhone;
  }

  static bool isMobile() {
    // this could be always true, but maybe want to support
    // a desktop platform which would work with this code
    return Device.get().isIos || Device.get().isAndroid;
  }
}
