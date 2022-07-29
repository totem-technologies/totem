class AccountState {
  static const String onboarded = 'onboarded';
  AccountState();
  Map<String, dynamic> _data = {};

  AccountState.fromJson(Map<String, dynamic> json) {
    _data = json;
  }

  bool boolAttribute(String key) => (_data[key] as bool? ?? false);
  bool get valid {
    return (_data[onboarded] ?? false) &&
        (_data['signUpComplete'] ?? false) &&
        (_data['tosAccepted'] ?? false);
  }
}
