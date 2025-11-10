import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_cars_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_housing_allowance_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_ticket_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/request_history/data/model/get_dynamic_order_model.dart';
import 'package:my_template/features/request_history/data/model/get_requests_vacation_back.dart';
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/dynamic_order/requests_listview_dynamic_order.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/housing_allowance/requests_listView_housing_allowance.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_car/requests_listView_all_cars.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_ticket/request_ticket.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_back/requests_back_list_widget.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_solfe/request_list_view_get_solfe.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_transfer/request_listview_get_transfer_widget.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_vacations/requests_list_view_all_vacations.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/resignation/requests_listView_all_resignation.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

class RequestListView extends StatelessWidget {
  final List<dynamic> requests;
  final int empCode;

  const RequestListView({super.key, required this.requests, required this.empCode});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImages.assetsGlobalIconEmptyFolderIcon,
              height: 200,
              width: 200,
              color: AppColor.primaryColor(context),
            ),
            const Gap(10),
            Text(AppLocalKay.no_requests.tr()),
          ],
        ),
      );
    }

    final first = requests.first;
    if (first is VacationRequestOrdersModel) {
      return RequestsListViewAllVacations(
        requests: requests.cast<VacationRequestOrdersModel>(),
        empcoded: empCode,
      );
    } else if (first is GetRequestVacationBackModel) {
      return RequestsBackListView(
        requests: requests.cast<GetRequestVacationBackModel>(),
        empcoded: empCode,
      );
    } else if (first is SolfaItem) {
      return RequestsListViewSolfe(requests: requests.cast<SolfaItem>(), empcoded: empCode);
    } else if (first is GetAllHousingAllowanceModel) {
      return RequestsListViewAllHousingAllowance(
        requests: requests.cast<GetAllHousingAllowanceModel>(),
        empcoded: empCode,
      );
    } else if (first is GetAllResignationModel) {
      return RequestsListViewAllResignation(
        requests: requests.cast<GetAllResignationModel>(),
        empcoded: empCode,
      );
    } else if (first is GetAllCarsModel) {
      return RequestsListViewAllCars(requests: requests.cast<GetAllCarsModel>(), empcoded: empCode);
    } else if (first is GetAllTransferModel) {
      return RequestsListViewGetTransfer(
        requests: requests.cast<GetAllTransferModel>(),
        empcoded: empCode,
      );
    } else if (first is AllTicketModel) {
      return RequestsListViewTicket(requests: requests.cast<AllTicketModel>(), empcoded: empCode);
    } else if (first is DynamicOrderModel) {
      return RequestsListViewRequestGeneral(
        requests: requests.cast<DynamicOrderModel>(),
        empcoded: empCode,
      );
    } else {
      return const SizedBox();
    }
  }
}
