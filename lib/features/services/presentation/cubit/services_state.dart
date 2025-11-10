import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/profile/data/model/employe_echange_photo_model.dart';
import 'package:my_template/features/request_history/data/model/request_leave_updata_response_model.dart';
import 'package:my_template/features/services/data/model/cars/add_new_car_response_model.dart';
import 'package:my_template/features/services/data/model/cars/car_type_model.dart';
import 'package:my_template/features/services/data/model/cars/update_car_response_model.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/add_new_dynamic_order_response.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/update_new_dynamic_order_response.dart';
import 'package:my_template/features/services/data/model/housing_allowance/housing_allowance_response_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/update_housing_allowance_response_model.dart';
import 'package:my_template/features/services/data/model/request_leave/Employee_bal_model.dart';
import 'package:my_template/features/services/data/model/request_leave/all_service_model.dart';
import 'package:my_template/features/services/data/model/request_leave/check_emp_have_requests.dart';
import 'package:my_template/features/services/data/model/request_leave/delete_%20service_response_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_vacation_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/request_leave_model.dart';
import 'package:my_template/features/services/data/model/request_leave/service_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_type_model.dart';
import 'package:my_template/features/services/data/model/resignation/resignation_response_model.dart';
import 'package:my_template/features/services/data/model/resignation/update_resignation_response_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/add_new_solfa_response_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/get_employee_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/solfa_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/update_solfa_response_model.dart';
import 'package:my_template/features/services/data/model/ticket/ticket_response_model.dart';
import 'package:my_template/features/services/data/model/ticket/update_request_ticket_response_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_response_model.dart';
import 'package:my_template/features/services/data/model/transfer/branch_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/department_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/projects_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_response_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/add_new_vacation_back_response_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/update_vacation_response_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/vacation_back_model.dart';

class ServicesState extends Equatable {
  final StatusState<List<VacationTypeModel>> leavesStatus;
  final StatusState<List<EmployeeModel>> employeesStatus;
  final StatusState<List<EmployeeVacationModel>> employeeVacationsStatus;
  final StatusState<List<EmployeeBalModel>> employeeBalStatus;
  final StatusState<List<ServiceModel>> servicesStatus;
  final StatusState<RequestLeaveResponseModel> submitVacationStatus;
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveRequestsStatus;
  final StatusState<DeleteServiceResponseModel> services;
  final StatusState<DeleteServiceResponseModel> deleteattachmentStatus;
  final StatusState<RequestLeaveUpdataResponseModel> updataVacationStatus;
  final StatusState<List<ALLServiceModel>>? allservicesStatus;
  final StatusState<List<String>> uploadedFilesStatus;
  final StatusState<List<VacationAttachmentItem>>? vacationAttachmentsStatus;
  final StatusState<String>? imageFileNameStatus;
  //العودة للاجازات///
  final StatusState<List<VacationBackRequestModel>>? vacationBackStatus;
  final StatusState<AddNewVacationBackResponseModel> vacationBackAddStatus;
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveBackRequestsStatus;
  final StatusState<UpdateVacationResponseBackModel> updataVacationBackStatus;

  /// السلفة//
  final StatusState<List<SolfaTypeModel>> solfaStatus;
  final StatusState<List<GetEmployeeModel>> employeeListStatus;
  final StatusState<AddNewSolfaResponseModel> loanRequestStatus;
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveSolfaRequestsStatus;
  final StatusState<UpdateSolfaResponseModel> updataSolfaStatus;
  // بدل السكن
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveBadalSakanRequestsStatus;
  final StatusState<HousingAllowanceResponse> housingAllowanceStatus;
  final StatusState<UpdateHousingAllowanceResponse> updataHousingAllowanceStatus;
  // استقالة
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveResignationRequestsStatus;
  final StatusState<ResignationResponseModel> resignationStatus;
  final StatusState<UpdateResignationResponse> updataResignationStatus;

  /// سيارة
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveCarRequestsStatus;
  final StatusState<List<CarTypeModel>> carTypeStatus;
  final StatusState<AddNewCarResponseModel> addnewCarStatus;
  final StatusState<UpdateCarResponseModel> updataCarStatus;

