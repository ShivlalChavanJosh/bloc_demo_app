
import 'package:bloc_demo_app/data/repository/app/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/login_repo/login_repository.dart';
import 'login_state.dart';


class LoginCubit extends Cubit<LoginState>{

  final LoginRepository loginRepository = AppRepository.loginRepository;

  LoginCubit() :super(LoginInitialState());




}