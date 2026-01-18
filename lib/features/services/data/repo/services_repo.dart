import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/core/network/handle_dio_request.dart';
import 'package:my_template/features/profile/data/model/employe_echange_photo_model.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/request_history/data/model/request_leave_updata_response_model.dart';
import 'package:my_template/features/services/data/model/Cars/add_new_car_request_model.dart';
import 'package:my_template/features/services/data/model/cars/add_new_car_response_model.dart';
import 'package:my_template/features/services/data/model/cars/car_type_model.dart';
import 'package:my_template/features/services/data/model/cars/update_car_request_model.dart';
import 'package:my_template/features/services/data/model/cars/update_car_response_model.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/add_new_dynamic_order.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/add_new_dynamic_order_response.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/updata_request_general_model.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/update_new_dynamic_order_response.dart';
import 'package:my_template/features/services/data/model/housing_allowance/housing_allowance_request_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/housing_allowance_response_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/update_housing_allowance_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/update_housing_allowance_response_model.dart';
import 'package:my_template/features/services/data/model/request_leave/Employee_bal_model.dart';
import 'package:my_template/features/services/data/model/request_leave/all_service_model.dart';
import 'package:my_template/features/services/data/model/request_leave/check_emp_have_requests.dart';
import 'package:my_template/features/services/data/model/request_leave/delete_%20service_reqest_model.dart';
import 'package:my_template/features/services/data/model/request_leave/delete_%20service_response_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_vacation_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/request_leave_model.dart';
import 'package:my_template/features/services/data/model/request_leave/service_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_updata.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_type_model.dart';
import 'package:my_template/features/services/data/model/resignation/resignation_request_model.dart';
import 'package:my_template/features/services/data/model/resignation/resignation_response_model.dart';
import 'package:my_template/features/services/data/model/resignation/update_resignation_model.dart';
import 'package:my_template/features/services/data/model/resignation/update_resignation_response_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/add_new_solf_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/add_new_solfa_response_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/get_employee_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/solfa_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/update_solfa_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/update_solfa_response_model.dart';
import 'package:my_template/features/services/data/model/ticket/ticket_request_model.dart';
import 'package:my_template/features/services/data/model/ticket/ticket_response_model.dart';
import 'package:my_template/features/services/data/model/ticket/update_request_ticket_model.dart';
import 'package:my_template/features/services/data/model/ticket/update_request_ticket_response_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_response_model.dart';
import 'package:my_template/features/services/data/model/transfer/branch_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/department_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/projects_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_response_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/add_new_vacation_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/add_new_vacation_back_response_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/update_vacation_request_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/update_vacation_response_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/vacation_back_model.dart';

import '../../../../core/error/failures.dart' hide handleDioRequest;

abstract interface class ServicesRepo {
  Future<Either<Failure, List<VacationTypeModel>>> getLeaves();
  Future<Either<Failure, List<EmployeeModel>>> getEmployees({
    required int empcode,
    required int privid,
    bool forceRefresh = false,
  });
  Future<Either<Failure, List<EmployeeVacationModel>>> getEmployeeVacations({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  });
  Future<Either<Failure, List<EmployeeBalModel>>> getEmployeeBal({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  });
  Future<Either<Failure, RequestLeaveResponseModel>> submitVacationRequest(
    VacationRequestModel request,
  );
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> CheckEmpHaveRequests({
    required int empCode,
  });
  Future<Either<Failure, List<ServiceModel>>> getServices({int? requestId});
  Future<Either<Failure, List<ALLServiceModel>>> getallServices();
  Future<Either<Failure, DeleteServiceResponseModel>> deleteServiceRequest({
    DeleteserviceRequestModel? request,
  });
  Future<Either<Failure, RequestLeaveUpdataResponseModel>> updataVacationRequest(
    VacationRequestUpdateModel request,
  );
  //العودة من الاجازات///
  Future<Either<Failure, List<VacationBackRequestModel>>> getVacationBack({required int empCode});
  Future<Either<Failure, AddNewVacationBackResponseModel>> addNewVacationBack(
    AddNewVacationBackRequestModel request,
  );
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveBackRequests({
    required int empCode,
  });
  Future<Either<Failure, UpdateVacationResponseBackModel>> updataVacationBackRequest(
    UpdateVacationRequestBackModel request,
  );

