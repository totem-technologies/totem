import 'package:url_launcher/url_launcher.dart';

class DataUrls {
  static const String userFeedback =
      "https://docs.google.com/forms/d/e/1FAIpQLSf8IuQ6UWEW-9_eX9eSmX5x7Kdabjtg5pmuKQx_4Lc-Amkdmg/viewform?usp=sf_link";
  static const String bugReport =
      "https://docs.google.com/forms/d/e/1FAIpQLScYy9jE1T5kgNqx87CPluYH-mBTrS9tBdcJMCX8zZSTPBu7zA/viewform";
  static const String donate = "https://donate.stripe.com/28obM32nf6TF7n2001";
  static const String privacyPolicy = "https://www.totem.org/privacy-policy";
  static const String termsOfService = "https://www.totem.org/tos";
  static const String docs = "https://help.totem.org/";
  static const String appleStore = "https://testflight.apple.com/join/p5k8gSEA";
  static const String androidStore =
      "https://play.google.com/store/apps/details?id=io.kbl.totem";

  static Future<bool> launch(String url) async {
    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}
