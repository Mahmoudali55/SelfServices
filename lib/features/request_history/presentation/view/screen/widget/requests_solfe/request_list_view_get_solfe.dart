import 'package:flutter/material.dart';
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_solfe/solfe_request_card.dart';

class RequestsListViewSolfe extends StatelessWidget {
  final List<SolfaItem> requests;
  final int empcoded;
  const RequestsListViewSolfe({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, index) => RequestCard(request: requests[index], empcoded: empcoded),
    );
  }
}
