import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/medication_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/medication_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class MedicationMovement extends ConsumerStatefulWidget {
  const MedicationMovement(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MedicationMovementState();
}

class _MedicationMovementState extends ConsumerState<MedicationMovement> {
  @override
  void initState() {
    isCreateVisible = true;
    selectedDate = widget.intialDate;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(medicationProvider.notifier)
          .getMedicationList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    });
    super.initState();
  }

  List<String> dropdownItems = ['mg', 'mcl', 'tsp'];
  String metric = 'mg';
  bool isCreateVisible = true;
  DateTime? selectedDate;
  bool isExtraNight = false;

  final TextEditingController textCtrl = TextEditingController();
  final TextEditingController doseCtrl = TextEditingController();
  final TextEditingController quantiyCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationProvider);
    bool ifToday = (selectedDate == null ||
        ((selectedDate?.day == DateTime.now().day) &&
            (selectedDate?.month == DateTime.now().month)));
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(10.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 120.h,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        CustomBackButton(),
                        TopNote(
                          text: 'Have you had any medication today?',
                        )
                      ],
                    ),
                    5.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          '${ifToday ? 'Today' : ''} ${DateFormat('EEE').format(selectedDate!)} ${(selectedDate)!.day} ${ifToday ? '' : DateFormat.MMM().format(selectedDate!)}',
                          color: AppColors.primaryColorPurple,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        CurvedButton(
                          width: 120.w,
                          height: 35.h,
                          text: 'Change',
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(const Duration(days: 90)),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {});
                              if (value != null) {
                                selectedDate = value;
                              }
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                ref
                                    .read(medicationProvider.notifier)
                                    .getMedicationList(DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!));
                              });
                            });
                          },
                        )
                      ],
                    ),
                    10.ph,
                  ],
                ),
              ),
              state.status == Loader.loading
                  ? const AppLoader()
                  : state.status == Loader.error
                      ? ErrorCon(
                          func: () {
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              ref
                                  .read(medicationProvider.notifier)
                                  .getMedicationList(DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!));
                            });
                          },
                        )
                      : Column(
                          children: [
                            state.medicationModels!.isEmpty
                                ? Visibility(
                                    visible: isCreateVisible,
                                    child: Column(
                                      children: [
                                        25.ph,
                                        Image.asset(
                                            'asset/png/no_medication.png'),
                                        10.ph
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.medicationModels!.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final medicationMetric = ref
                                          .watch(medicationProvider)
                                          .medicationModels![index];

                                      return MedicationList(
                                          medicationModel: medicationMetric,
                                          date: DateFormat('yyyy-MM-dd')
                                              .format(selectedDate!));
                                    },
                                  ),
                            15.ph,
                            Visibility(
                              visible: isCreateVisible,
                              replacement: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 7.h, horizontal: 10.w),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: const Color(0xffEEEDF8),
                                    border:
                                        Border.all(color: const Color(0xffEEEDF8))),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    7.ph,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          'Name of Medication',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColorPurple,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isCreateVisible =
                                                    !isCreateVisible;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              color:
                                                  AppColors.primaryColorPurple,
                                            ))
                                      ],
                                    ),
                                    CustomTextField(
                                        filled: true, controller: textCtrl),
                                    15.ph,
                                    CustomText(
                                      'Single Dosage',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColorPurple,
                                    ),
                                    7.ph,
                                    Row(
                                      children: [
                                        Expanded(
                                            child: CustomTextField(
                                          filled: true,
                                          controller: doseCtrl,
                                          inputType: TextInputType.number,
                                        )),
                                        10.pw,
                                        DropdownExample(
                                          onChanged: (val) {
                                            metric = val!;
                                            setState(() {});
                                          },
                                          items: dropdownItems,
                                          hint: const Text(''),
                                          width: 70.w,
                                          value: metric,
                                        )
                                      ],
                                    ),
                                    15.ph,
                                    CustomText(
                                      'Quantity taken',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColorPurple,
                                    ),
                                    7.ph,
                                    CustomTextField(
                                      filled: true,
                                      controller: quantiyCtrl,
                                      inputType: TextInputType.number,
                                    ),
                                    10.ph,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CurvedButton(
                                          text: 'Done',
                                          loading: ref
                                                  .watch(medicationProvider)
                                                  .postStatus ==
                                              Loader.loading,
                                          onPressed: () async {
                                            if (textCtrl.text.isEmpty ||
                                                doseCtrl.text.isEmpty ||
                                                quantiyCtrl.text.isEmpty) {
                                              return;
                                            }
                                            final response = await ref
                                                .read(
                                                    medicationProvider.notifier)
                                                .createMedicationMetric(
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(selectedDate!),
                                                    MedicationModel(
                                                        id: null,
                                                        time: DateFormatter
                                                            .formatTime(DateTime
                                                                    .now()
                                                                .toString()),
                                                        metric: metric,
                                                        name: textCtrl.text,
                                                        dosage: int.parse(
                                                            doseCtrl.text),
                                                        quantity: int.parse(
                                                            quantiyCtrl.text)));

                                            if (response
                                                .successMessage.isNotEmpty) {
                                              getAlert(response.successMessage,
                                                  isWarning: false);
                                              isCreateVisible = true;
                                              textCtrl.clear();
                                              doseCtrl.clear();
                                              quantiyCtrl.clear();

                                              SchedulerBinding.instance
                                                  .addPostFrameCallback(
                                                      (timeStamp) async {
                                                ref
                                                    .read(medicationProvider
                                                        .notifier)
                                                    .getMedicationList(
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(
                                                                selectedDate!));
                                              });
                                            } else if (response
                                                .responseMessage!.isNotEmpty) {
                                              getAlert(
                                                  response.responseMessage!);
                                            } else {
                                              getAlert(response.errorMessage);
                                            }
                                          },
                                          width: 150.w,
                                          height: 45.h,
                                        ),
                                      ],
                                    ),
                                    10.ph,
                                  ],
                                ),
                              ),
                              child: InkWell(
                                  onTap: () async {
                                    isCreateVisible = false;
                                    setState(() {});
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const AddButton(),
                                        7.pw,
                                        CustomText(
                                          'Add Medication record',
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryColorPurple,
                                        )
                                      ])),
                            ),
                            10.ph,
                          ],
                        ),
            ],
          ),
        ),
      )),
    );
  }
}

class DropdownExample extends StatefulWidget {
  final List<String> items;
  final Widget hint;
  final double width;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? value;

  const DropdownExample(
      {super.key,
      required this.items,
      this.width = 170,
      required this.hint,
      this.onChanged,
      this.validator,
      required this.value});

  @override
  DropdownExampleState createState() => DropdownExampleState();
}

class DropdownExampleState extends State<DropdownExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      width: widget.width.w,
      padding: EdgeInsets.only(left: 7.w),
      decoration: BoxDecoration(
          color: AppColors.primaryColorPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.black12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          elevation: 2,
          borderRadius: BorderRadius.circular(10.r),
          value: widget.value,
          hint: widget.hint,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: 30.r,
            color: AppColors.primaryColorPurple,
          ),
          style: TextStyle(
              color: AppColors.primaryColorPurple,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600),
          onChanged: widget.onChanged,
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
