import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_history_body.dart';

class RequestHistoryScreen extends StatelessWidget {
  final int empCode;
  final String? initialType;
  
  const RequestHistoryScreen({super.key, required this.empCode, this.initialType,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, centerTitle: false, automaticallyImplyLeading: true),
      body: RequestHistoryBody(empCode: empCode, initialType: initialType, ),
    );
  }
}
