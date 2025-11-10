import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/profile/data/repo/Profile_repo.dart';
import 'package:my_template/features/profile/presentation/cubit/profile_state.dart';

class PrefileCubit extends Cubit<ProfileState> {
  final ProfileRepo repo;
  PrefileCubit(this.repo) : super(const ProfileState());
  Future<void> getProfile({required int empId}) async {
    emit(state.copyWith(profileStatus: const StatusState.loading()));
    final result = await repo.getProfile(empId: empId);
    result.fold(
      (failure) => emit(state.copyWith(profileStatus: StatusState.failure(failure.errMessage))),
      (success) {
        final profile = success.isNotEmpty ? success[0] : null; // List<ProfileModel>
        emit(state.copyWith(profileStatus: StatusState.success(success))); // تحتفظ بالقائمة
        if (profile != null) {
          HiveMethods.saveProjectId(profile.projectId);
          HiveMethods.saveEmpPhotoBase64(profile.empPhotoWeb ?? '');
        }
      },
    );
  }
}
