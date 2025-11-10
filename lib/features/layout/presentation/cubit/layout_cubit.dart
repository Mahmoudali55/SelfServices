import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(const LayoutState(currentIndex: 0));

  void changePage(int index) {
    emit(LayoutState(currentIndex: index));
  }
}
