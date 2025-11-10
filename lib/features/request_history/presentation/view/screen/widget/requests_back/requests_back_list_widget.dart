import 'package:flutter/material.dart';
import 'package:my_template/features/request_history/data/model/get_requests_vacation_back.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_back/request_back_card.dart';

class RequestsBackListView extends StatelessWidget {
  final List<GetRequestVacationBackModel> requests;
  final int empcoded;

  const RequestsBackListView({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, index) => RequestBackCard(request: requests[index], empcoded: empcoded),
    );
  }
}
