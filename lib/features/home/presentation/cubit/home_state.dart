import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/home/data/model/get_news_model.dart';
import 'package:my_template/features/home/data/model/page_item_model.dart';
import 'package:my_template/features/home/data/model/service_Item_model.dart';

class HomeState extends Equatable {
  final StatusState<List<ServiceItem>> servicesStatus;
  final StatusState<PageItemModel> vacationStatus;
  final StatusState<List<GetNewsModel>> newsStatus;

  const HomeState({
    this.servicesStatus = const StatusState.initial(),
    this.vacationStatus = const StatusState.initial(),
    this.newsStatus = const StatusState.initial(),
  });

  HomeState copyWith({
    StatusState<List<ServiceItem>>? servicesStatus,
    StatusState<PageItemModel>? vacationStatus,
    StatusState<List<GetNewsModel>>? newsStatus,
  }) {
    return HomeState(
      servicesStatus: servicesStatus ?? this.servicesStatus,
      vacationStatus: vacationStatus ?? this.vacationStatus,
      newsStatus: newsStatus ?? this.newsStatus,
    );
  }

  @override
  List<Object?> get props => [servicesStatus, vacationStatus, newsStatus];
}
