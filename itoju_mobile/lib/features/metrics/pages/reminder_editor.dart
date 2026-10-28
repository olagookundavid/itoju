import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/services/reminder_coordinator.dart';

/// Units match what the Medication log offers, so a dose logged from a reminder
/// ("Mark as taken") shows up correctly there.
const List<String> kReminderUnits = ['mg', 'mcl', 'tsp'];

String prettyTime(String hhmm) {
  final p = parseHhmm(hhmm);
  if (p == null) return hhmm;
  return DateFormat.jm().format(DateTime(2000, 1, 1, p.hour, p.minute));
}

class ReminderEditorPage extends ConsumerStatefulWidget {
  const ReminderEditorPage({super.key, this.existing});
  final MedReminderModel? existing;

  @override
  ConsumerState<ReminderEditorPage> createState() => _ReminderEditorPageState();
}

class _ReminderEditorPageState extends ConsumerState<ReminderEditorPage> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _dose = TextEditingController(
      text: (widget.existing?.dosage ?? 0) > 0
          ? '${widget.existing!.dosage}'
          : '');
  late String _unit = kReminderUnits.contains(widget.existing?.unit)
      ? widget.existing!.unit
      : kReminderUnits.first;
  late int _quantity = widget.existing?.quantity ?? 1;
  late int _days = widget.existing?.days ?? kAllDays;
  late List<String> _times = [...?widget.existing?.times];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  MedReminderModel _draft() => MedReminderModel(
        id: widget.existing?.id,
        name: _name.text,
        dosage: int.tryParse(_dose.text.trim()) ?? 0,
        unit: _unit,
        quantity: _quantity,
        days: _days,
        times: parsedTimes(_times),
        enabled: widget.existing?.enabled ?? true,
      );

  Future<void> _addTime() async {
    // Otherwise focus returns to the name box when the picker closes and the
    // keyboard pops up over the times the person just set.
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (picked == null) return;
    final t = formatHhmm(picked.hour, picked.minute);
    setState(() => _times = parsedTimes([..._times, t]));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(reminderRepositoryProvider).save(_draft());
    } on ArgumentError catch (e) {
      getAlert(e.message.toString());
      if (mounted) setState(() => _saving = false);
      return;
    } catch (_) {
      getAlert('Something went wrong saving this reminder');
      if (mounted) setState(() => _saving = false);
      return;
    }

    // The first reminder is where the phone's permission prompt belongs.
    final allowed =
        await ref.read(reminderCoordinatorProvider).enableNotifications();
    if (!mounted) return;
    if (!allowed) {
      getAlert('Reminder saved, but notifications are turned off for Itoju. '
          'Turn them on in your phone settings to be reminded.');
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this reminder?'),
        content: Text('"${widget.existing!.name}" will stop reminding you. '
            'Medication you have already logged is not affected.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(reminderRepositoryProvider).delete(widget.existing!.id!);
    if (mounted) Navigator.pop(context);
  }

  Widget _label(String text, {String? hint}) => Padding(
        padding: EdgeInsets.only(top: 18.h, bottom: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColorPurple),
            if (hint != null)
              Text(hint,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.hintGrey)),
          ],
        ),
      );

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.opaquePurple,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    final draft = _draft();
    final times = parsedTimes(_times);
    final perWeek = ReminderDays.weekdays(_days).length * times.length;
    final editing = widget.existing != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const CustomBackButton(),
                8.pw,
                CustomText(editing ? 'Edit reminder' : 'New reminder',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColorPurple),
              ]),
              _label('Medication name'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                // Rebuild so the Save button enables as soon as there is a name.
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration('e.g. Metformin'),
              ),
              _label('Dose', hint: 'Optional - how much each time'),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _dose,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: _fieldDecoration('e.g. 500'),
                  ),
                ),
                10.pw,
                DropdownButton<String>(
                  value: _unit,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final u in kReminderUnits)
                      DropdownMenuItem(value: u, child: Text(u)),
                  ],
                  onChanged: (v) => setState(() => _unit = v ?? _unit),
                ),
              ]),
              _label('How many each time'),
              Row(children: [
                IconButton.filledTonal(
                  tooltip: 'Fewer',
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text('$_quantity',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.w700)),
                ),
                IconButton.filledTonal(
                  tooltip: 'More',
                  onPressed:
                      _quantity < 99 ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add),
                ),
              ]),
              _label('Days'),
              Wrap(spacing: 6.w, runSpacing: 6.h, children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    label: Text(ReminderDays.name(d)),
                    selected: ReminderDays.has(_days, d),
                    selectedColor: AppColors.primaryColorPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                        fontSize: 12.sp,
                        color: ReminderDays.has(_days, d)
                            ? Colors.white
                            : AppColors.primaryColorPurple),
                    onSelected: (_) =>
                        setState(() => _days = ReminderDays.toggle(_days, d)),
                  ),
              ]),
              Row(children: [
                TextButton(
                    onPressed: () => setState(() => _days = kAllDays),
                    child: const Text('Every day')),
                TextButton(
                    onPressed: () => setState(() => _days = 31),
                    child: const Text('Weekdays')),
              ]),
              _label('Times',
                  hint:
                      'Add as many as you need, up to $kMaxReminderTimes a day'),
              Wrap(spacing: 8.w, runSpacing: 6.h, children: [
                for (final t in times)
                  InputChip(
                    label: Text(prettyTime(t)),
                    onDeleted: () => setState(() => _times.remove(t)),
                    deleteButtonTooltipMessage: 'Remove ${prettyTime(t)}',
                  ),
                if (times.length < kMaxReminderTimes)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Add a time'),
                    onPressed: _addTime,
                  ),
              ]),
              14.ph,
              if (perWeek > 0)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.splash_underlay,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${ReminderDays.summary(_days)} at ${times.map(prettyTime).join(', ')}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffC98500)),
                  ),
                ),
              24.ph,
              Center(
                child: CurvedButton(
                  text: editing ? 'Save changes' : 'Save reminder',
                  loading: _saving,
                  // Look disabled while there is no name (the button also is).
                  color: draft.name.trim().isEmpty
                      ? AppColors.borderGrey
                      : AppColors.primaryColorPurple,
                  // Greyed out until the basics are valid; the message on tapping
                  // explains anything else (e.g. the phone's reminder limit).
                  onPressed: draft.name.trim().isEmpty ? null : _save,
                  width: 220.w,
                  height: 48.h,
                ),
              ),
              if (editing) ...[
                8.ph,
                Center(
                  child: TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xffD72727)),
                    label: const Text('Delete reminder',
                        style: TextStyle(color: Color(0xffD72727))),
                  ),
                ),
              ],
              30.ph,
            ],
          ),
        ),
      ),
    );
  }
}
