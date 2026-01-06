import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/request_leave/all_service_model.dart';
import 'package:my_template/features/services/data/model/request_leave/service_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';

Map<String, String> parseService(dynamic service, {required bool isArabic}) {
  String id = '';
  String desc = '';

  if (service is ServiceModel) {
    id = service.id.toString();
    desc = isArabic
        ? (service.serviceDesc ?? '')
        : (service.serviceDescEn ?? service.serviceDesc ?? '');
  } else if (service is ALLServiceModel) {
    id = service.id.toString();
    desc = service.serviceDesc ?? '';
  } else if (service is Map<String, dynamic>) {
    id = (service['Id'] ?? '').toString();
    desc = (service['ServiceDesc'] ?? '').toString();
  }

  if (desc.toLowerCase() == 'null' || desc.trim().isEmpty) {
    desc = 'null';
  }

  final regex = RegExp(r'{ServiceDesc: (.*?), Id: (\d+)}');
  final match = regex.firstMatch(desc);
  if (match != null) {
    desc = match.group(1) ?? desc;
    id = match.group(2) ?? id;
  }

  return {'id': id, 'servcdesc': desc};
}

Future<void> showServicesBottomSheet({
  required BuildContext context,
  required TextEditingController controller,
  required List<Map<String, String>> selectedServices,
  required List<dynamic> apiServices,
  required Function(List<Map<String, String>>) onServicesUpdated,
  required int requestId,
}) async {
  final TextEditingController manualController = TextEditingController();
  final List<Map<String, String>> tempSelected = List.from(selectedServices);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void addManualService() {
            final text = manualController.text.trim();
            if (text.isNotEmpty) {
              setState(() {
                tempSelected.add({'id': '-1', 'servcdesc': text});
                manualController.clear();
              });
            }
          }

          void toggleService(dynamic service) {
            final map = parseService(service, isArabic: context.locale.languageCode != 'en');
            final isSelected = tempSelected.any((s) => s['id'] == map['id']);
            setState(() {
              if (isSelected) {
                tempSelected.removeWhere((s) => s['id'] == map['id']);
              } else {
                tempSelected.add(map);
              }
            });
          }

          return SizedBox(
            height: 600,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 10,
                right: 10,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    AppLocalKay.servicess1.tr(),
                    style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormField(
                          controller: manualController,
                          hintText: AppLocalKay.enterServiceName.tr(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: addManualService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.greenColor(context),
                          fixedSize: const Size(100, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          AppLocalKay.add.tr(),
                          style: AppTextStyle.text16MSecond(context, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (apiServices.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: apiServices.length,
                        itemBuilder: (context, index) {
                          final service = apiServices[index];
                          final map = parseService(
                            service,
                            isArabic: context.locale.languageCode != 'en',
                          );
                          final isSelected = tempSelected.any((s) => s['id'] == map['id']);

                          return ListTile(
                            title: Text(map['servcdesc'] ?? ''),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: AppColor.greenColor(context))
                                : const Icon(Icons.circle_outlined),
                            onTap: () => toggleService(service),
                          );
                        },
                      ),
                    ),
                  if (tempSelected.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              AppLocalKay.number.tr(),
                              style: AppTextStyle.textFormStyle(context),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              AppLocalKay.service.tr(),
                              style: AppTextStyle.textFormStyle(context),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              AppLocalKay.delete.tr(),
                              style: AppTextStyle.textFormStyle(context),
                            ),
                          ),
                        ],
                        rows: tempSelected.asMap().entries.map((entry) {
                          final index = entry.key;
                          final service = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(service['servcdesc'] ?? '')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final id = service['id'] ?? '-1';
                                    if (id != '-1') {
                                      final cubit = context.read<ServicesCubit>();
                                      final serviceId = int.tryParse(id) ?? -1;

                                      await cubit.deleteService(
                                        serviceId: serviceId,
                                        context: context,
                                        requestId: requestId,
                                      );

                                      setState(() {
                                        tempSelected.removeWhere((s) => s['id'] == id);
                                        apiServices.removeWhere(
                                          (s) =>
                                              parseService(
                                                s,
                                                isArabic: context.locale.languageCode != 'en',
                                              )['id'] ==
                                              id,
                                        );
                                      });
                                    } else {
                                      setState(() {
                                        tempSelected.remove(service);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      controller.text = tempSelected.map((e) => e['servcdesc'] ?? '').join(', ');
                      onServicesUpdated(List<Map<String, String>>.from(tempSelected));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor(context),
                      fixedSize: const Size(100, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      AppLocalKay.confirm.tr(),
                      style: AppTextStyle.text16MSecond(context, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
