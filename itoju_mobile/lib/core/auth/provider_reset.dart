import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/exercise_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/food_diary_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/syms_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/bowel_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/exercise_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/food_diary_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/syms_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/bowel_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/exercise_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/food_week_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/syms_week_chart_notifier.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/getSmiley_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/get_most_tracked_syms_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/getTrackedMetrics_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/get_latest_smiley_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/metrics_status_notifier.dart';
import 'package:itoju_mobile/features/menses/notifiers/menses_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/bowel_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/exercise_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/food_metric_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/medication_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/sleep_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/urine_notifier.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/settings/notifier/menses_notifier.dart';
import 'package:itoju_mobile/features/settings/notifier/points_notifier.dart';

/// Drops every cached provider that holds ONE account's data, so nothing from a
/// previous session (profile, points, charts, calendar, today's entries, …) can
/// show up for the next user — or linger after "Erase data" / logout.
///
/// Many of these are long-lived (non-autoDispose) notifiers that survive
/// navigation, so a screen-by-screen refresh is not enough. Pass
/// `ref.invalidate` from a widget or a Riverpod `Ref`:
///
///     resetUserScopedProviders(ref.invalidate);
///
/// Auth-form notifiers (login/register/forgot-password) are deliberately not
/// listed: they hold UI state, not account data.
void resetUserScopedProviders(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(profileProvider);
  invalidate(pointProvider);
  invalidate(getSmileyProvider);
  invalidate(getTrackedSymsProvider);
  invalidate(resourcesProvider);
  invalidate(getUserMetricsProvider);
  invalidate(periodProvider);
  invalidate(mensesProvider);
  invalidate(bowelProvider);
  invalidate(sleepProvider);
  invalidate(urineProvider);
  invalidate(exerciseProvider);
  invalidate(medicationProvider);
  invalidate(foodMetricProvider);
  invalidate(symsProvider);
  invalidate(latestSmileyProvider);
  invalidate(metricsStatusProvider);
  invalidate(syms7ChartProvider);
  invalidate(exercise7ChartProvider);
  invalidate(foodDiary7ChartProvider);
  invalidate(bowel7ChartProvider);
  invalidate(symsWeekChartProvider);
  invalidate(bowelWeekChartProvider);
  invalidate(foodDiaryWeekChartProvider);
  invalidate(exerciseWeekChartProvider);
  invalidate(symsMonthChartProvider);
  invalidate(exerciseMonthChartProvider);
  invalidate(foodDiaryMonthChartProvider);
  invalidate(bowelMonthChartProvider);
}
