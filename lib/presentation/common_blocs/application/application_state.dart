
import 'package:equatable/equatable.dart';

abstract class ApplicationState extends Equatable{
  const ApplicationState();

  List<Object> get props =>[];
}

class ApplicationInitialState extends ApplicationState{}

class ApplicationCompleted extends ApplicationState{}