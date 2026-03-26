import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomStepperHeader extends StatelessWidget {
  CustomStepperHeader({super.key});

  final CreateTyreController controller = Get.find<CreateTyreController>();

  final Color completedColor = const Color(0xFF2ECC71);
  final Color currentColor = const Color(0xFFFFC107);
  final Color upcomingColor = const Color(0xFFBDBDBD);
  final Color lineColor = const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.transparent,
        child: Row(
          children: List.generate(4, (index) {
            final bool isCompleted = controller.currentStep.value > index;
            final bool isCurrent = controller.currentStep.value == index;
            final bool isLast = index == 3;

            return Expanded(
              child: Row(
                children: [
                  _stepCircle(
                    index: index,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isCompleted ? completedColor : lineColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _stepCircle({
    required int index,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? completedColor
            : isCurrent
            ? currentColor
            : Colors.white,
        border: Border.all(
          color: isCompleted
              ? completedColor
              : isCurrent
              ? currentColor
              : upcomingColor,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
              (index + 1).toString(),
              style: TextStyle(
                color: isCurrent ? Colors.white : upcomingColor,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
