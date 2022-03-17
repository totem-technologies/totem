enum AppLinkType {
  snapSession,
}

class AppLink {
  String value;
  AppLinkType type;

  AppLink({required this.type, required this.value});
}