  /// السلفات
  Future<Either<Failure, List<SolfaTypeModel>>> getSolfaType();
  Future<Either<Failure, List<GetEmployeeModel>>> getEmployee();
  Future<Either<Failure, AddNewSolfaResponseModel>> addnewSolfa(AddNewSolfaRquestModel request);
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveSolfaRequests({
    required int empCode,
  });
  Future<Either<Failure, UpdateSolfaResponseModel>> updataSolfaRequest(UpdateSolfaModel request);
  // طلب بدل سكن
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveBadalSakan({
    required int empCode,
  });
  Future<Either<Failure, HousingAllowanceResponse>> addnewHousingallowance(
    HousingAllowanceRequestModel request,
  );
  Future<Either<Failure, UpdateHousingAllowanceResponse>> updataHousingallowanceRequest(
    UpdateHousingAllowanceRequestModel request,
  );
  // طلب استقالة
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveResignation({
    required int empCode,
  });
  Future<Either<Failure, ResignationResponseModel>> addnewResignation(
    ResignationRequestModel request,
  );
  Future<Either<Failure, UpdateResignationResponse>> updataResignationRequest(
    UpdateResignationModel request,
  );
  //طلب سيارة
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveCar({required int empCode});
  Future<Either<Failure, List<CarTypeModel>>> carType();
  Future<Either<Failure, AddNewCarResponseModel>> addnewCar(AddNewCarRequestModel request);
  Future<Either<Failure, UpdateCarResponseModel>> updataCarRequest(UpdateCarRequestModel request);
  //طلب نقل
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveTransfer({
    required int empCode,
  });

  Future<Either<Failure, List<DepartmentModel>>> getDepartmentData();
  Future<Either<Failure, List<BranchDataModel>>> getBranchData({required int DeptCode});
  Future<Either<Failure, List<ProjectsDataModel>>> getprojectData();
  Future<Either<Failure, AddNewTransferResponseModel>> addnewTransfer(
    AddNewTransferRequestModel request,
  );
  Future<Either<Failure, UpdateTransferResponseModel>> updataTransfer(
    UpdateTransferRequestModel request,
  );
  //طلب تذاكر
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveTicket({
    required int empCode,
  });
  Future<Either<Failure, TicketResponse>> addnewTicket({required TicketRequest request});
  Future<Either<Failure, UpdateTicketsResponseModel>> updataTicket(
    UpdateTicketsRequestModel request,
  );
  //تحميل ملف
  Future<Either<Failure, List<String>>> uploadFile({required List<String> filePaths});
  Future<Either<Failure, DeleteServiceResponseModel>> deleteattachment({
    DeleteserviceRequestModel? request,
  });
  Future<Either<Failure, List<VacationAttachmentItem>>> getVacationAttachments({
    required int vacationId,
    required int attchmentType,
  });
  Future<Either<Failure, String>> imageFileName({required String filePath});
  Future<Either<Failure, EmployeechangephotoResponse>> employeechangephoto(
    EmployeeChangePhotoRequest request,
  );
  Future<Either<Failure, EmployeechangephotoResponse>> employeefacephoto(
    EmployeeChangePhotoRequest request,
  );

  //طلب عام
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveGeneral({
    required int empCode,
    required int requesttypeid,
  });
  Future<Either<Failure, AddNewDynamicOrderResponse>> addnewGeneralRequest(
    AddNewDynamicOrder request,
  );
  Future<Either<Failure, UpdataNewDynamicOrderResponse>> updataGeneralRequest(
    UpdataRequestGeneralModel request,
  );

  Future<Either<Failure, String>> getEmployeeFaceImage(int empCode);
}

class ServicesRepoImpl implements ServicesRepo {
  final ApiConsumer apiConsumer;

  ServicesRepoImpl(this.apiConsumer);

