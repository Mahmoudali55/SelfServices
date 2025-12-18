import 'package:flutter/material.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/resignation/resignation_request_Item_widget.dart';

class RequestsListViewAllResignation extends StatelessWidget {
  final List<GetAllResignationModel> requests;
  final int empcoded;

  const RequestsListViewAllResignation({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutesName.resignationDetailsScreen,
            arguments: requests[index],
          );
        },
        child: ResignationRequestItem(request: requests[index], empcoded: empcoded),
      ),
    );
  }
}
