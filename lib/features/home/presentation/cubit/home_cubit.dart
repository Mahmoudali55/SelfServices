import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/home/data/repository/home_repo.dart';
import 'package:my_template/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepoImp repo;

  HomeCubit(this.repo) : super(const HomeState());

  bool _homeLoaded = false;
  bool _newsLoaded = false;
  bool _vacationLoaded = false;

  /// =======================
  /// Home Services
  /// =======================
  Future<void> loadHomeData() async {
    if (_homeLoaded && state.servicesStatus.isSuccess) return;

    emit(state.copyWith(servicesStatus: const StatusState.loading()));
    try {
      final data = await repo.getHomeData();
      _homeLoaded = true;
      emit(state.copyWith(servicesStatus: StatusState.success(data)));
    } catch (e) {
      emit(state.copyWith(servicesStatus: StatusState.failure(e.toString())));
    }
  }

  /// =======================
  /// Vacation Privileges
  /// =======================
  Future<void> loadVacationAdditionalPrivilages({required int pageID, required int empId}) async {
    if (_vacationLoaded && state.vacationStatus.isSuccess) return;

    emit(state.copyWith(vacationStatus: const StatusState.loading()));

    final result = await repo.vacationAdditionalPrivilages(pageID: pageID, empId: empId);

    result.fold(
      (failure) => emit(state.copyWith(vacationStatus: StatusState.failure(failure.errMessage))),
      (pageItem) {
        _vacationLoaded = true;
        emit(state.copyWith(vacationStatus: StatusState.success(pageItem)));
      },
    );
  }

  /// =======================
  /// News
  /// =======================
  Future<void> getAllNews({int? sar}) async {
    if (_newsLoaded && state.newsStatus.isSuccess) return;

    emit(state.copyWith(newsStatus: const StatusState.loading()));

    final result = await repo.getAllNews(sar);

    result.fold(
      (failure) => emit(state.copyWith(newsStatus: StatusState.failure(failure.errMessage))),
      (newsList) {
        _newsLoaded = true;
        emit(state.copyWith(newsStatus: StatusState.success(newsList)));
      },
    );
  }
}
