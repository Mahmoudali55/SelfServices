import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/services/data/model/Cars/add_new_car_request_model.dart';
import 'package:my_template/features/services/data/model/cars/car_type_model.dart';
import 'package:my_template/features/services/data/model/cars/update_car_request_model.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/add_new_dynamic_order.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/updata_request_general_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/housing_allowance_request_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/update_housing_allowance_model.dart';
import 'package:my_template/features/services/data/model/request_leave/check_emp_have_requests.dart';
import 'package:my_template/features/services/data/model/request_leave/delete_%20service_reqest_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_updata.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_type_model.dart';
import 'package:my_template/features/services/data/model/resignation/resignation_request_model.dart';
import 'package:my_template/features/services/data/model/resignation/update_resignation_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/add_new_solf_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/solfa_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/update_solfa_model.dart';
import 'package:my_template/features/services/data/model/ticket/ticket_request_model.dart';
import 'package:my_template/features/services/data/model/ticket/update_request_ticket_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/add_new_vacation_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/update_vacation_request_back_model.dart';
import 'package:my_template/features/services/data/repo/services_repo.dart';

import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepo leavesRepo;
  VacationTypeModel? selectedLeave;
  SolfaTypeModel? selectedSolfaType;
  EmployeeModel? selectedEmployee;
  CarTypeModel? selectedCarType;

  ServicesCubit(this.leavesRepo) : super(const ServicesState());

  Future<void> getLeaves() async {
    emit(state.copyWith(leavesStatus: const StatusState.loading()));
    final result = await leavesRepo.getLeaves();
    result.fold(
      (error) => emit(state.copyWith(leavesStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(leavesStatus: StatusState.success(success))),
    );
  }

  int currentPage = 1;
  bool hasMore = true;
  List<EmployeeModel> employees = [];

  Future<void> getEmployees({
    required int empcode,
    required int privid,
    bool refresh = false,
  }) async {
    emit(state.copyWith(employeesStatus: const StatusState.loading()));

    final result = await leavesRepo.getEmployees(
      empcode: empcode,
      privid: privid,
      forceRefresh: refresh,
    );

    result.fold(
      (error) {
        emit(state.copyWith(employeesStatus: StatusState.failure(error.errMessage)));
      },
      (data) {
        employees = data; // تحديث قائمة الموظفين
        emit(state.copyWith(employeesStatus: StatusState.success(List.from(employees))));
      },
    );
  }

  Future<void> getEmployeeVacations({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  }) async {
    emit(state.copyWith(employeeVacationsStatus: const StatusState.loading()));

    final result = await leavesRepo.getEmployeeVacations(
      empCode: empCode,
      bnDate: bnDate,
      edDate: edDate,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(employeeVacationsStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(employeeVacationsStatus: StatusState.success(success))),
    );
  }

  Future<void> getEmployeeBal({
    required int empCode,
    required DateTime bnDate,
    required DateTime edDate,
  }) async {
    emit(state.copyWith(employeeVacationsStatus: const StatusState.loading()));

    final result = await leavesRepo.getEmployeeBal(
      empCode: empCode,
      bnDate: bnDate,
      edDate: edDate,
    );

    result.fold(
      (error) => emit(state.copyWith(employeeBalStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(employeeBalStatus: StatusState.success(success))),
    );
  }

  Future<void> submitVacationRequest(VacationRequestModel request) async {
    if (isClosed) return;
    emit(state.copyWith(submitVacationStatus: const StatusState.loading()));

    final result = await leavesRepo.submitVacationRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(submitVacationStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(submitVacationStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(submitVacationStatus: StatusState.success(success)));
        emit(state.copyWith(submitVacationStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.CheckEmpHaveRequests(empCode: empCode);

    result.fold(
      (error) =>
          emit(state.copyWith(checkEmpHaveRequestsStatus: StatusState.failure(error.errMessage))),
      (success) =>
          emit(state.copyWith(checkEmpHaveRequestsStatus: StatusState.success(success.first))),
    );
  }

  Future<void> getServices({int? requestId}) async {
    emit(state.copyWith(servicesStatus: const StatusState.loading()));

    final result = await leavesRepo.getServices(requestId: requestId);

    result.fold(
      (error) => emit(state.copyWith(servicesStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(servicesStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteService({
    required int serviceId,
    required BuildContext context,
    required int requestId,
  }) async {
    emit(state.copyWith(services: const StatusState.loading()));

    final result = await leavesRepo.deleteServiceRequest(
      request: DeleteserviceRequestModel(id: serviceId),
    );

    result.fold((error) => emit(state.copyWith(services: StatusState.failure(error.errMessage))), (
      success,
    ) {
      emit(state.copyWith(services: StatusState.success(success)));
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar' ? 'تم الحذف بنجاح' : 'Deleted successfully',
        type: ToastType.success,
      );
      getServices(requestId: requestId);
    });
  }

  Future<void> deleteAttachment({
    required int attachId,
    required BuildContext context,
    required int requestId,
  }) async {
    emit(state.copyWith(deleteattachmentStatus: const StatusState.loading()));

    final result = await leavesRepo.deleteattachment(
      request: DeleteserviceRequestModel(id: attachId),
    );

    result.fold(
      (error) =>
          emit(state.copyWith(deleteattachmentStatus: StatusState.failure(error.errMessage))),
      (success) {
        emit(state.copyWith(deleteattachmentStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: context.locale.languageCode == 'ar' ? 'تم الحذف بنجاح' : 'Deleted successfully',
          type: ToastType.success,
        );
        getAttachments(requestId: requestId);
      },
    );
  }

  Future<void> getAttachments({required int requestId}) async {
    emit(state.copyWith(vacationAttachmentsStatus: const StatusState.loading()));

    final result = await leavesRepo.getVacationAttachments(vacationId: requestId);

    result.fold(
      (error) =>
          emit(state.copyWith(vacationAttachmentsStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(vacationAttachmentsStatus: StatusState.success(success))),
    );
  }

  Future<void> updataVacationRequest(VacationRequestUpdateModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataVacationStatus: const StatusState.loading()));

    final result = await leavesRepo.updataVacationRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataVacationStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataVacationStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataVacationStatus: StatusState.success(success)));
        emit(state.copyWith(updataVacationStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> getallServices() async {
    emit(state.copyWith(allservicesStatus: const StatusState.loading()));

    final result = await leavesRepo.getallServices();

    result.fold(
      (error) => emit(state.copyWith(allservicesStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(allservicesStatus: StatusState.success(success))),
    );
  }

  Future<void> getVacationBack({required int empcode}) async {
    emit(state.copyWith(vacationBackStatus: const StatusState.loading()));

    final result = await leavesRepo.getVacationBack(empCode: empcode);

    result.fold(
      (error) => emit(state.copyWith(vacationBackStatus: StatusState.failure(error.errMessage))),
      (success) {
        emit(state.copyWith(vacationBackStatus: StatusState.success(success)));
      },
    );
  }

  Future<void> addNewVacationBack({required AddNewVacationBackRequestModel request}) async {
    emit(state.copyWith(vacationBackAddStatus: const StatusState.loading()));

    final result = await leavesRepo.addNewVacationBack(request);

    result.fold(
      (error) {
        emit(state.copyWith(vacationBackAddStatus: StatusState.failure(error.errMessage)));

        emit(state.copyWith(vacationBackAddStatus: const StatusState.initial()));
      },
      (success) {
        emit(state.copyWith(vacationBackAddStatus: StatusState.success(success)));

        emit(state.copyWith(vacationBackAddStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpBackHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveBackRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveBackRequests(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveBackRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) =>
          emit(state.copyWith(checkEmpHaveBackRequestsStatus: StatusState.success(success.first))),
    );
  }

  Future<void> getSofaType() async {
    emit(state.copyWith(solfaStatus: const StatusState.loading()));
    final result = await leavesRepo.getSolfaType();
    result.fold(
      (error) => emit(state.copyWith(solfaStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(solfaStatus: StatusState.success(success))),
    );
  }

  Future<void> getEmployeeList() async {
    emit(state.copyWith(employeeListStatus: const StatusState.loading()));
    final result = await leavesRepo.getEmployee();
    result.fold(
      (error) => emit(state.copyWith(employeeListStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(employeeListStatus: StatusState.success(success))),
    );
  }

  Future<void> addNewSolfaRequest({required AddNewSolfaRquestModel request}) async {
    emit(state.copyWith(loanRequestStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewSolfa(request);
    result.fold(
      (error) {
        emit(state.copyWith(loanRequestStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(loanRequestStatus: const StatusState.initial()));
      },
      (success) {
        emit(state.copyWith(loanRequestStatus: StatusState.success(success)));
        emit(state.copyWith(loanRequestStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpSolfaHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveSolfaRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveSolfaRequests(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveSolfaRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) =>
          emit(state.copyWith(checkEmpHaveSolfaRequestsStatus: StatusState.success(success.first))),
    );
  }

  Future<void> updataVacationBackRequest(UpdateVacationRequestBackModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataVacationBackStatus: const StatusState.loading()));

    final result = await leavesRepo.updataVacationBackRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataVacationBackStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataVacationBackStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataVacationBackStatus: StatusState.success(success)));
        emit(state.copyWith(updataVacationBackStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updataSolfaRequest(UpdateSolfaModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataSolfaStatus: const StatusState.loading()));

    final result = await leavesRepo.updataSolfaRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataSolfaStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataSolfaStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataSolfaStatus: StatusState.success(success)));
        emit(state.copyWith(updataSolfaStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpBackHaveRequestsBadalsakan({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveBadalSakanRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveBadalSakan(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveBadalSakanRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) => emit(
        state.copyWith(checkEmpHaveBadalSakanRequestsStatus: StatusState.success(success.first)),
      ),
    );
  }

  Future<void> checkEmpBackHaveRequestsResignation({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveResignationRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveResignation(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(
          checkEmpHaveResignationRequestsStatus: StatusState.failure(error.errMessage),
        ),
      ),
      (success) => emit(
        state.copyWith(checkEmpHaveResignationRequestsStatus: StatusState.success(success.first)),
      ),
    );
  }

  Future<void> addnewHousingallowanceRequest({
    required HousingAllowanceRequestModel request,
  }) async {
    emit(state.copyWith(housingAllowanceStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewHousingallowance(request);
    result.fold(
      (error) {
        emit(state.copyWith(housingAllowanceStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(housingAllowanceStatus: const StatusState.initial()));
      },
      (success) {
        emit(state.copyWith(housingAllowanceStatus: StatusState.success(success)));
        emit(state.copyWith(housingAllowanceStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> addnewResignationRequest({required ResignationRequestModel request}) async {
    emit(state.copyWith(resignationStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewResignation(request);
    result.fold(
      (error) {
        emit(state.copyWith(resignationStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(resignationStatus: const StatusState.initial()));
      },
      (success) {
        emit(state.copyWith(resignationStatus: StatusState.success(success)));
        emit(state.copyWith(resignationStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateHousingAllowance(UpdateHousingAllowanceRequestModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataHousingAllowanceStatus: const StatusState.loading()));

    final result = await leavesRepo.updataHousingallowanceRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataHousingAllowanceStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataHousingAllowanceStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataHousingAllowanceStatus: StatusState.success(success)));
        emit(state.copyWith(updataHousingAllowanceStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateResignation(UpdateResignationModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataResignationStatus: const StatusState.loading()));

    final result = await leavesRepo.updataResignationRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataResignationStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataResignationStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataResignationStatus: StatusState.success(success)));
        emit(state.copyWith(updataResignationStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpCarsHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveCarRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveCar(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveCarRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) =>
          emit(state.copyWith(checkEmpHaveCarRequestsStatus: StatusState.success(success.first))),
    );
  }

  Future<void> getcarTypeList() async {
    emit(state.copyWith(carTypeStatus: const StatusState.loading()));
    final result = await leavesRepo.carType();
    result.fold(
      (error) => emit(state.copyWith(carTypeStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(carTypeStatus: StatusState.success(success))),
    );
  }

  Future<void> addnewCarRequest({required AddNewCarRequestModel request}) async {
    emit(state.copyWith(addnewCarStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewCar(request);
    result.fold(
      (error) {
        emit(state.copyWith(addnewCarStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(addnewCarStatus: const StatusState.initial()));
      },
      (success) {
        emit(state.copyWith(addnewCarStatus: StatusState.success(success)));
        emit(state.copyWith(addnewCarStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateCars(UpdateCarRequestModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataCarStatus: const StatusState.loading()));

    final result = await leavesRepo.updataCarRequest(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataCarStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataCarStatus: const StatusState.initial()));
      },

      (success) {
        emit(state.copyWith(updataCarStatus: StatusState.success(success)));
        emit(state.copyWith(updataCarStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpTransferHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveTransferRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveTransfer(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveTransferRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) => emit(
        state.copyWith(checkEmpHaveTransferRequestsStatus: StatusState.success(success.first)),
      ),
    );
  }

  Future<void> getDepartmentData() async {
    emit(state.copyWith(departmentStatus: const StatusState.loading()));
    final result = await leavesRepo.getDepartmentData();
    result.fold(
      (error) => emit(state.copyWith(departmentStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(departmentStatus: StatusState.success(success))),
    );
  }

  Future<void> getBranchData({required int deptCode}) async {
    emit(state.copyWith(branchStatus: const StatusState.loading()));
    final result = await leavesRepo.getBranchData(DeptCode: deptCode);
    result.fold(
      (error) => emit(state.copyWith(branchStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(branchStatus: StatusState.success(success))),
    );
  }

  Future<void> getProjectData() async {
    emit(state.copyWith(projectStatus: const StatusState.loading()));
    final result = await leavesRepo.getprojectData();
    result.fold(
      (error) => emit(state.copyWith(projectStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(projectStatus: StatusState.success(success))),
    );
  }

  Future<void> addnewTransfer({required AddNewTransferRequestModel request}) async {
    emit(state.copyWith(addnewTransferStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewTransfer(request);
    result.fold(
      (error) {
        emit(state.copyWith(addnewTransferStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(addnewTransferStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(addnewTransferStatus: StatusState.success(success)));
        emit(state.copyWith(addnewTransferStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateTransfer(UpdateTransferRequestModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataTransferStatus: const StatusState.loading()));

    final result = await leavesRepo.updataTransfer(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataTransferStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataTransferStatus: StatusState.failure(error.errMessage)));
      },

      (success) {
        emit(state.copyWith(updataTransferStatus: StatusState.success(success)));
        emit(state.copyWith(updataTransferStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> checkEmpTicketHaveRequests({required int empCode}) async {
    emit(state.copyWith(checkEmpHaveTicketRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveTicket(empCode: empCode);

    result.fold(
      (error) => emit(
        state.copyWith(checkEmpHaveTicketRequestsStatus: StatusState.failure(error.errMessage)),
      ),
      (success) => emit(
        state.copyWith(checkEmpHaveTicketRequestsStatus: StatusState.success(success.first)),
      ),
    );
  }

  Future<void> addnewTicket({required TicketRequest request}) async {
    emit(state.copyWith(addnewTicketStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewTicket(request: request);
    result.fold(
      (error) {
        emit(state.copyWith(addnewTicketStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(addnewTicketStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(addnewTicketStatus: StatusState.success(success)));
        emit(state.copyWith(addnewTicketStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateTicket(UpdateTicketsRequestModel request) async {
    if (isClosed) return;
    emit(state.copyWith(updataTicketStatus: const StatusState.loading()));

    final result = await leavesRepo.updataTicket(request);
    if (isClosed) return;
    result.fold(
      (error) {
        emit(state.copyWith(updataTicketStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataTicketStatus: StatusState.failure(error.errMessage)));
      },

      (success) {
        emit(state.copyWith(updataTicketStatus: StatusState.success(success)));
        emit(state.copyWith(updataTicketStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> uploadFiles(List<String> filePaths) async {
    emit(state.copyWith(uploadedFilesStatus: const StatusState.loading()));

    final result = await leavesRepo.uploadFile(filePaths: filePaths);

    result.fold(
      (error) {
        emit(state.copyWith(uploadedFilesStatus: StatusState.failure(error.errMessage)));
      },
      (files) {
        emit(state.copyWith(uploadedFilesStatus: StatusState.success(files)));
        emit(state.copyWith(uploadedFilesStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> imageFileName(String filePaths, BuildContext context) async {
    emit(state.copyWith(imageFileNameStatus: const StatusState.loading()));
    CommonMethods.showToast(
      message: context.locale.languageCode == 'ar' ? ' جاري التحميل.....' : 'Uploading.....',
      type: ToastType.help,
    );
    final result = await leavesRepo.imageFileName(filePath: filePaths);

    result.fold(
      (error) {
        emit(state.copyWith(imageFileNameStatus: StatusState.failure(error.errMessage)));
      },
      (files) {
        emit(state.copyWith(imageFileNameStatus: StatusState.success(files)));
        emit(state.copyWith(imageFileNameStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> employeechangephoto(EmployeeChangePhotoRequest request) async {
    emit(state.copyWith(employeechangephoto: const StatusState.loading()));
    final result = await leavesRepo.employeechangephoto(request);
    result.fold(
      (failure) =>
          emit(state.copyWith(employeechangephoto: StatusState.failure(failure.errMessage))),
      (success) {
        emit(state.copyWith(employeechangephoto: StatusState.success(success)));
        emit(state.copyWith(employeechangephoto: const StatusState.initial()));
      },
    );
  }

  Future<CheckEmpHaveRequestsModel?> checkEmpGeneral({
    required int empCode,
    required int requesttypeid,
  }) async {
    emit(state.copyWith(checkEmpHaveResignationRequestsStatus: const StatusState.loading()));

    final result = await leavesRepo.checkEmpHaveGeneral(
      empCode: empCode,
      requesttypeid: requesttypeid,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            checkEmpHaveResignationRequestsStatus: StatusState.failure(failure.errMessage),
          ),
        );
        return null;
      },
      (data) {
        emit(
          state.copyWith(checkEmpHaveResignationRequestsStatus: StatusState.success(data.first)),
        );
        return data.first;
      },
    );
  }

  Future<void> addnewGeneral({required AddNewDynamicOrder request}) async {
    emit(state.copyWith(addnewGeneralStatus: const StatusState.loading()));
    final result = await leavesRepo.addnewGeneralRequest(request);
    result.fold(
      (error) {
        emit(state.copyWith(addnewGeneralStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(addnewGeneralStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(addnewGeneralStatus: StatusState.success(success)));
        emit(state.copyWith(addnewGeneralStatus: const StatusState.initial()));
      },
    );
  }

  Future<void> updateGeneral({required UpdataRequestGeneralModel request}) async {
    emit(state.copyWith(updataGeneralStatus: const StatusState.loading()));
    final result = await leavesRepo.updataGeneralRequest(request);
    result.fold(
      (error) {
        emit(state.copyWith(updataGeneralStatus: StatusState.failure(error.errMessage)));
        emit(state.copyWith(updataGeneralStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(updataGeneralStatus: StatusState.success(success)));
        emit(state.copyWith(updataGeneralStatus: const StatusState.initial()));
      },
    );
  }

  void selectLeave(VacationTypeModel leave) {
    selectedLeave = leave;
    emit(state);
  }

  void selectSolfaType(SolfaTypeModel type) {
    selectedSolfaType = type;
    emit(state);
  }

  void selectEmployee(EmployeeModel employee) {
    selectedEmployee = employee;
    emit(state);
  }

  void selectCarType(CarTypeModel carType) {
    selectedCarType = carType;
    emit(state);
  }
}
