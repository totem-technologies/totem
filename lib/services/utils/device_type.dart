export 'device_type_unsupported.dart'
    if (dart.library.html) 'device_type_web.dart'
    if (dart.library.io) 'device_type_device.dart';
