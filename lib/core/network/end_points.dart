class EndPoints {
  static const String login = '/token';
  static const String empLogin = '/DeltagroupService/Users/Emp_login';
  static const String users = 'users';
  static String detailsUser(int id) => '$users/$id';
  static const String vacationAdditionalPrivilagesPath =
      '/DeltagroupService/Vacation/Getvacation_AdditionalPrivilages';
  static String vacationType = '/DeltagroupService/Vacation/Getvacation_Type';
  static String employeewithPrivilages(int empcode, int privid) =>
      '/DeltagroupService/Vacation/GetemployeewithPrivilages?empcode=$empcode&privid=$privid';
  static String employeevacationbalance(int empcode, String bnDate, String edDate) =>
      '/DeltagroupService/Vacation/Getemployeevacationbalance?Empid=$empcode&BN_Date=$bnDate&Ed_Date=$edDate';
  static String employeebal(int Empid, String bnDate, String edDate) =>
      '/DeltagroupService/Vacation/Getemployeebal?Empid=$Empid&BN_Date=$bnDate&Ed_Date=$edDate';
  static const String addnewvacation = '/DeltagroupService/Vacation/addnewvacation';
  static String checkEmpHaveRequestsInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=1&empcode=$Empid';
  static String getAllVacationdetails({int? requestId, required int empcode}) {
    if (requestId != null) {
      return '/DeltagroupService/Vacation/GetAllVacation?RequestId=$requestId&empcode=$empcode';
    }
    return '/DeltagroupService/Vacation/GetAllVacation?RequestId=&empcode=$empcode';
  }

  static String getAllVacationes({int? empId}) {
    return '/DeltagroupService//DeltagroupService/Follow/GetAllVacation?EmpId=$empId';
  }

  static String vacationservice({int? requestId}) {
    if (requestId != null) {
      return '/DeltagroupService/Vacation/GetVacationservice?RequestId=$requestId';
    }
    return '/DeltagroupService/Vacation/GetVacationservice?RequestId=';
  }

  static String vacationallservice() {
    return '/DeltagroupService/Vacation/Getallservice';
  }

  static const String updatenewvacation = '/DeltagroupService/Vacation/updatevacation';
  static const String deletevacation = '/DeltagroupService/Vacation/transDel';
  static const String deleteServices = '/DeltagroupService/Vacation/ServiceDel';
  static const String uploadFiles = '/DeltagroupService/Vacation/UploadFiles';
  static const String deleteFile = '/DeltagroupService/Vacation/AttachmentDel';
  static String getattachment({required int requestId, required int attchmentType}) =>
      '/DeltagroupService/Vacation/GetVacationAttachment?RequestId=$requestId&AttchmentTypeid=$attchmentType';
  static String imageFileName({required String imageFileName}) =>
      '/DeltagroupService/Users/userimge?imageFileName=$imageFileName';
  //العوده من الاجازه///
  static String vacationBack(int Empid) =>
      '/DeltagroupService/VacationBack/GetempVacation?empcode=$Empid';
  static const String addNewVacationBack = '/DeltagroupService/VacationBack/addnewvacationBack';
  static String checkEmpHaveBackRequestsInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=18&empcode=$Empid';

  static String getempVacationBack(int Empid) =>
      '/DeltagroupService/VacationBack/GetempVacationBack?RequestId=&empcode=$Empid';
  static const String deletevacationBack = '/DeltagroupService/VacationBack/transDel';
  static const String updatenewBackvacation = '/DeltagroupService/VacationBack/updatevacationBack';

  /// السلفة ///
  static const String SofaType = '/DeltagroupService/Solfa/GetSolfaType';
  static const String getEmployee = '/DeltagroupService/Solfa/GetEmployee';
  static const String addnewSolfa = '/DeltagroupService/Solfa/addnewSolfa';
  static String getSolfa({required int empcode}) {
    return '/DeltagroupService/Solfa/GetSolfa?RequestId&empcode=$empcode';
  }

  static const String updateSolfa = '/DeltagroupService/Solfa/updateSolfa';

  static const String deleteSolfa = '/DeltagroupService/Solfa/SolfaDel';

  static String checkEmpHaveSolfaRequestsInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=4&empcode=$Empid';

  ///بيانات الموظفين///
  static String getprofile(int Empid) => '/DeltagroupService/Users/GetEmpData?empcode=$Empid';
  static const String employeechangephoto = '/DeltagroupService/Users/Employeechangephoto';

  ///بدل سكن
  static String checkEmpHaveBadalSakanInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=8&empcode=$Empid';
  static const String addnewHousingallowance =
      '/DeltagroupService/Housing_allowance/addnewHousing_allowance';
  static String getAllHousingAllowanceInProccissing(int Empid) =>
      'https://delta-asg.com:57513/DeltagroupService/Housing_allowance/GetHousing_allowance?RequestId=&empcode=$Empid';
  static const String deleteHousingAllowance =
      '/DeltagroupService/Housing_allowance/Housing_allowanceDel';
  static const String updateHousingAllowance =
      '/DeltagroupService/Housing_allowance/updateHousing_allowance';
  //استقالة
  static String checkEmpHaveResignationInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=5&empcode=$Empid';
  static const String addnewResignation = '/DeltagroupService/Terminate/addnewTerminate';
  static String getAllResignationInProccissing(int Empid) =>
      'https://delta-asg.com:57513/DeltagroupService/Terminate/GetTerminate?RequestId=&empcode=$Empid';
  static const String deleteResignation = '/DeltagroupService/Terminate/TerminateDel';
  static const String updateResignation = '/DeltagroupService/Terminate/UpdateTerminate';
  // سيارة
  static String checkEmpHaveCarInProccissing(int Empid) =>
      '/DeltagroupService/Cars/CheckData?EmpId=$Empid';
  static const String carType = '/DeltagroupService/Cars/GetCarType';
  static const String addNewCar = '/DeltagroupService/Cars/addnewCar';
  static String getAllCars(int Empid) =>
      '/DeltagroupService/Cars/Getcars?RequestId=&empcode=$Empid';
  static const String deleteCar = '/DeltagroupService/Cars/CarsDel';
  static const String updateCar = '/DeltagroupService/Cars/updateCar';
  // طلب نقل
  static String checkEmpHaveTransferInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=18&empcode=$Empid';
  static const String getDepartmentData = '/DeltagroupService/Transfer/GetDepartmentData';
  static const String getProjectsData = '//DeltagroupService/Transfer/GetProjectsData';
  static String getBranchData(int Empid) =>
      '/DeltagroupService/Transfer/GetBranchData?DeptCode=$Empid';
  static const String addnewTransfer = '/DeltagroupService/Transfer/addnewTransfer';
  static String getAllTransfer(int Empid) =>
      '/DeltagroupService/Transfer/GetTransfer?RequestId=&empcode=$Empid';
  static const String deleteTransfer = '/DeltagroupService/Transfer/TransferDel';
  static const String updateTransfer = '/DeltagroupService/Transfer/updateTransfer';

  ///عدد الطلبات المعلقة
  static String getRequestsCount(int Empid) =>
      '/DeltagroupService/Users/RequestsCountToDecide?empcode=$Empid';
  // طلبات اللتي يتتطلب  البت فيها

  static String vacationRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/VactionRequestToDecide?empcode=$Empid';

  static String vacationBackRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/VactionBackRequestToDecide?empcode=$Empid';

  static String solfaRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/SolfaRequestToDecide?empcode=$Empid';

  static String resignationRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/TerminateRequestToDecide?empcode=$Empid';

  static String ticketRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/TicketRequestToDecide?empcode=$Empid';

  static String dynamicRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/DynamicRequestToDecide?empcode=$Empid';

  static String carRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/CarsRequestToDecide?empcode=$Empid';

  static String housingAllowanceRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/BadalSakanRequestToDecide?empcode=$Empid';
  static String employeeRequestsNotify(int Empid) =>
      '/DeltagroupService/Users/EmployeeRequestsnotify?empcode=$Empid';

  static String transferRequestToDecide(int Empid) =>
      '/DeltagroupService/Users/TransferRequestToDecide?empcode=$Empid';
  static const String decidingIn = '/DeltagroupService/Users/DecidingInRequest';
  // تغير كلمه السر
  static const String changePassword = '/DeltagroupService/Users/Changepassword';
  static String getnews({int? ser}) {
    if (ser != null) {
      return '/DeltagroupService/News/GetNews?Ser=$ser';
    }
    return '/DeltagroupService/News/GetNews?Ser=';
  }
  //طلب تذاكر

  static String checkEmpHaveTicketInProccissing(int Empid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=7&empcode=$Empid';
  static const String addnewTicket = '/DeltagroupService/Tickets/addnewTickets';
  static String getAllTickets(int Empid) =>
      '/DeltagroupService/Tickets/GetTickets?RequestId=&empcode=$Empid';
  static const String deleteTicket = '/DeltagroupService/Tickets/TicketsDel';
  static const String updateTicket = '/DeltagroupService/Tickets/update_Tickets';
  //البصمه
  static const String addpresenceFinger = '/DeltagroupService/Users/timesheet';
  static const String addabsenceFinger = '/DeltagroupService/Users/timesheetout';
  static String getAllTimesheet = '/DeltagroupService/Users/Employeetimesheet';
  static const String employeeSalary = '/DeltagroupService/Users/EmployeeSalary';

  static String getEmployeeMobileSerialno(int Empid) =>
      '/DeltagroupService/Users/Employeeserialno?empcode=$Empid';
  static String getimageFileName(String fileName) =>
      '/DeltagroupService/Users/userimge?imageFileName=$fileName';
  // طلب عام
  static String checkEmpHaveTicketInProccissingGeneral(int Empid, int typeid) =>
      '/DeltagroupService/Vacation/CheckEmpHaveRequestsInProccissing?typeid=$typeid&empcode=$Empid';
  static const String addnewRequestGeneral = '/DeltagroupService/Dynamic/addnewDynamicorder';
  static String getAllRequestsGeneral(int Empid, int typeid) =>
      '/DeltagroupService/Dynamic/GetDynamicorder?RequestId=&empcode=$Empid&RequestType=$typeid';
  static const String deleteRequestGeneral = '/DeltagroupService/Dynamic/DynamicorderDel';
  static const String updateRequestGeneral = '/DeltagroupService/Dynamic/update_Dynamicorder';
  static String requestDynamicCount(int Empid, int typeid) =>
      '/DeltagroupService/Users/DynamicRequestsCountToDecide?empcode=$Empid&RequestType=$typeid';
  static String employeefacephoto = '/DeltagroupService/Users/Employeefacephoto';
  static String employeeFaceImage(int empCode) =>
      '/DeltagroupService/Users/Employeefaceimage?empcode=$empCode';
}
