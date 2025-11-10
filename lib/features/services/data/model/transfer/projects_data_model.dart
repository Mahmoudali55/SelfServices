import 'dart:convert';

import 'package:equatable/equatable.dart';

class ProjectsDataModel extends Equatable {
  final int projectId;
  final String projectName;
  final String? projectNameEng;

  const ProjectsDataModel({required this.projectId, required this.projectName, this.projectNameEng});

  factory ProjectsDataModel.fromJson(Map<String, dynamic> json) {
    return ProjectsDataModel(
      projectId: json['ProjectId'] as int,
      projectName: json['ProjectName'] as String,
      projectNameEng: json['ProjectNameEng'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'ProjectId': projectId,
    'ProjectName': projectName,
    'ProjectNameEng': projectNameEng,
  };

  static List<ProjectsDataModel> listFromMap(Map<String, dynamic> json) {
    final dataString = json['Data'] as String? ?? '[]';
    final List<dynamic> decoded = jsonDecode(dataString);
    return decoded.map((e) => ProjectsDataModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [projectId, projectName, projectNameEng];
}
