import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/db/seed_catalogs.dart';
import 'package:itoju_mobile/data/repositories/smiley_repository.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/getSmiley_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/today_provider.dart';
import 'package:itoju_mobile/features/home/metric_registry.dart';
import 'package:itoju_mobile/features/home/notifer/getTrackedMetrics_notifier.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/metrics/pages/blood_pressure.dart';
import 'package:itoju_mobile/features/metrics/pages/medication_reminders.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

const List<String> _moodEmoji = ['😃', '🙂', '😑', '🙁', '😢'];

/// The first thing on Home: how today is going, and one tap to log anything.
class TodaySection extends ConsumerWidget {
  const TodaySection({super.key});

  Future<void> _setMood(BuildContext context, WidgetRef ref, int id, String date) async {
    final repo = ref.read(smileyRepositoryProvider);
    // Changing the mood keeps any tags already chosen for today (set on the
    // middle tab); only the face changes.
    final existing = await repo.getLatestForDate(date);
    await repo.addSmiley(id, List<String>.from(existing?.tags ?? const []), date);
    ref.read(getSmileyProvider.notifier).getGetSmiley();
    getAlert('Mood saved', isWarning: false);
  }

  void _openMetric(BuildContext context, WidgetRef ref, MetricDef def) {
    if (def.opensCalendar) {
      ref.read(routeStateProvider).jumpToTab(3);
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => def.pageFor!(DateTime.now())));
  }

  void _addMetric(BuildContext context) => pushScreen(
        context,
        screen: const AddTrackedMetrics(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaySummaryProvider);
    final selectedAsync = ref.watch(selectedMetricsProvider);
    final summary = summaryAsync.valueOrNull;
    final selected = (selectedAsync.valueOrNull ?? const [])
        .where((m) => kMetricDefs.containsKey(m.name))
        .toList();

    // Progress counts the daily to-dos: mood, plus every tracked metric except
    // Menstruation, which says where you are in your cycle rather than asking
    // for something every day.
    final todo = selected.where((m) => m.name != kMenstruationMetric).toList();
    final done = summary == null
        ? 0
        : todo.where((m) => summary.metrics[m.name]?.logged ?? false).length +
            (summary.moodId != null ? 1 : 0);
    final total = todo.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Today',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColorPurple)),
            8.pw,
            Text(DateFormat('EEE d MMM').format(DateTime.now()),
                style: TextStyle(fontSize: 12.sp, color: AppColors.hintGrey)),
            const Spacer(),
            if ((summary?.streak ?? 0) >= 2)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.splash_underlay,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('🔥 ${summary!.streak}-day streak',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xffC98500))),
              ),
          ],
        ),
        10.ph,
        _Progress(done: done, total: total),
        14.ph,
        _MoodRow(
          selected: summary?.moodId,
          onPick: (id) => _setMood(context, ref, id, todayKey()),
        ),
        14.ph,
        if (selected.isEmpty && selectedAsync.hasValue)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text('Choose what you would like to track and it will appear here.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.hintGrey)),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          // A GridView adds the system status-bar / nav-bar insets as padding by
          // default, which showed up as big gaps above and below the boxes.
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.4,
          children: [
            for (final m in selected)
              _MetricBox(
                def: kMetricDefs[m.name]!,
                today: summary?.metrics[m.name],
                onTap: () => _openMetric(context, ref, kMetricDefs[m.name]!),
              ),
            _AddMetricBox(onTap: () => _addMetric(context)),
          ],
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});
  final int done, total;

  String get _message {
    if (done >= total) return 'All done for today 🎉';
    if (done == 0) return "Let's get started";
    return 'Nice - keep going';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('$done of $total logged',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey)),
          const Spacer(),
          Text(_message, style: TextStyle(fontSize: 11.sp, color: AppColors.hintGrey)),
        ]),
        6.ph,
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : (done / total).clamp(0.0, 1.0),
            minHeight: 8.h,
            backgroundColor: AppColors.opaquePurple,
            color: AppColors.primaryColorPurple,
          ),
        ),
      ],
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.selected, required this.onPick});
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8FC),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selected == null ? 'How are you feeling?' : 'Feeling ${kSmileySeed[selected! - 1].toLowerCase()} today',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple)),
          8.ph,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _moodEmoji.length; i++)
                Semantics(
                  button: true,
                  selected: selected == i + 1,
                  label: kSmileySeed[i],
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30.r),
                    onTap: () => onPick(i + 1),
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == i + 1 ? AppColors.opaquePurple : Colors.white,
                        border: Border.all(
                            color: selected == i + 1
                                ? AppColors.primaryColorPurple
                                : AppColors.alt_border_grey,
                            width: selected == i + 1 ? 2 : 1),
                      ),
                      child: Text(_moodEmoji[i], style: TextStyle(fontSize: 24.sp)),
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

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.def, required this.today, required this.onTap});
  final MetricDef def;
  final MetricToday? today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final logged = today?.logged ?? false;
    final headline = today?.headline ?? '';
    final isCta = !logged;
    return Semantics(
      button: true,
      label: '${def.name}. ${headline.isEmpty ? '' : '$headline. '}'
          '${today?.detail ?? ''}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: logged ? def.color : const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: logged ? Colors.transparent : AppColors.alt_border_grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppColors.splash_underlay,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset('asset/svg/${def.icon}.svg',
                          width: 18.w, height: 18.w),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    logged ? Icons.check_circle : Icons.add_circle_outline,
                    size: 22.r,
                    color: logged ? const Color(0xff2A9341) : AppColors.primaryColorPurple,
                  ),
                ],
              ),
              const Spacer(),
              Text(def.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff737B7D))),
              2.ph,
              Text(headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: isCta ? 13.sp : 16.sp,
                      fontWeight: FontWeight.w800,
                      color: isCta ? AppColors.primaryColorPurple : AppColors.textGrey)),
              if (today?.detail != null)
                Text(today!.detail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.sp, color: AppColors.hintGrey, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMetricBox extends StatelessWidget {
  const _AddMetricBox({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a metric to track',
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primaryColorPurple.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 28.r, color: AppColors.primaryColorPurple),
              4.ph,
              Text('Add a metric',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColorPurple)),
            ],
          ),
        ),
      ),
    );
  }
}

