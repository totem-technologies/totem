export 'app_links_unsupported.dart'
    if (dart.library.html) 'app_links_web.dart'
    if (dart.library.io) 'app_links_device.dart';
