import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}
class _RateAppScreenState extends State<RateAppScreen> {
  double rating = 0.0;
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.rate_app.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalKay.how_was_your_experience.tr(),
              style: AppTextStyle.text16MSecond(context),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      rating = index + 1.0;
                    });
                  },
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: (index < rating) ? Colors.amber : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            CustomFormField(
              controller: feedbackController,
              maxLines: 4,
              title: AppLocalKay.notes.tr(),
              hintText: AppLocalKay.write_notes.tr(),
            ),
            const SizedBox(height: 30),
            CustomButton(
              radius: 12,
              onPressed: () {
                _showThankYouDialog(context);
              },
              text: AppLocalKay.send_rating.tr(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(AppLocalKay.thank.tr(), style: AppTextStyle.text18MSecond(context)),
        content: Text(
          rating == 0
              ? '${AppLocalKay.your_notes_received.tr()}'
              : '${AppLocalKay.your_rating_has_been_recorded.tr()} ⭐ $rating',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalKay.good.tr())),
        ],
      ),
    );
  }
}
