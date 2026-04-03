import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Purple accent (Material 3–style, matches system date picker).
const Color _pickerPurple = Color(0xFF6750A4);

/// Light lavender surface (Material date picker background).
const Color _dialogSurface = Color(0xFFF3EDF7);

const Color _onSurface = Color(0xFF1C1B1F);
const Color _onSurfaceVariant = Color(0xFF49454F);

/// Result from [showUpdateHoursDatePicker].
class UpdateHoursDatePickResult {
  final bool isCancel;
  final bool isClear;
  final DateTime? date;

  UpdateHoursDatePickResult.cancel()
      : isCancel = true,
        isClear = false,
        date = null;

  UpdateHoursDatePickResult.clear()
      : isCancel = false,
        isClear = true,
        date = null;

  UpdateHoursDatePickResult.set(DateTime d)
      : isCancel = false,
        isClear = false,
        date = d;
}

Future<UpdateHoursDatePickResult?> showUpdateHoursDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<UpdateHoursDatePickResult>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _UpdateHoursDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _UpdateHoursDatePickerDialog extends StatefulWidget {
  const _UpdateHoursDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_UpdateHoursDatePickerDialog> createState() =>
      _UpdateHoursDatePickerDialogState();
}

class _UpdateHoursDatePickerDialogState
    extends State<_UpdateHoursDatePickerDialog> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    var d = widget.initialDate;
    if (d.isBefore(widget.firstDate)) d = widget.firstDate;
    if (d.isAfter(widget.lastDate)) d = widget.lastDate;
    _selected = d;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.light(
      primary: const Color.fromARGB(255, 47, 47, 48),
      onPrimary: Colors.white,
      surface: _dialogSurface,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme,
        dialogBackgroundColor: _dialogSurface,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 31, 31, 31)),
        ),
      ),
      child: Dialog(
        backgroundColor: _dialogSurface,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select date',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEE, MMM d').format(_selected),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: _onSurface,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ),
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (d) => setState(() => _selected = d),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(UpdateHoursDatePickResult.clear()),
                    child: const Text('CLEAR'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(UpdateHoursDatePickResult.cancel()),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(UpdateHoursDatePickResult.set(_selected)),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
