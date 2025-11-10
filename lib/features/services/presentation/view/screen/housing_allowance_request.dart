import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_housing_allowance_model.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/housing_allowance/housing_allowance_form_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/housing_allowance/housing_allowance_save_button_widget.dart';

class HousingAllowanceRequestScreen extends StatefulWidget {
  const HousingAllowanceRequestScreen({super.key, this.empCode, this.model});
  final int? empCode;
  final GetAllHousingAllowanceModel? model;

  @override
  State<HousingAllowanceRequestScreen> createState() => _HousingAllowanceRequestScreenState();
}

class _HousingAllowanceRequestScreenState extends State<HousingAllowanceRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? selectedPlace = AppLocalKay.vacationPeriodType2.tr();
  final Map<String, int> travelPlaceValues = {
    AppLocalKay.vacationPeriodType2.tr(): 1,
    AppLocalKay.vacationPeriodType3.tr(): 2,
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    if (widget.model != null) {
      final model = widget.model!;
      _requestIdController.text = model.requestID.toString();
      _noteController.text = model.strNotes ?? '';
      _amountController.text = model.sakanAmount.toString();

      if (model.requestDate.isNotEmpty) {
        try {
          DateTime parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(model.requestDate);
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
        } catch (_) {
          _dateController.text = model.requestDate;
        }
      }

      selectedPlace = travelPlaceValues.entries
          .firstWhere((e) => e.value == model.amountType, orElse: () => const MapEntry('', 0))
          .key;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _requestIdController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.model != null;
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.vacation.tr(),
        helpText: AppLocalKay.housing_allowance_request_screen.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: HousingAllowanceForm(
          formKey: _formKey,
          dateController: _dateController,
          noteController: _noteController,
          amountController: _amountController,
          requestIdController: _requestIdController,
          travelPlaceValues: travelPlaceValues,
          selectedPlace: selectedPlace,
          onPlaceChanged: (val) => setState(() => selectedPlace = val),
        ),
      ),
      bottomNavigationBar: HousingAllowanceSaveButton(
        formKey: _formKey,
        empCode: widget.empCode,
        newrequest: () {
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());

          _noteController.clear();
          _amountController.clear();
        },
        isEdit: isEdit,
        controllers: HousingAllowanceControllers(
          dateController: _dateController,
          noteController: _noteController,
          amountController: _amountController,
          requestIdController: _requestIdController,
          selectedPlaceNotifier: ValueNotifier(selectedPlace),
          travelPlaceValues: travelPlaceValues,
        ),
      ),
    );
  }
}
