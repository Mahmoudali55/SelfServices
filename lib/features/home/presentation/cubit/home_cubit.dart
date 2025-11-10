import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/home/data/repository/home_repo.dart';
import 'package:my_template/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepoImp repo;

  HomeCubit(this.repo) : super(const HomeState());

  void loadHomeData() async {
    try {
      final data = await repo.getHomeData();
      emit(state.copyWith(servicesStatus: StatusState.success(data)));
    } catch (e) {
      emit(state.copyWith(servicesStatus: StatusState.failure(e.toString())));
    }
  }

  Future<void> loadVacationAdditionalPrivilages({required int pageID, required int empId}) async {
    emit(state.copyWith(vacationStatus: const StatusState.loading()));
    final result = await repo.vacationAdditionalPrivilages(pageID: pageID, empId: empId);

    result.fold(
      (failure) => emit(state.copyWith(vacationStatus: StatusState.failure(failure.errMessage))),
      (pageItem) => emit(state.copyWith(vacationStatus: StatusState.success(pageItem))),
    );
  }

  Future<void> getAllNews({int? sar}) async {
    emit(state.copyWith(newsStatus: const StatusState.loading()));

    final result = await repo.getAllNews(sar);

    result.fold(
      (failure) => emit(state.copyWith(newsStatus: StatusState.failure(failure.errMessage))),
      (newsList) => emit(state.copyWith(newsStatus: StatusState.success(newsList))),
    );
  }
}
