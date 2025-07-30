import 'package:flutter_bloc/flutter_bloc.dart';

import 'tab_event.dart';
import 'tab_state.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  TabBloc() : super(const TabState(currentTab: TabItem.home)) {
    on<TabChanged>((event, emit) {
      emit(TabState(currentTab: event.tab));
    });
  }
}