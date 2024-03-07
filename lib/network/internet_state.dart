import 'package:flutter/material.dart';

import '../constants/enums.dart';

@immutable
abstract class InternetState{}
class InternetLoading extends InternetState {}
class InternetConnected extends InternetState {
  final ConnectionType connectionType;

  InternetConnected({required this.connectionType});

  @override
  String toString() => 'InternetConnected(connectionType: $connectionType)';
}

class InternetDisconnected extends InternetState {}