/// One-time card for existing users: points them at blood pressure and reminders.
/// Dismissing it (or acting on either button) hides it for good.
class WhatsNewCard extends ConsumerStatefulWidget {
  const WhatsNewCard({super.key});

  @override
  ConsumerState<WhatsNewCard> createState() => _WhatsNewCardState();
}

class _WhatsNewCardState extends ConsumerState<WhatsNewCard> {
  late bool _hidden = HiveStorage.get(HiveKeys.whatsNew12Seen) == true;

  void _dismiss() {
    HiveStorage.put(HiveKeys.whatsNew12Seen, true);
    setState(() => _hidden = true);
  }

  Future<void> _trackBloodPressure() async {
    final repo = ref.read(trackedMetricsRepositoryProvider);
    final catalog = await repo.getCatalog();
    final bp = catalog.where((m) => m.name == 'Blood Pressure');
    if (bp.isNotEmpty) await repo.add(bp.first.id!);
    // The middle tab keeps its own list; refresh it so BP shows there too.
    ref.read(getUserMetricsProvider.notifier).getGetUserMetrics();
    _dismiss();
    if (!mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => BloodPressurePage(DateTime.now())));
  }

  void _reminders() {
    _dismiss();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MedicationRemindersPage()));
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 6.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.opaquePurple,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('New in Itoju',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColorPurple)),
            ),
            IconButton(
              tooltip: 'Dismiss',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 18),
              onPressed: _dismiss,
            ),
          ]),
          Text(
              'Track your blood pressure and get medication reminders on the days '
              'and times you choose.',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey, height: 1.3)),
          10.ph,
          Wrap(spacing: 8.w, children: [
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColorPurple,
                  foregroundColor: Colors.white),
              onPressed: _trackBloodPressure,
              child: const Text('Track blood pressure'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColorPurple,
                  side: const BorderSide(color: AppColors.primaryColorPurple)),
              onPressed: _reminders,
              child: const Text('Set up reminders'),
            ),
          ]),
        ],
      ),
    );
  }
}
