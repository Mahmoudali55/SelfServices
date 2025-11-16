import 'package:equatable/equatable.dart';

class TicketRequest extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int ticketCount;
  final String travelDate;
  final String? travelDateH;
  final String ticketPath;
  final int goBack; // 1 = ذهاب وعودة, 2 = ذهاب فقط
  final String strNotes;

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
  });

  // لتحويل من JSON
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
    );
  }

  // لتحويل إلى JSON
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
  ];
}

// مثال دالة لإضافة طلب جديد
Future<void> addNewTicketRequest(TicketRequest request) async {
  final Map<String, dynamic> payload = request.toJson();



  // مثال وهمي
  await Future.delayed(const Duration(seconds: 1));

}
