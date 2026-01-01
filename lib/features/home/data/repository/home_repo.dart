import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:my_template/core/error/failures.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/features/home/data/model/get_news_model.dart';
import 'package:my_template/features/home/data/model/page_item_model.dart';
import 'package:my_template/features/home/data/model/service_Item_model.dart';

abstract interface class HomeRepo {
  Future<Either<Failure, PageItemModel>> vacationAdditionalPrivilages({
    required int pageID,
    required int empId,
  });
  Future<Either<Failure, List<GetNewsModel>>> getAllNews(int? sar);
}

class HomeRepoImp implements HomeRepo {
  final ApiConsumer apiConsumer;
  HomeRepoImp(this.apiConsumer);

  Future<List<ServiceItem>> getHomeData() async {
    return [
      ServiceItem(
        id: 1,
        nameAr: 'طلب الاجازة',
        nameEn: 'Leave Request',
        image: 'assets/global_icon/request_leave.png',
      ),
      ServiceItem(
        id: 2,
        nameAr: 'اشعار العودة من الاجازة',
        nameEn: 'Return from Leave Notification',
        image: 'assets/global_icon/request_an_advance.png',
      ),

      ServiceItem(
        id: 3,
        nameAr: 'طلب سلفة',
        nameEn: 'Loan Request',
        image: 'assets/global_icon/request_salfa.png',
      ),

      ServiceItem(
        id: 4,
        nameAr: 'طلب استقالة',
        nameEn: 'Resignation Request',
        image: 'assets/global_icon/request_resignation.png',
      ),

      ServiceItem(
        id: 5,
        nameAr: 'طلب صرف تذاكر',
        nameEn: 'Ticket Request',
        image: 'assets/global_icon/request_ticket.png',
      ),
      ServiceItem(
        id: 6,
        nameAr: 'طلب صرف بدل سكن',
        nameEn: 'Housing Allowance Request',
        image: 'assets/global_icon/request_Housing_allowance.png',
      ),
      ServiceItem(
        id: 7,
        nameAr: 'طلب سيارة',
        nameEn: 'Car Request',
        image: 'assets/global_icon/request_car.png',
      ),

      ServiceItem(
        id: 8,
        nameAr: 'طلب نقل',
        nameEn: 'Transfer Request',
        image: 'assets/global_icon/request_transfer.png',
      ),
      ServiceItem(
        id: 9,
        nameAr: ' طلب تغيير جهاز الموظف',
        nameEn: 'Device ID',
        image: 'assets/global_icon/device.png',
      ),
      ServiceItem(
        id: 10,
        nameAr: 'طلب عام',
        nameEn: 'General Request',
        image: 'assets/global_icon/request_general.png',
      ),
    ];
  }

  @override
  Future<Either<Failure, PageItemModel>> vacationAdditionalPrivilages({
    required int pageID,
    required int empId,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.vacationAdditionalPrivilagesPath,
          queryParameters: {'PageID': pageID, 'EmpId': empId},
        );
        final dynamic dataRaw = response['Data'];
        List<Map<String, dynamic>> dataList = [];

        if (dataRaw != null) {
          try {
            if (dataRaw is String) {
              final decoded = jsonDecode(dataRaw) as List<dynamic>;
              dataList = decoded.map((e) => e as Map<String, dynamic>).toList();
            } else if (dataRaw is List) {
              dataList = dataRaw.map((e) => e as Map<String, dynamic>).toList();
            }
          } catch (_) {
            dataList = [];
          }
        }

        final pageItem = dataList.isNotEmpty
            ? PageItemModel.fromJson(dataList[0])
            : const PageItemModel(
                ser: 0,
                userID: 0,
                userName: null,
                pageID: 0,
                pagePrivID: 0,
                appID: 0,
              );

        return pageItem;
      },
    );
  }

  @override
  Future<Either<Failure, List<GetNewsModel>>> getAllNews(int? ser) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getnews(ser: ser));

        return GetNewsModel.parseList(response);
      },
    );
  }
}
