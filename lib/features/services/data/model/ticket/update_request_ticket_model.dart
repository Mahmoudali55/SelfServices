import 'package:equatable/equatable.dart';

class UpdateTicketsRequestModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int ticketCount;
  final String travelDate;
  final String? travelDateH;
  final String ticketPath;
  final int goBack; // 1 = ذهاب وعودة ، 2 = ذهاب فقط
  final String strNotes;

  const UpdateTicketsRequestModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.ticketCount,
    required this.travelDate,
    this.travelDateH,
    required this.ticketPath,
    required this.goBack,
    required this.strNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'Requestid': requestId,
      'EmpCode': empCode,
      'RequestDate': requestDate,
      'RequestDateH': requestDateH,
      'Ticketcount': ticketCount,
      'TravelDate': travelDate,
      'TravelDateH': travelDateH,
      'TicketPath': ticketPath,
      'Goback': goBack,
      'StrNotes': strNotes,
    };
  }

  factory UpdateTicketsRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateTicketsRequestModel(
      requestId: json['Requestid'],
      empCode: json['EmpCode'],
      requestDate: json['RequestDate'],
      requestDateH: json['RequestDateH'],
      ticketCount: json['Ticketcount'],
      travelDate: json['TravelDate'],
      travelDateH: json['TravelDateH'],
      ticketPath: json['TicketPath'],
      goBack: json['Goback'],
      strNotes: json['StrNotes'],
    );
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    ticketCount,
    travelDate,
    travelDateH,
    ticketPath,
    goBack,
    strNotes,
  ];
}
