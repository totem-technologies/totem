enum _Roles { keeper, member }

class Roles {
  Roles._();
  static const Role keeper = Role(_Roles.keeper);
  static const Role member = Role(_Roles.member);
}

class Role {
  final _Roles r;
  const Role(this.r);

  @override
  String toString() {
    return r.toString().split('.').last.toUpperCase();
  }

  @override
  bool operator ==(other) {
    if (other is! Role) {
      return false;
    }
    return r == other.r;
  }

  static Role fromString(String? role) {
    _Roles roleVal;
    try {
      roleVal = _Roles.values.firstWhere((element) =>
          element.toString().split('.').last.toUpperCase() == role);
    } catch (ex) {
      roleVal = _Roles.member;
    }
    return Role(roleVal);
  }

  @override
  int get hashCode => r.hashCode;
}
