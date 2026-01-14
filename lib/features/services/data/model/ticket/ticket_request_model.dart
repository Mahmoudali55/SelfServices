import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class TicketRequest extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int ticketCount;
  final String travelDate;
  final String? travelDateH;
  final String ticketPath;
  final int goBack;
  final String strNotes;
  final List<AttachmentModel> attachment;

  const TicketRequest({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.ticketCount,
    required this.travelDate,
    this.travelDateH,
    required this.ticketPath,
    required this.goBack,
    required this.strNotes,
    required this.attachment,
  });

  factory TicketRequest.fromJson(Map<String, dynamic> json) {
    return TicketRequest(
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      ticketCount: json['Ticketcount'] ?? 1,
      travelDate: json['TravelDate'] ?? '',
      travelDateH: json['TravelDateH'],
      ticketPath: json['TicketPath'] ?? '',
      goBack: json['Goback'] ?? 1,
      strNotes: json['StrNotes'] ?? '',
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmpCode': empCode,
      'RequestDate': requestDate,
      'RequestDateH': requestDateH,
      'Ticketcount': ticketCount,
      'TravelDate': travelDate,
      'TravelDateH': travelDateH,
      'TicketPath': ticketPath,
      'Goback': goBack,
      'StrNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    empCode,
    requestDate,
    requestDateH,
    ticketCount,
    travelDate,
    travelDateH,
    ticketPath,
    goBack,
    strNotes,
    attachment,
  ];
}

Future<void> addNewTicketRequest(TicketRequest request) async {
  await Future.delayed(const Duration(seconds: 1));
}
