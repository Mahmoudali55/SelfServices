part of 'layout_cubit.dart';

class LayoutState extends Equatable {
  final int currentIndex;

  const LayoutState({required this.currentIndex});

  @override
  List<Object?> get props => [currentIndex];
}
