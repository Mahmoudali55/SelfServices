import 'package:dartz/dartz.dart';
import 'package:my_template/core/error/failures.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/features/profile/data/model/employe_echange_photo_model.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/profile/data/model/profile_model.dart';

abstract interface class ProfileRepo {
  Future<Either<Failure, List<ProfileModel>>> getProfile({required int empId});
 
}

class ProfileRepoImp implements ProfileRepo {
  final ApiConsumer apiConsumer;
  ProfileRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, List<ProfileModel>>> getProfile({required int empId}) {
    return handleDioRequest(
      request: () async {
        final Map<String, dynamic> jsonResponse = await apiConsumer.get(
          EndPoints.getprofile(empId),
        );
        return ProfileModel.listFromResponse(jsonResponse);
      },
    );
  }

  
}
