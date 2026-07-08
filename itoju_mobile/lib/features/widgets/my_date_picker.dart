// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';

// ignore: must_be_immutable
class MyDatePicker extends StatefulWidget {
  ///DropDown select text style
  final TextStyle? textStyle;

  ///DropDown container box decoration
  final BoxDecoration? boxDecoration;

  ///DropDown expand icon
  final Icon? icon;

  ///Start year for date picker
  ///Default is 1900
  final int? startYear;

  ///End year for date picker
  ///Default is Current year
  final int? endYear;

  ///width between each drop down
  ///Default is 12.0
  final double width;

  ///Return selected date
  ValueChanged<String?>? onChangedDay;

  ///Return selected month
  ValueChanged<String?>? onChangedMonth;

  ///Return selected year
  ValueChanged<String?>? onChangedYear;

  MyDatePicker({
    Key? key,
    this.textStyle,
    this.boxDecoration,
    this.icon,
    this.startYear,
    this.endYear,
    this.width = 10.0,
    this.onChangedDay,
    this.onChangedMonth,
    this.onChangedYear,
  }) : super(key: key);

  @override
  _MyDatePickerState createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  var monthselVal = '';
  var dayselVal = '';
  var yearselVal = '';
  int daysIn = 32;
  late List listdates = [];
  late List listyears = [];

  @override
  void initState() {
    super.initState();
    listdates = Iterable<int>.generate(daysIn).skip(1).toList();
    listyears =
        Iterable<int>.generate((widget.endYear ?? DateTime.now().year) + 1)
            .skip(widget.startYear ?? 2020)
            .toList()
            .reversed
            .toList();
  }

  ///Month selection dropdown function
  monthSelected(value) {
    widget.onChangedMonth!(value);
    monthselVal = value;
    int days = daysInMonth(
        yearselVal == '' ? DateTime.now().year : int.parse(yearselVal),
        int.parse(value));
    listdates = Iterable<int>.generate(days + 1).skip(1).toList();
    checkDates(days);
    update();
  }

  ///check dates for selected month and year
  void checkDates(days) {
    if (dayselVal != '') {
      if (int.parse(dayselVal) > days) {
        dayselVal = '';
        widget.onChangedDay!('');
        update();
      }
    }
  }

  ///find days in month and year
  int daysInMonth(year, month) => DateTimeRange(
          start: DateTime(year, month, 1), end: DateTime(year, month + 1))
      .duration
      .inDays;

  ///day selection dropdown function
  daysSelected(value) {
    widget.onChangedDay!(value);
    dayselVal = value;
    update();
  }

  ///year selection dropdown function
  yearsSelected(value) {
    widget.onChangedYear!(value);
    yearselVal = value;
    if (monthselVal != '') {
      int days = daysInMonth(
          yearselVal == '' ? DateTime.now().year : int.parse(yearselVal),
          int.parse(monthselVal));
      listdates = Iterable<int>.generate(days + 1).skip(1).toList();
      checkDates(days);
      update();
    }
    update();
  }

  ///list of months
  List<dynamic> listMonths = [
    {"id": 1, "value": "January"},
    {"id": 2, "value": "February"},
    {"id": 3, "value": "March"},
    {"id": 4, "value": "April"},
    {"id": 5, "value": "May"},
    {"id": 6, "value": "June"},
    {"id": 7, "value": "July"},
    {"id": 8, "value": "August"},
    {"id": 9, "value": "September"},
    {"id": 10, "value": "October"},
    {"id": 11, "value": "November"},
    {"id": 12, "value": "December"}
  ];

  ///update function
  update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: dayDropdown(),
        ),
        w(widget.width),
        Expanded(
          flex: 5,
          child: monthDropdown(),
        ),
        w(widget.width),
        Expanded(
          flex: 4,
          child: yearDropdown(),
        ),
      ],
    );
  }

  ///month dropdown
  DropdownButtonFormField<String> monthDropdown() {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.primaryColorPurple.withOpacity(0.1)),
        hint: const CustomText(
          "Month",
          fontSize: 14,
          color: AppColors.hintGrey,
        ),
        icon: widget.icon ??
            const Icon(
              Icons.expand_more,
              color: Colors.grey,
            ),
        initialValue: monthselVal == '' ? null : monthselVal,
        onChanged: (value) {
          monthSelected(value);
        },
        items: listMonths.map((item) {
          return DropdownMenuItem<String>(
            value: item["id"].toString(),
            child: Text(
              item["value"].toString(),
              style: widget.textStyle ??
                  const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
            ),
          );
        }).toList());
  }

  ///year dropdown
  DropdownButtonFormField<String> yearDropdown() {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.primaryColorPurple.withOpacity(0.1)),
        hint: const CustomText(
          "Year",
          fontSize: 14,
          color: AppColors.hintGrey,
        ),
        icon: widget.icon ?? const Icon(Icons.expand_more, color: Colors.grey),
        initialValue: yearselVal == '' ? null : yearselVal,
        onChanged: (value) {
          yearsSelected(value);
        },
        items: listyears.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(
              item.toString(),
              style: widget.textStyle ??
                  const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
            ),
          );
        }).toList());
  }

  ///day dropdown
  DropdownButtonFormField<String> dayDropdown() {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.primaryColorPurple.withOpacity(0.1)),
        hint: const CustomText(
          "Day",
          fontSize: 14,
          color: AppColors.hintGrey,
        ),
        icon: widget.icon ?? const Icon(Icons.expand_more, color: Colors.grey),
        initialValue: dayselVal == '' ? null : dayselVal,
        onChanged: (value) {
          daysSelected(value);
        },
        items: listdates.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item.toString(),
                style: widget.textStyle ??
                    const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
          );
        }).toList());
  }

  ///sizedbox for width
  Widget w(double count) => SizedBox(
        width: count,
      );
}
