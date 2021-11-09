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
}
