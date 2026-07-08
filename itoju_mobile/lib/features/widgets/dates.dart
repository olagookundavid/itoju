import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String? date) {
    if (date == null) {
      return '--';
    }
    final dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return '--';
    }
    var newDate = DateFormat("yyyy-MM-dd").format(dateTime);
    return newDate;
  }

  static String formatToyMMMMd(String? date) {
    if (date == null) {
      return '--';
    }
    final dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return '--';
    }
    var newDate = DateFormat.yMMMMd().format(dateTime);
    return newDate;
  }

  static String formatTime(String? date) {
    if (date == null) {
      return '--';
    }
    final dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return '--';
    }
    var newTime = DateFormat.jm().format(dateTime);
    return newTime;
  }
}

String? timeOfDay() {
  var time = DateTime.now().hour;
  if (time <= 11) {
    return "Morning";
  } else if (time >= 11 && time <= 16) {
    return "Afternoon";
  } else {
    return "Evening";
  }
}

String calculateTimeDifference(DateTime? startDate, DateTime? endDate) {
  if (startDate == null || endDate == null) {
    return "00h 00m";
  }

  Duration difference = endDate.difference(startDate);

  if (difference.isNegative) {
    difference = -difference;
  }

  int hours = difference.inHours;
  int minutes = difference.inMinutes.remainder(60);

  String formattedDifference =
      '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';

  return formattedDifference;
}

DateTime? convertTimeStringToDateTime(String timeString) {
  try {
    // Parse time string to DateTime
    DateFormat format = DateFormat('hh:mm a');
    DateTime parsedTime =
        format.parse(timeString.trim().replaceAll("\u202F", " "));

    // Get current DateTime
    DateTime currentDateTime = DateTime.now();

    // Add parsed time to current DateTime
    int hoursToAdd = parsedTime.hour;
    int minutesToAdd = parsedTime.minute;
    return DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      hoursToAdd,
      minutesToAdd,
    );
  } catch (e) {
    return null;
  }
}
