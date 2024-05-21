
class DevEnvironment {
  final  receiveTimeout = const Duration(seconds:2 * 60);
  final connectTimeout = const Duration(seconds: 2 * 60 );
}

class DemoApi {
  static const BASE_URL = "your_end_point";
}

final environment = DevEnvironment();

enum MethodType { GET, POST, PUT, DELETE }
