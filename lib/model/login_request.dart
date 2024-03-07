/// user_login : false
/// third_party_apps : true
/// session : {"login":"","password":"","device_id":"","notification_token":""}

class LoginRequest {
  LoginRequest({
      bool? userLogin,
      bool? thirdPartyApps,
      Session? session,}){
    _userLogin = userLogin;
    _thirdPartyApps = thirdPartyApps;
    _session = session;
}

  LoginRequest.fromJson(dynamic json) {
    _userLogin = json['user_login'];
    _thirdPartyApps = json['third_party_apps'];
    _session = json['session'] != null ? Session?.fromJson(json['session']) : null;
  }
  bool?_userLogin;
  bool? _thirdPartyApps;
  Session? _session;
LoginRequest copyWith({  bool? userLogin,
  bool? thirdPartyApps,
  Session? session,
}) => LoginRequest(  userLogin: userLogin ?? _userLogin,
  thirdPartyApps: thirdPartyApps ?? _thirdPartyApps,
  session: session ?? _session,
);
  bool? get userLogin => _userLogin;
  bool? get thirdPartyApps => _thirdPartyApps;
  Session? get session => _session;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_login'] = _userLogin;
    map['third_party_apps'] = _thirdPartyApps;
    if (_session != null) {
      map['session'] = _session?.toJson();
    }
    return map;
  }

}

/// login : ""
/// password : ""
/// device_id : ""
/// notification_token : ""

class Session {
  Session({
      String? login,
      String? password,
      String? deviceId,
      String? notificationToken,}){
    _login = login;
    _password = password;
    _deviceId = deviceId;
    _notificationToken = notificationToken;
}

  Session.fromJson(dynamic json) {
    _login = json['login'];
    _password = json['password'];
    _deviceId = json['device_id'];
    _notificationToken = json['notification_token'];
  }
  String? _login;
  String? _password;
  String? _deviceId;
  String? _notificationToken;
Session copyWith({  String? login,
  String? password,
  String? deviceId,
  String? notificationToken,
}) => Session(  login: login ?? _login,
  password: password ?? _password,
  deviceId: deviceId ?? _deviceId,
  notificationToken: notificationToken ?? _notificationToken,
);
  String? get login => _login;
  String? get password => _password;
  String? get deviceId => _deviceId;
  String? get notificationToken => _notificationToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['login'] = _login;
    map['password'] = _password;
    map['device_id'] = _deviceId;
    map['notification_token'] = _notificationToken;
    return map;
  }

}