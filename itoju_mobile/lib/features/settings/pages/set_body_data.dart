import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/body_units.dart';
import 'package:itoju_mobile/data/limits.dart';
import 'package:itoju_mobile/features/settings/notifier/body_data_notifier.dart';
import 'package:itoju_mobile/features/settings/widgets/sign_value_widget.dart';
import 'package:itoju_mobile/features/settings/widgets/sign_widget.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class SetBodyData extends ConsumerStatefulWidget {
  const SetBodyData({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SetBodyDataState();
}

/// Parses a typed number. Empty means "not set" (0). Accepts a decimal comma.
/// Returns null for anything that is not a plain non-negative number.
double? parseMeasure(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return 0;
  final v = double.tryParse(t);
  if (v == null || v.isNaN || v < 0) return null;
  return v;
}

String _fmt(double v) {
  if (v == 0) return '';
  return v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(1);
}

class _SetBodyDataState extends ConsumerState<SetBodyData> {
  bool _pounds = false; // weight unit: kg (false) | lb (true)
  bool _feetInches = false; // height unit: cm (false) | ft + in (true)

  final weightCtrl = TextEditingController();
  final cmCtrl = TextEditingController();
  final feetCtrl = TextEditingController();
  final inchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pounds = isPounds(HiveStorage.get(HiveKeys.weightMetric));
    _feetInches = isFeetInches(HiveStorage.get(HiveKeys.heightMetric));
    SchedulerBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(bodyDataProvider.notifier).getBodyData();
    if (!mounted) return;
    final data = ref.read(bodyDataProvider).bodyDataModel;
    _showWeightKg(data?.weightKg ?? 0);
    _showHeightCm(data?.heightCm ?? 0);
  }

  void _showWeightKg(double kg) {
    weightCtrl.text = _fmt(_pounds ? kgToLb(kg) : kg);
  }

  void _showHeightCm(double cm) {
    if (_feetInches) {
      final fi = cmToFeetInches(cm);
      feetCtrl.text = fi.feet == 0 ? '' : '${fi.feet}';
      inchCtrl.text = _fmt(fi.inches);
      cmCtrl.clear();
    } else {
      cmCtrl.text = _fmt(cm);
      feetCtrl.clear();
      inchCtrl.clear();
    }
  }

  /// Current inputs as canonical kg / cm, or null (with a message) if invalid.
  ({double kg, double cm})? _read() {
    final w = parseMeasure(weightCtrl.text);
    if (w == null) {
      getAlert('Enter your weight as a number, for example 68.5');
      return null;
    }
    final kg = _pounds ? lbToKg(w) : w;

    double cm;
    if (_feetInches) {
      final ft = int.tryParse(
          feetCtrl.text.trim().isEmpty ? '0' : feetCtrl.text.trim());
      final inch = parseMeasure(inchCtrl.text);
      if (ft == null || inch == null) {
        getAlert(
            'Enter height as whole feet and inches, for example 5 ft 8.5 in');
        return null;
      }
      if (inch >= 12) {
        getAlert('Inches must be under 12 — add the extra to the feet box');
        return null;
      }
      cm = feetInchesToCm(ft, inch);
    } else {
      final c = parseMeasure(cmCtrl.text);
      if (c == null) {
        getAlert('Enter your height as a number, for example 172.5');
        return null;
      }
      cm = c;
    }
    if (kg > kMaxWeightKg) {
      getAlert('That weight looks too high — please check it');
      return null;
    }
    if (cm > kMaxHeightCm) {
      getAlert('That height looks too tall — please check it');
      return null;
    }
    return (kg: round1(kg), cm: round1(cm));
  }

  /// Switching unit converts what is typed so the person sees the same body
  /// measurement in the new unit, rather than the same digits with a new label.
  void _setWeightUnit(bool pounds) {
    if (pounds == _pounds) return;
    final w = parseMeasure(weightCtrl.text) ?? 0;
    final kg = _pounds ? lbToKg(w) : w;
    setState(() {
      _pounds = pounds;
      _showWeightKg(kg);
    });
    HiveStorage.put(HiveKeys.weightMetric, pounds ? 'lb' : 'kg');
  }

  void _setHeightUnit(bool feetInches) {
    if (feetInches == _feetInches) return;
    double cm;
    if (_feetInches) {
      final ft = int.tryParse(feetCtrl.text.trim()) ?? 0;
      cm = feetInchesToCm(ft, parseMeasure(inchCtrl.text) ?? 0);
    } else {
      cm = parseMeasure(cmCtrl.text) ?? 0;
    }
    setState(() {
      _feetInches = feetInches;
      _showHeightCm(cm);
    });
    HiveStorage.put(HiveKeys.heightMetric, feetInches ? 'inch' : 'cm');
  }

  void _step(TextEditingController c, double by, {double max = 999}) {
    final cur = parseMeasure(c.text) ?? 0;
    final next = round1((cur + by).clamp(0, max).toDouble());
    setState(() => c.text = _fmt(next));
  }

  @override
  void dispose() {
    weightCtrl.dispose();
    cmCtrl.dispose();
    feetCtrl.dispose();
    inchCtrl.dispose();
    super.dispose();
  }

  Widget _unitChips(
      List<String> labels, int selected, ValueChanged<int> onPick) {
    return Wrap(
      spacing: 8.w,
      children: [
        for (var i = 0; i < labels.length; i++)
          ChoiceChip(
            label: Text(labels[i]),
            selected: i == selected,
            selectedColor: AppColors.primaryColorPurple,
            labelStyle: TextStyle(
                color:
                    i == selected ? Colors.white : AppColors.primaryColorPurple,
                fontWeight: FontWeight.w600),
            onSelected: (_) => onPick(i),
          ),
      ],
    );
  }

  Widget _card(Widget child) => Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          width: 320.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: const Color(0xffF8F8FC),
          ),
          child: child,
        ),
      );

  /// [-] value [+] with the unit written inside the box.
  Widget _stepper(TextEditingController c, String unit, double step,
      {double max = 999, double width = 110, bool decimal = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SignWigdet(isAdd: false, onTap: () => _step(c, -step, max: max)),
        6.pw,
        SignValueWigdet(ctrl: c, decimal: decimal, suffix: unit, width: width),
        6.pw,
        SignWigdet(isAdd: true, onTap: () => _step(c, step, max: max)),
      ],
    );
  }

  Widget _label(String text) => CustomText(
        text,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xffEEAF4B),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyDataProvider);
    return Scaffold(
      appBar: AppBar(leading: const CustomBackButton()),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: state.getStatus == Loader.loading
              ? const AppLoader()
              : state.getStatus == Loader.error
                  ? ErrorCon(func: _load)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Body measurements',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        4.ph,
                        CustomText(
                          'Use decimals if you like, e.g. 68.5 kg. Pick the units '
                          'you are used to; we keep them in kg and cm behind the scenes.',
                          fontSize: 12.sp,
                          maxline: 3,
                          color: AppColors.hintGrey,
                        ),
                        24.ph,
                        _label('Weight'),
                        8.ph,
                        _unitChips(['kg', 'lb'], _pounds ? 1 : 0,
                            (i) => _setWeightUnit(i == 1)),
                        12.ph,
                        _card(_stepper(weightCtrl, _pounds ? 'lb' : 'kg', 0.5,
                            max: _pounds ? 1100 : kMaxWeightKg, width: 140)),
                        36.ph,
                        _label('Height'),
                        8.ph,
                        _unitChips(['cm', 'ft + in'], _feetInches ? 1 : 0,
                            (i) => _setHeightUnit(i == 1)),
                        12.ph,
                        _card(_feetInches
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _fieldTitle('Feet'),
                                      _fieldTitle('Inches'),
                                    ],
                                  ),
                                  6.ph,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SignValueWigdet(
                                          ctrl: feetCtrl,
                                          suffix: 'ft',
                                          width: 100),
                                      SignValueWigdet(
                                          ctrl: inchCtrl,
                                          decimal: true,
                                          suffix: 'in',
                                          width: 110),
                                    ],
                                  ),
                                ],
                              )
                            : _stepper(cmCtrl, 'cm', 1,
                                max: kMaxHeightCm, width: 140)),
                        32.ph,
                        Center(
                          child: CurvedButton(
                              text: 'Update',
                              loading: ref.watch(bodyDataProvider).postStatus ==
                                  Loader.loading,
                              onPressed: () async {
                                final v = _read();
                                if (v == null) return;
                                final response = await ref
                                    .read(bodyDataProvider.notifier)
                                    .updateBodyData(v.cm, v.kg);
                                if (response.successMessage.isNotEmpty) {
                                  getAlert(response.successMessage,
                                      isWarning: false);
                                } else if (response
                                        .responseMessage?.isNotEmpty ??
                                    false) {
                                  getAlert(response.responseMessage!);
                                } else {
                                  getAlert(response.errorMessage);
                                }
                              }),
                        ),
                        40.ph,
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _fieldTitle(String t) => CustomText(t,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryColorPurple);
}
