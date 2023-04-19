class AccountState {
  AccountState();
  Map<String, dynamic> _data = {};

  AccountState.fromJson(Map<String, dynamic> json) {
    _data = json;
  }

  bool boolAttribute(String key) => (_data[key] as bool? ?? false);
}
