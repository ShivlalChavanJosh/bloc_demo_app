import 'package:bloc/bloc.dart';
import 'package:bloc_demo_app/configs/application.dart';
import 'package:bloc_demo_app/presentation/common_blocs/application/application_event.dart';
import 'package:bloc_demo_app/presentation/common_blocs/application/application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent,ApplicationState>{

  final Application application = Application();

  ApplicationBloc() : super(ApplicationInitialState());

}