
import 'package:equatable/equatable.dart';
import 'package:hajzi/presentation/bottomnavigation/bloc/tab_state.dart';

class TabEvent extends Equatable {
  const TabEvent();

  @override
  List<Object> get props => [];
}

class TabChanged extends TabEvent {
  final TabItem tab;

  const TabChanged(this.tab);

  @override
  List<Object> get props => [tab];
}