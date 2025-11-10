import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/resignation/resignatin_save_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/resignation/resignation_form_widget.dart';

class ResignationRequestScreen extends StatefulWidget {
  const ResignationRequestScreen({super.key, this.empCode, this.resignationModel});
  final int? empCode;
  final GetAllResignationModel? resignationModel;

  @override
  State<ResignationRequestScreen> createState() => _ResignationRequestScreenState();
}

class _ResignationRequestScreenState extends State<ResignationRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _lastWorkController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    if (widget.resignationModel != null) {
      _requestIdController.text = widget.resignationModel?.requestID.toString() ?? '';
      _notesController.text = widget.resignationModel?.strNotes ?? '';
      _lastWorkController.text = widget.resignationModel?.lastWorkDate ?? '';
      try {
        if (widget.resignationModel!.requestDate.isNotEmpty) {
          DateTime parsedDate = DateFormat(
            'yyyy-MM-dd',
            'en',
          ).parse(widget.resignationModel!.requestDate);
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    _lastWorkController.dispose();
    _requestIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.resignation.tr(),
        helpText: AppLocalKay.resignation_help.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ResignationForm(
          formKey: _formKey,
          dateController: _dateController,
          lastWorkController: _lastWorkController,
          notesController: _notesController,
          requestIdController: _requestIdController,
        ),
      ),
      bottomNavigationBar: ResignationSaveButton(
        newrequest: () {
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
          _notesController.clear();
          _lastWorkController.clear();
        },
        formKey: _formKey,
        empCode: widget.empCode,
        resignationModel: widget.resignationModel,
        dateController: _dateController,
        lastWorkController: _lastWorkController,
        notesController: _notesController,
        requestIdController: _requestIdController,
      ),
    );
  }
}
