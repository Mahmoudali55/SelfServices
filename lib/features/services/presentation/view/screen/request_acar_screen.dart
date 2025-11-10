import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_cars_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/cars/car_request_form_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/cars/car_request_save_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';

class RequestACarScreen extends StatefulWidget {
  const RequestACarScreen({super.key, this.empCode, this.car});
  final int? empCode;
  final GetAllCarsModel? car;

  @override
  State<RequestACarScreen> createState() => _RequestACarScreenState();
}

class _RequestACarScreenState extends State<RequestACarScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initControllers();
    context.read<ServicesCubit>().getcarTypeList();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    if (widget.car != null) {
      final car = widget.car!;
      _requestIdController.text = car.requestID.toString();
      _carTypeController.text = car.carTypeID.toString();
      _reasonController.text = car.purpose ?? '';
      _noteController.text = car.strNotes ?? '';
      try {
        if (car.requestDate.isNotEmpty) {
          DateTime parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(car.requestDate);
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _requestIdController.dispose();
    _carTypeController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.car != null;
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.car.tr(),
        helpText: AppLocalKay.request_a_car_screen.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: CarRequestForm(
          formKey: _formKey,
          dateController: _dateController,
          carTypeController: _carTypeController,
          reasonController: _reasonController,
          noteController: _noteController,
          requestIdController: _requestIdController,
        ),
      ),
      bottomNavigationBar: CarRequestSaveButton(
        formKey: _formKey,
        empCode: widget.empCode,
        newrequest: () {
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
          _carTypeController.clear();
          _reasonController.clear();
          _noteController.clear();
        },
        isEdit: isEdit,
        carRequestControllers: CarRequestControllers(
          dateController: _dateController,
          carTypeController: _carTypeController,
          reasonController: _reasonController,
          noteController: _noteController,
          requestIdController: _requestIdController,
        ),
      ),
    );
  }
}