  ///طلب نقل
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveTransferRequestsStatus;
  final StatusState<List<DepartmentModel>> departmentStatus;
  final StatusState<List<BranchDataModel>> branchStatus;
  final StatusState<List<ProjectsDataModel>> projectStatus;
  final StatusState<AddNewTransferResponseModel> addnewTransferStatus;
  final StatusState<UpdateTransferResponseModel> updataTransferStatus;
  // طلب تذاكر
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveTicketRequestsStatus;
  final StatusState<TicketResponse> addnewTicketStatus;
  final StatusState<UpdateTicketsResponseModel> updataTicketStatus;
  final StatusState<EmployeechangephotoResponse>? employeechangephoto;
  //طلب عام
  final StatusState<CheckEmpHaveRequestsModel> checkEmpHaveGeneralRequestsStatus;
  final StatusState<AddNewDynamicOrderResponse> addnewGeneralStatus;
  final StatusState<UpdataNewDynamicOrderResponse> updataGeneralStatus;
  const ServicesState({
    this.leavesStatus = const StatusState.initial(),
    this.employeesStatus = const StatusState.initial(),
    this.employeeVacationsStatus = const StatusState.initial(),
    this.employeeBalStatus = const StatusState.initial(),
    this.submitVacationStatus = const StatusState.initial(),
    this.checkEmpHaveRequestsStatus = const StatusState.initial(),
    this.servicesStatus = const StatusState.initial(),
    this.services = const StatusState.initial(),
    this.updataVacationStatus = const StatusState.initial(),
    this.allservicesStatus = const StatusState.initial(),
    this.vacationBackStatus = const StatusState.initial(),
    this.vacationBackAddStatus = const StatusState.initial(),
    this.checkEmpHaveBackRequestsStatus = const StatusState.initial(),
    this.solfaStatus = const StatusState.initial(),
    this.employeeListStatus = const StatusState.initial(),
    this.loanRequestStatus = const StatusState.initial(),
    this.checkEmpHaveSolfaRequestsStatus = const StatusState.initial(),
    this.updataVacationBackStatus = const StatusState.initial(),
    this.updataSolfaStatus = const StatusState.initial(),
    this.checkEmpHaveBadalSakanRequestsStatus = const StatusState.initial(),
    this.checkEmpHaveResignationRequestsStatus = const StatusState.initial(),
    this.housingAllowanceStatus = const StatusState.initial(),
    this.resignationStatus = const StatusState.initial(),
    this.updataHousingAllowanceStatus = const StatusState.initial(),
    this.updataResignationStatus = const StatusState.initial(),
    this.checkEmpHaveCarRequestsStatus = const StatusState.initial(),
    this.carTypeStatus = const StatusState.initial(),
    this.addnewCarStatus = const StatusState.initial(),
    this.updataCarStatus = const StatusState.initial(),
    this.checkEmpHaveTransferRequestsStatus = const StatusState.initial(),
    this.departmentStatus = const StatusState.initial(),
    this.branchStatus = const StatusState.initial(),
    this.projectStatus = const StatusState.initial(),
    this.addnewTransferStatus = const StatusState.initial(),
    this.updataTransferStatus = const StatusState.initial(),
    this.checkEmpHaveTicketRequestsStatus = const StatusState.initial(),
    this.addnewTicketStatus = const StatusState.initial(),
    this.updataTicketStatus = const StatusState.initial(),
    this.uploadedFilesStatus = const StatusState.initial(),
    this.deleteattachmentStatus = const StatusState.initial(),
    this.vacationAttachmentsStatus = const StatusState.initial(),
    this.imageFileNameStatus = const StatusState.initial(),
    this.employeechangephoto = const StatusState.initial(),
    this.checkEmpHaveGeneralRequestsStatus = const StatusState.initial(),
    this.addnewGeneralStatus = const StatusState.initial(),
    this.updataGeneralStatus = const StatusState.initial(),
  });

