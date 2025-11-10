import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/profile/data/model/profile_model.dart';

class ProfileState extends Equatable {
  final StatusState<List<ProfileModel>> profileStatus;

  const ProfileState({this.profileStatus = const StatusState.initial()});

  ProfileState copyWith({StatusState<List<ProfileModel>>? profileStatus}) {
    return ProfileState(profileStatus: profileStatus ?? this.profileStatus);
  }

  @override
  List<Object?> get props => [profileStatus];
}
