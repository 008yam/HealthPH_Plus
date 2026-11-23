import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class SelfReportWizardScaffold extends StatelessWidget {
  final int currentStep;
  final bool submitting;
  final PageController pageController;
  final List<String> stepTitles;
  final List<Widget> steps;

  final ValueChanged<int> onPageChanged;
  final GestureDragEndCallback onHorizontalDragEnd;
  final VoidCallback onClose;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const SelfReportWizardScaffold({
    super.key,
    required this.currentStep,
    required this.submitting,
    required this.pageController,
    required this.stepTitles,
    required this.steps,
    required this.onPageChanged,
    required this.onHorizontalDragEnd,
    required this.onClose,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  }) : assert(stepTitles.length == steps.length);

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == steps.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('Report Symptoms'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr('Close'),
                onPressed: submitting ? null : onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${context.tr("Step")} '
            '${currentStep + 1} '
            '${context.tr("of")} '
            '${steps.length}: '
            '${context.tr(stepTitles[currentStep])}',
            style: const TextStyle(color: AppTheme.mutedText),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(steps.length, (index) {
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == steps.length - 1 ? 0 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? AppTheme.primary
                        : AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: onHorizontalDragEnd,
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: onPageChanged,
                children: steps,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (currentStep > 0)
                OutlinedButton.icon(
                  onPressed: submitting ? null : onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.tr('Back')),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: submitting
                    ? null
                    : isLastStep
                    ? onSubmit
                    : onNext,
                icon: submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isLastStep ? Icons.send_outlined : Icons.arrow_forward,
                      ),
                label: Text(
                  context.tr(
                    submitting
                        ? 'Submitting...'
                        : isLastStep
                        ? 'Submit Self Report'
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
