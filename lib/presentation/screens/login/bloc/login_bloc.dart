import 'package:bloc/bloc.dart';
import 'package:bloc_demo_app/model/login_request.dart';
import 'package:bloc_demo_app/presentation/screens/login/bloc/login_event.dart';
import 'package:bloc_demo_app/presentation/screens/login/bloc/login_state.dart';
import '../../../../data/repository/app/app_repository.dart';
import '../../../../data/repository/login_repo/login_repository.dart';
import '../../../../model/login_response.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final LoginRepository loginRepository = AppRepository.loginRepository;

  LoginBloc() :super(LoginInitialState()) {
    on<LoginWithCredentials>((event, emit) => loginUser(event, emit));

  }

  Future<LoginResponse> loginUser(LoginWithCredentials event,
      Emitter<LoginState> emit,) async {

    emit(LoginLoading());
    if(event.email.isEmpty || event.password.isEmpty){
      emit(LoginFailed(message: 'Please enter the credentials'));
    }
    Session session = Session(login: event.email,
        password: event.password,
        deviceId: "67c0cb23aa733175",
        notificationToken: "");
    LoginRequest request = LoginRequest(session: session,thirdPartyApps: false,userLogin: true);

    var response = await loginRepository.userLogin(request);
    print("Login Response -- ${response.data?.user?.name}");
    emit(LoginCompleted());
    return response;
  }
}