  ServicesState copyWith({
    StatusState<List<VacationTypeModel>>? leavesStatus,
    StatusState<List<EmployeeModel>>? employeesStatus,
    StatusState<List<EmployeeVacationModel>>? employeeVacationsStatus,
    StatusState<List<EmployeeBalModel>>? employeeBalStatus,
    StatusState<RequestLeaveResponseModel>? submitVacationStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveRequestsStatus,
    StatusState<List<ServiceModel>>? servicesStatus,
    StatusState<DeleteServiceResponseModel>? services,
    StatusState<DeleteServiceResponseModel>? deleteattachmentStatus,
    StatusState<RequestLeaveUpdataResponseModel>? updataVacationStatus,
    StatusState<List<ALLServiceModel>>? allservicesStatus,
    StatusState<List<VacationBackRequestModel>>? vacationBackStatus,
    StatusState<AddNewVacationBackResponseModel>? vacationBackAddStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveBackRequestsStatus,
    StatusState<List<SolfaTypeModel>>? solfaStatus,
    StatusState<List<GetEmployeeModel>>? employeeListStatus,
    StatusState<AddNewSolfaResponseModel>? loanRequestStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveSolfaRequestsStatus,
    StatusState<UpdateVacationResponseBackModel>? updataVacationBackStatus,
    StatusState<UpdateSolfaResponseModel>? updataSolfaStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveBadalSakanRequestsStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveResignationRequestsStatus,
    StatusState<HousingAllowanceResponse>? housingAllowanceStatus,
    StatusState<ResignationResponseModel>? resignationStatus,
    StatusState<UpdateHousingAllowanceResponse>? updataHousingAllowanceStatus,
    StatusState<UpdateResignationResponse>? updataResignationStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveCarRequestsStatus,
    StatusState<List<CarTypeModel>>? carTypeStatus,
    StatusState<AddNewCarResponseModel>? addnewCarStatus,
    StatusState<UpdateCarResponseModel>? updataCarStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveTransferRequestsStatus,
    StatusState<List<DepartmentModel>>? departmentStatus,
    StatusState<List<BranchDataModel>>? branchStatus,
    StatusState<List<ProjectsDataModel>>? projectStatus,
    StatusState<AddNewTransferResponseModel>? addnewTransferStatus,
    StatusState<UpdateTransferResponseModel>? updataTransferStatus,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveTicketRequestsStatus,
    StatusState<TicketResponse>? addnewTicketStatus,
    StatusState<UpdateTicketsResponseModel>? updataTicketStatus,
    StatusState<List<String>>? uploadedFilesStatus,
    StatusState<List<VacationAttachmentItem>>? vacationAttachmentsStatus,
    StatusState<String>? imageFileNameStatus,
    StatusState<EmployeechangephotoResponse>? employeechangephoto,
    StatusState<CheckEmpHaveRequestsModel>? checkEmpHaveGeneralRequestsStatus,
    StatusState<AddNewDynamicOrderResponse>? addnewGeneralStatus,
    StatusState<UpdataNewDynamicOrderResponse>? updataGeneralStatus,
  }) {
    return ServicesState(
      leavesStatus: leavesStatus ?? this.leavesStatus,
      employeesStatus: employeesStatus ?? this.employeesStatus,
      employeeVacationsStatus: employeeVacationsStatus ?? this.employeeVacationsStatus,
      employeeBalStatus: employeeBalStatus ?? this.employeeBalStatus,
      submitVacationStatus: submitVacationStatus ?? this.submitVacationStatus,
      checkEmpHaveRequestsStatus: checkEmpHaveRequestsStatus ?? this.checkEmpHaveRequestsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      services: services ?? this.services,
      updataVacationStatus: updataVacationStatus ?? this.updataVacationStatus,
      allservicesStatus: allservicesStatus ?? this.allservicesStatus,
      vacationBackStatus: vacationBackStatus ?? this.vacationBackStatus,
      vacationBackAddStatus: vacationBackAddStatus ?? this.vacationBackAddStatus,
      checkEmpHaveBackRequestsStatus:
          checkEmpHaveBackRequestsStatus ?? this.checkEmpHaveBackRequestsStatus,
      solfaStatus: solfaStatus ?? this.solfaStatus,
      employeeListStatus: employeeListStatus ?? this.employeeListStatus,
      loanRequestStatus: loanRequestStatus ?? this.loanRequestStatus,
      checkEmpHaveSolfaRequestsStatus:
          checkEmpHaveSolfaRequestsStatus ?? this.checkEmpHaveSolfaRequestsStatus,
      updataVacationBackStatus: updataVacationBackStatus ?? this.updataVacationBackStatus,
      updataSolfaStatus: updataSolfaStatus ?? this.updataSolfaStatus,
      checkEmpHaveBadalSakanRequestsStatus:
          checkEmpHaveBadalSakanRequestsStatus ?? this.checkEmpHaveBadalSakanRequestsStatus,
      checkEmpHaveResignationRequestsStatus:
          checkEmpHaveResignationRequestsStatus ?? this.checkEmpHaveResignationRequestsStatus,
      housingAllowanceStatus: housingAllowanceStatus ?? this.housingAllowanceStatus,
      resignationStatus: resignationStatus ?? this.resignationStatus,
      updataHousingAllowanceStatus:
          updataHousingAllowanceStatus ?? this.updataHousingAllowanceStatus,
      updataResignationStatus: updataResignationStatus ?? this.updataResignationStatus,
      checkEmpHaveCarRequestsStatus:
          checkEmpHaveCarRequestsStatus ?? this.checkEmpHaveCarRequestsStatus,
      carTypeStatus: carTypeStatus ?? this.carTypeStatus,
      addnewCarStatus: addnewCarStatus ?? this.addnewCarStatus,
      updataCarStatus: updataCarStatus ?? this.updataCarStatus,
      checkEmpHaveTransferRequestsStatus:
          checkEmpHaveTransferRequestsStatus ?? this.checkEmpHaveTransferRequestsStatus,
      departmentStatus: departmentStatus ?? this.departmentStatus,
      branchStatus: branchStatus ?? this.branchStatus,
      projectStatus: projectStatus ?? this.projectStatus,
      addnewTransferStatus: addnewTransferStatus ?? this.addnewTransferStatus,
      updataTransferStatus: updataTransferStatus ?? this.updataTransferStatus,
      checkEmpHaveTicketRequestsStatus:
          checkEmpHaveTicketRequestsStatus ?? this.checkEmpHaveTicketRequestsStatus,
      addnewTicketStatus: addnewTicketStatus ?? this.addnewTicketStatus,
      updataTicketStatus: updataTicketStatus ?? this.updataTicketStatus,
      uploadedFilesStatus: uploadedFilesStatus ?? this.uploadedFilesStatus,
      deleteattachmentStatus: deleteattachmentStatus ?? this.deleteattachmentStatus,
      vacationAttachmentsStatus: vacationAttachmentsStatus ?? this.vacationAttachmentsStatus,
      imageFileNameStatus: imageFileNameStatus ?? this.imageFileNameStatus,
      employeechangephoto: employeechangephoto ?? this.employeechangephoto,
      checkEmpHaveGeneralRequestsStatus:
          checkEmpHaveGeneralRequestsStatus ?? this.checkEmpHaveGeneralRequestsStatus,
      addnewGeneralStatus: addnewGeneralStatus ?? this.addnewGeneralStatus,
      updataGeneralStatus: updataGeneralStatus ?? this.updataGeneralStatus,
    );
  }

