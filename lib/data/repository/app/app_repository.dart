import 'package:bloc_demo_app/data/repository/login_repo/login_repository.dart';

class AppRepository {
  static final loginRepository = LoginRepository();

  static final AppRepository _instance = AppRepository._internal();

  factory AppRepository(){
    return _instance;
  }
  AppRepository._internal();
}