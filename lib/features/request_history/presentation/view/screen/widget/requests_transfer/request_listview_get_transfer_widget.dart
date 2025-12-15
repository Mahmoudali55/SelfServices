import 'package:flutter/material.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_transfer/request_item_Card.dart';

class RequestsListViewGetTransfer extends StatelessWidget {
  final List<GetAllTransferModel> requests;
  final int empcoded;
  const RequestsListViewGetTransfer({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, RoutesName.transferDetailsScreen, arguments: request);
          },
          child: RequestItemCard(request: request, empcoded: empcoded),
        );
      },
    );
  }
}
