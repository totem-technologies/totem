import 'package:universal_html/html.dart' as html;

class DeviceType {
  static String? _userAgent;
  static bool? _isPhone;
  static bool? _isMobile;

  static bool isPhone() {
    _isPhone ??= _isPhoneDevice();
    return _isPhone!;
  }

  static bool isMobile() {
    _isMobile ??= _isMobileDevice();
    return _isMobile!;
  }

  static void _assertUserAgent() {
    _userAgent ??= html.window.navigator.userAgent.toString().toLowerCase();
  }

  static bool _isMobileDevice() {
    _assertUserAgent();
    return _userAgent!.contains("iphone") ||
        _userAgent!.contains("android") ||
        _userAgent!.contains("ipad");
  }

  static bool _isPhoneDevice() {
    _assertUserAgent();
    // smartphone
    if (_userAgent!.contains("iphone")) return true;
    if (_userAgent!.contains("android")) {
      // return based on size if this is a mobile browser on android
      int width = html.window.outerWidth;
      int height = html.window.outerHeight;
      // if either dimension is bigger than 1000, treat as non-phone
      return (width < 1000 && height < 1000);
    }
    return false;
  }
}
