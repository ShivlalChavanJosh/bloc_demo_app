import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable{
}


class LoginInitialState extends LoginState{
  @override
  List<Object?> get props => [];
}

class LoginLoading extends LoginState{
  @override
  List<Object?> get props => [];
}

class LoginCompleted extends LoginState{
  @override
  List<Object?> get props => [];
}

class LoginFailed extends LoginState{
  String message;
  LoginFailed({required this.message});
  @override
  List<Object?> get props => [];
}