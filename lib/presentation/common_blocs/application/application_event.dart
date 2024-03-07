
import 'package:equatable/equatable.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  List<Object> get props => [];
}

class SetUpApplication extends ApplicationEvent{}