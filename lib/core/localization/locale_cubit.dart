import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(Locale initial) : super(initial);

  void setLocale(Locale locale) => emit(locale);
} 