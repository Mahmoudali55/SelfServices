import 'package:equatable/equatable.dart';

class DeleteRequestSolfaModel extends Equatable {
  final bool data;

  const DeleteRequestSolfaModel({required this.data});

  factory DeleteRequestSolfaModel.fromJson(Map<String, dynamic>? json) {
    return DeleteRequestSolfaModel(data: json?['Data'] == true);
  }

  Map<String, dynamic> toJson() => {'Data': data};

  @override
  List<Object?> get props => [data];
}