  @override
  List<Object?> get props => [
    leavesStatus,
    employeesStatus,
    employeeVacationsStatus,
    employeeBalStatus,
    submitVacationStatus,
    checkEmpHaveRequestsStatus,
    servicesStatus,
    services,
    updataVacationStatus,
    allservicesStatus,
    vacationBackStatus,
    vacationBackAddStatus,
    checkEmpHaveBackRequestsStatus,
    solfaStatus,
    employeeListStatus,
    loanRequestStatus,
    checkEmpHaveSolfaRequestsStatus,
    updataVacationBackStatus,
    updataSolfaStatus,
    checkEmpHaveBadalSakanRequestsStatus,
    checkEmpHaveResignationRequestsStatus,
    housingAllowanceStatus,
    resignationStatus,
    updataHousingAllowanceStatus,
    updataResignationStatus,
    checkEmpHaveCarRequestsStatus,
    carTypeStatus,
    addnewCarStatus,
    updataCarStatus,
    checkEmpHaveTransferRequestsStatus,
    departmentStatus,
    branchStatus,
    projectStatus,
    addnewTransferStatus,
    updataTransferStatus,
    checkEmpHaveTicketRequestsStatus,
    addnewTicketStatus,
    updataTicketStatus,
    uploadedFilesStatus,
    deleteattachmentStatus,
    deleteattachmentStatus,
    vacationAttachmentsStatus,
    imageFileNameStatus,
    employeechangephoto,
    checkEmpHaveGeneralRequestsStatus,
    addnewGeneralStatus,
    updataGeneralStatus,
  ];
}