  ///طلبات الاجازه
  @override
  Future<Either<Failure, List<VacationTypeModel>>> getLeaves() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationType);

        final String dataString = response['Data'];
        final List dataList = jsonDecode(dataString);

        return dataList.map((x) => VacationTypeModel.fromJson(x)).toList();
      },
    );
  }

  final Map<String, List<EmployeeModel>> _cache = {};

  @override
  Future<Either<Failure, List<EmployeeModel>>> getEmployees({
    required int empcode,
    required int privid,
    bool forceRefresh = false,
  }) {
    return handleDioRequest(
      request: () async {
        final cacheKey = '$empcode-$privid';

        if (!forceRefresh && _cache.containsKey(cacheKey)) {
          return _cache[cacheKey]!;
        }

        final response = await apiConsumer.get(EndPoints.employeewithPrivilages(empcode, privid));

        final allEmployees = EmployeeModel.listFromJson(response['Data']);

        _cache[cacheKey] = allEmployees;

        return allEmployees;
      },
    );
  }

  @override
  Future<Either<Failure, List<EmployeeVacationModel>>> getEmployeeVacations({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  }) {
    return handleDioRequest(
      request: () async {
        final bnDateStr = DateFormat('yyyy-MM-dd', 'en').format(bnDate);
        final edDateStr = DateFormat('yyyy-MM-dd', 'en').format(edDate);

        final response = await apiConsumer.get(
          EndPoints.employeevacationbalance(empCode, bnDateStr, edDateStr),
        );

        return EmployeeVacationModel.listFromDataString(jsonEncode(response));
      },
    );
  }

  @override
  Future<Either<Failure, List<EmployeeBalModel>>> getEmployeeBal({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  }) {
    return handleDioRequest(
      request: () async {
        final bnDateStr = DateFormat('yyyy-MM-dd', 'en').format(bnDate);
        final edDateStr = DateFormat('yyyy-MM-dd', 'en').format(edDate);

        final response = await apiConsumer.get(
          EndPoints.employeebal(empCode, bnDateStr, edDateStr),
        );

        return EmployeeBalModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, RequestLeaveResponseModel>> submitVacationRequest(
    VacationRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(EndPoints.addnewvacation, body: request.toJson());

        return RequestLeaveResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> CheckEmpHaveRequests({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveRequestsInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices({int? requestId}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationservice(requestId: requestId));

        final String dataString = response['Data'] ?? '[]';
        final List<ServiceModel> services = ServiceModel.listFromData(dataString);

        return services;
      },
    );
  }

  @override
  Future<Either<Failure, List<ALLServiceModel>>> getallServices() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationallservice());

        final List<ALLServiceModel> services = ALLServiceModel.listFromResponse(response);

        return services;
      },
    );
  }

  @override
  Future<Either<Failure, DeleteServiceResponseModel>> deleteServiceRequest({
    DeleteserviceRequestModel? request,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteServices,
          body: {'id': request?.id},
        );
        return DeleteServiceResponseModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, DeleteServiceResponseModel>> deleteattachment({
    DeleteserviceRequestModel? request,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(EndPoints.deleteFile, body: {'id': request?.id});

        return DeleteServiceResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, RequestLeaveUpdataResponseModel>> updataVacationRequest(
    VacationRequestUpdateModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updatenewvacation, body: request.toJson());

        return RequestLeaveUpdataResponseModel.fromJson(response);
      },
    );
  }

  ///طلبات العودة من الاجازة
  @override
  Future<Either<Failure, List<VacationBackRequestModel>>> getVacationBack({required int empCode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationBack(empCode));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = json.decode(dataString);

        return dataList.map((e) => VacationBackRequestModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, AddNewVacationBackResponseModel>> addNewVacationBack(
    AddNewVacationBackRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addNewVacationBack,
          body: request.toJson(),
        );
        return AddNewVacationBackResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveBackRequests({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveBackRequestsInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateVacationResponseBackModel>> updataVacationBackRequest(
    UpdateVacationRequestBackModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.updatenewBackvacation,
          body: request.toJson(),
        );

        return UpdateVacationResponseBackModel.fromJson(response);
      },
    );
  }

  // السلفات
  @override
  Future<Either<Failure, List<SolfaTypeModel>>> getSolfaType() {
    return handleDioRequest(
      request: () async {
        final result = await apiConsumer.get(EndPoints.SofaType);
        return SolfaTypeModel.listFromResponse(result);
      },
    );
  }

  @override
  Future<Either<Failure, List<GetEmployeeModel>>> getEmployee() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getEmployee);
        return GetEmployeeModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, AddNewSolfaResponseModel>> addnewSolfa(AddNewSolfaRquestModel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(EndPoints.addnewSolfa, body: request.toJson());
        return AddNewSolfaResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveSolfaRequests({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveSolfaRequestsInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateSolfaResponseModel>> updataSolfaRequest(UpdateSolfaModel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updateSolfa, body: request.toJson());

        return UpdateSolfaResponseModel.fromJson(response);
      },
    );
  }

  /// طلبات البدل سكن
  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveBadalSakan({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveBadalSakanInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, HousingAllowanceResponse>> addnewHousingallowance(
    HousingAllowanceRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addnewHousingallowance,
          body: request.toJson(),
        );
        return HousingAllowanceResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateHousingAllowanceResponse>> updataHousingallowanceRequest(
    UpdateHousingAllowanceRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.updateHousingAllowance,
          body: request.toJson(),
        );

        return UpdateHousingAllowanceResponse.fromJson(response);
      },
    );
  }

  // االاستقالة
  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveResignation({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveResignationInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, ResignationResponseModel>> addnewResignation(
    ResignationRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addnewResignation,
          body: request.toJson(),
        );
        return ResignationResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateResignationResponse>> updataResignationRequest(
    UpdateResignationModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updateResignation, body: request.toJson());

        return UpdateResignationResponse.fromJson(response);
      },
    );
  }

  // السيارة
  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveCar({required int empCode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.checkEmpHaveCarInProccissing(empCode));
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CarTypeModel>>> carType() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.carType);

        return CarTypeModel.listFromMap(response);
      },
    );
  }

  @override
  Future<Either<Failure, AddNewCarResponseModel>> addnewCar(AddNewCarRequestModel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(EndPoints.addNewCar, body: request.toJson());
        return AddNewCarResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateCarResponseModel>> updataCarRequest(UpdateCarRequestModel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updateCar, body: request.toJson());
        return UpdateCarResponseModel.fromJson(response);
      },
    );
  }

  // نقل موظف
  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveTransfer({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveTransferInProccissing(empCode),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<DepartmentModel>>> getDepartmentData() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getDepartmentData);

        return DepartmentModel.listFromMap(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<BranchDataModel>>> getBranchData({required int DeptCode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getBranchData(DeptCode));

        return BranchDataModel.listFromMap(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<ProjectsDataModel>>> getprojectData() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getProjectsData);
        return ProjectsDataModel.listFromMap(response);
      },
    );
  }

  @override
  Future<Either<Failure, AddNewTransferResponseModel>> addnewTransfer(
    AddNewTransferRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(EndPoints.addnewTransfer, body: request.toJson());
        return AddNewTransferResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateTransferResponseModel>> updataTransfer(
    UpdateTransferRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updateTransfer, body: request.toJson());
        return UpdateTransferResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveTicket({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.checkEmpHaveTicketInProccissing(empCode));
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, TicketResponse>> addnewTicket({required TicketRequest request}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(EndPoints.addnewTicket, body: request.toJson());
        return TicketResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdateTicketsResponseModel>> updataTicket(
    UpdateTicketsRequestModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.updateTicket, body: request.toJson());
        return UpdateTicketsResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<String>>> uploadFile({required List<String> filePaths}) {
    return handleDioRequest(
      request: () async {
        final uri = Uri.parse('https://delta-asg.com:57513/DeltagroupService/Vacation/UploadFiles');

        var request = http.MultipartRequest('POST', uri);

        // إضافة الملفات
        for (var path in filePaths) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'files', // اسم الحقل في الـ API
              path,
              filename: path.split('/').last,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            // ✅ ارجع List<String> فقط
            final List<String> uploadedFilePaths = decoded.map((path) => path.toString()).toList();
            return uploadedFilePaths;
          } else {
            throw Exception('Unexpected response format: ${response.body}');
          }
        } else {
          throw Exception('Server error: ${response.statusCode}, ${response.body}');
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationAttachmentItem>>> getVacationAttachments({
    required int vacationId,
    required int attchmentType,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getattachment(requestId: vacationId, attchmentType: attchmentType),
        );

        final String dataString = response['Data'] ?? '[]';
        final List<dynamic> dataList = jsonDecode(dataString);

        return dataList.map((item) => VacationAttachmentItem.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, String>> imageFileName({required String filePath}) async {
    return handleDioRequest(
      request: () async {
        final fileName = filePath.split('/').last.split('\\').last;
        final url =
            'https://delta-asg.com:57513/DeltagroupService/Users/userimge?imageFileName=$fileName';

        final response = await apiConsumer.get(url);

        return response.toString();
      },
    );
  }

  @override
  Future<Either<Failure, EmployeechangephotoResponse>> employeechangephoto(
    EmployeeChangePhotoRequest request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.employeechangephoto,
          body: request.toJson(),
        );
        return EmployeechangephotoResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, EmployeechangephotoResponse>> employeefacephoto(
    EmployeeChangePhotoRequest request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.employeefacephoto, body: request.toJson());
        return EmployeechangephotoResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<CheckEmpHaveRequestsModel>>> checkEmpHaveGeneral({
    required int empCode,
    required int requesttypeid,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.checkEmpHaveTicketInProccissingGeneral(empCode, requesttypeid),
        );
        return CheckEmpHaveRequestsModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, AddNewDynamicOrderResponse>> addnewGeneralRequest(
    AddNewDynamicOrder request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addnewRequestGeneral,
          body: request.toJson(),
        );
        return AddNewDynamicOrderResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, UpdataNewDynamicOrderResponse>> updataGeneralRequest(
    UpdataRequestGeneralModel request,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.updateRequestGeneral,
          body: request.toJson(),
        );
        return UpdataNewDynamicOrderResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, String>> getEmployeeFaceImage(int empCode) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.employeeFaceImage(empCode));

        final String dataString = response['Data'] ?? '';
        if (dataString.isEmpty) return '';

        try {
          final dynamic decoded = jsonDecode(dataString);
          if (decoded is List && decoded.isNotEmpty) {
            return decoded[0]['emp_photo']?.toString() ?? '';
          } else if (decoded is Map<String, dynamic>) {
            return decoded['emp_photo']?.toString() ?? '';
          }
        } catch (e) {
          return dataString;
        }
        return '';
      },
    );
  }
}
