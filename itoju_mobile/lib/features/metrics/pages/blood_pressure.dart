import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/blood_pressure.dart';
import 'package:itoju_mobile/features/metrics/notifiers/bp_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/bp_category_chip.dart';
import 'package:itoju_mobile/features/metrics/widgets/bp_trend_chart.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class BloodPressurePage extends ConsumerStatefulWidget {
  const BloodPressurePage(this.initialDate, {super.key});
  final DateTime initialDate;

  @override
  ConsumerState<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends ConsumerState<BloodPressurePage> {
  static final _dayFmt = DateFormat('yyyy-MM-dd');

  late DateTime _date = widget.initialDate;
  TimeOfDay _time = TimeOfDay.now();
  BpModel? _editing;

  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();

  String get _dateKey => _dayFmt.format(_date);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() => ref.read(bpProvider.notifier).getForDate(_dateKey);

  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _parse(String hhmm) {
    final p = hhmm.split(':');
    final h = int.tryParse(p.first) ?? 0;
    final m = p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static String _pretty(String hhmm) {
    final t = _parse(hhmm);
    return DateFormat.jm().format(DateTime(2000, 1, 1, t.hour, t.minute));
  }

  void _clearForm() {
    _sysCtrl.clear();
    _diaCtrl.clear();
    _pulseCtrl.clear();
    _editing = null;
    _time = TimeOfDay.now();
  }

  void _startEdit(BpModel m) {
    setState(() {
      _editing = m;
      _sysCtrl.text = '${m.systolic}';
      _diaCtrl.text = '${m.diastolic}';
      _pulseCtrl.text = '${m.pulse}';
      _time = _parse(m.time);
    });
  }

  Future<void> _save() async {
    final sys = int.tryParse(_sysCtrl.text.trim());
    final dia = int.tryParse(_diaCtrl.text.trim());
    final pulse = int.tryParse(_pulseCtrl.text.trim());
    final problem = validateBp(systolic: sys, diastolic: dia, pulse: pulse);
    if (problem != null) {
      getAlert(problem);
      return;
    }
    final model = BpModel(
      id: _editing?.id,
      date: _dateKey,
      time: _hhmm(_time),
      systolic: sys!,
      diastolic: dia!,
      pulse: pulse!,
    );
    final notifier = ref.read(bpProvider.notifier);
    final response = _editing == null
        ? await notifier.create(_dateKey, model)
        : await notifier.update(model);
    if (!mounted) return;
    if (response.successMessage.isNotEmpty) {
      getAlert(response.successMessage, isWarning: false);
      setState(_clearForm);
      _reload();
    } else if (response.responseMessage?.isNotEmpty ?? false) {
      getAlert(response.responseMessage!);
    } else {
      getAlert(response.errorMessage);
    }
  }

  Future<void> _delete(BpModel m) async {
    final response = await ref.read(bpProvider.notifier).delete(m.id!);
    if (!mounted) return;
    if (response.successMessage.isNotEmpty) {
      if (_editing?.id == m.id) setState(_clearForm);
      _reload();
    } else {
      getAlert(response.errorMessage);
    }
  }

  Widget _numberField(
      {required String title,
      required String hint,
      required String unit,
      required TextEditingController ctrl}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColorPurple),
          Text(hint,
              style: TextStyle(color: AppColors.hintGrey, fontSize: 10.sp)),
          6.ph,
          Container(
            height: 64.h,
            decoration: BoxDecoration(
              color: const Color(0xffFFFAEB),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffFF9F00).withValues(alpha: 0.35)),
                  suffixText: unit,
                  suffixStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffEEAF4B)),
                ),
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffFF9F00)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard() {
    final sys = int.tryParse(_sysCtrl.text.trim());
    final dia = int.tryParse(_diaCtrl.text.trim());
    // Live readout once both numbers look like a plausible reading.
    final preview = (sys != null && dia != null && sys > dia)
        ? classifyBp(sys, dia)
        : null;
    final busy = ref.watch(bpProvider).busy;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xffEEEDF8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(_editing == null ? 'New reading' : 'Edit reading',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple),
              const Spacer(),
              if (_editing != null)
                TextButton(
                    onPressed: () => setState(_clearForm),
                    child: const Text('Cancel')),
            ],
          ),
          10.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _numberField(
                  title: 'Systolic',
                  hint: 'top number',
                  unit: 'mmHg',
                  ctrl: _sysCtrl),
              8.pw,
              _numberField(
                  title: 'Diastolic',
                  hint: 'bottom number',
                  unit: 'mmHg',
                  ctrl: _diaCtrl),
              8.pw,
              _numberField(
                  title: 'Pulse', hint: 'beats a minute', unit: 'bpm', ctrl: _pulseCtrl),
            ],
          ),
          12.ph,
          Row(
            children: [
              Icon(Icons.schedule, size: 16.r, color: AppColors.primaryColorPurple),
              6.pw,
              Text(_pretty(_hhmm(_time)),
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey)),
              TextButton(
                onPressed: () async {
                  final picked =
                      await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                },
                child: const Text('Change'),
              ),
            ],
          ),
          if (preview != null) ...[
            4.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BpCategoryChip(preview),
                8.pw,
                Expanded(
                  child: Text(preview.summary,
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textGrey, height: 1.3)),
                ),
              ],
            ),
          ],
          14.ph,
          Center(
            child: CurvedButton(
              text: _editing == null ? 'Save reading' : 'Update reading',
              loading: busy,
              onPressed: _save,
              width: 180.w,
              height: 45.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingTile(BpModel m) {
    final selected = _editing?.id == m.id;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: selected ? AppColors.primaryColorPurple : AppColors.alt_border_grey,
            width: selected ? 1.5 : 1),
      ),
      child: ListTile(
        onTap: () => _startEdit(m),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        title: Row(
          children: [
            Text('${m.systolic}/${m.diastolic}',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColorPurple)),
            4.pw,
            Text('mmHg',
                style: TextStyle(fontSize: 10.sp, color: AppColors.hintGrey)),
            10.pw,
            Text('${m.pulse} bpm',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey)),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              BpCategoryChip(m.category),
              8.pw,
              Text(_pretty(m.time),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.hintGrey)),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: 'Delete reading',
          icon: const Icon(Icons.delete_outline, color: AppColors.hintGrey),
          onPressed: () => _delete(m),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bpProvider);
    final today = DateTime.now();
    final isToday = _date.year == today.year &&
        _date.month == today.month &&
        _date.day == today.day;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  CustomBackButton(),
                  Expanded(child: TopNote(text: "Let's check your blood pressure")),
                ]),
                10.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flexible so a long date or large system text shrinks instead
                    // of overflowing next to the Change button.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          '${isToday ? 'Today ' : ''}${DateFormat('EEE d').format(_date)}'
                          '${isToday ? '' : ' ${DateFormat.MMM().format(_date)}'}',
                          color: AppColors.primaryColorPurple,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    8.pw,
                    CurvedButton(
                      width: 120.w,
                      height: 35.h,
                      text: 'Change',
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: today.subtract(const Duration(days: 365)),
                          lastDate: today,
                        );
                        if (picked == null) return;
                        setState(() {
                          _date = picked;
                          _clearForm();
                        });
                        _reload();
                      },
                    ),
                  ],
                ),
                14.ph,
                _entryCard(),
                16.ph,
                if (state.status == Loader.loading)
                  const Center(child: AppLoader())
                else if (state.readings.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text('No readings for this day yet',
                        style: TextStyle(color: AppColors.hintGrey, fontSize: 12.sp)),
                  )
                else
                  ...state.readings.map(_readingTile),
                12.ph,
                const BpTrendCard(),
                12.ph,
                Text(kBpDisclaimer,
                    style: TextStyle(
                        fontSize: 10.sp, color: AppColors.hintGrey, height: 1.3)),
                40.ph,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
