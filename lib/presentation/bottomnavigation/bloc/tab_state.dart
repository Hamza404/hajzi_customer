
import 'package:equatable/equatable.dart';

enum TabItem { home, profile, request, chat }

class TabState extends Equatable {
  final TabItem currentTab;

  const TabState({required this.currentTab});

  @override
  List<Object> get props => [currentTab];
}