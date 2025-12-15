String mapReqTypeToInitialType(int? reqType) {
  switch (reqType) {
    case 1: // إجازة
      return 'leavesRequest';

    case 18: // العودة من إجازة
      return 'backleave';

    case 4: // السلف
      return 'solfaRequest';

    case 8: // بدل السكن
      return 'deductionRequest';

    case 9: // السيارات
      return 'siraRequest';

    case 5: // الاستقالة
      return 'sakalRequest';

    case 19: // النقل
      return 'nqalRequest';

    case 7: // تذاكر السفر
      return 'tickets';

    case 2: // خطاب تعريف
    case 3: // الدورات التدريبية
    case 15: // طلبات التوظيف
    case 16: // تقييم موظف
    case 17: // إنذار موظف
      return 'requestgenerals';

    case 6: // جواز السفر
      return 'requestchangePhone'; // لو عندك شاشة مخصصة غيرها

    default:
      return 'leavesRequest';
  }
}
