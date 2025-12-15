import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

class RequestHistoryDetilesScreen extends StatelessWidget {
  const RequestHistoryDetilesScreen({super.key, required this.request});
  final VacationRequestOrdersModel request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(
          context.locale.languageCode == "en" ? "Vacation Request Details" : "تفاصيل طلب الإجازة",
          style: AppTextStyle.text18MSecond(context),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: context.locale.languageCode == "en" ? "Employee Data" : "بيانات الموظف",
            items: {
              "اسم الموظف": request.empName,
              "اسم الموظف (EN)": request.empNameE,
              "الكود الوظيفي": request.empCode?.toString(),
              "اسم القسم": request.dName,
              "اسم القسم (EN)": request.dNameE,
            },
          ),
          _section(
            title: "بيانات الإجازة",
            items: {
              "رقم الطلب": request.vacRequestId?.toString(),
              "نوع الإجازة": request.vacTypeName,
              "تاريخ الطلب": request.vacRequestDate,
              "من تاريخ": request.vacRequestDateFrom,
              "إلى تاريخ": request.vacRequestDateTo,
              "عدد الأيام": request.vacDayCount?.toString(),
              "ملاحظات": request.strNotes,
            },
          ),
          _section(
            title: "حالة الطلب",
            items: {"الوصف": request.requestDesc, "رقم الحالة": request.reqDecideState?.toString()},
          ),
          _section(
            title: "الموظف البديل",
            items: {
              "اسم البديل": request.alternativeEmpName,
              "اسم البديل (EN)": request.alternativeEmpNameE,
              "كود البديل": request.alternativeEmpCode?.toString(),
            },
          ),
          _section(
            title: "المرفقات",
            items: {
              "اسم المرفق": (request.attachFileName?.isEmpty ?? true)
                  ? "لا يوجد"
                  : request.attachFileName,
            },
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Map<String, String?> items}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.entries.map((e) => _row(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 5, child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
