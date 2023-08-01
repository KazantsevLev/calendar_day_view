import 'package:calendar_day_view/src/extensions/list_extensions.dart';
import 'package:flutter/material.dart';

import '../../calendar_day_view.dart';
import '../models/typedef.dart';

class CategoryCalendarDayView<T extends Object> extends StatelessWidget {
  const CategoryCalendarDayView({
    Key? key,
    required this.categories,
    required this.events,
    required this.startOfDay,
    this.endOfDay,
    required this.timeGap,
    this.heightPerMin = 1.0,
    this.evenRowColor,
    this.oddRowColor,
    this.verticalDivider,
    this.horizontalDivider,
    this.timeTextStyle,
    required this.eventBuilder,
    this.onTileTap,
    this.headerTileBuilder,
    this.headerDecoration,
  }) : super(key: key);
  final List<EventCategory> categories;
  final List<CategorizedDayEvent<T>> events;

  /// To set the start time of the day view
  final TimeOfDay startOfDay;

  /// To set the end time of the day view
  final TimeOfDay? endOfDay;

  /// time gap/duration of a row.
  ///
  /// This will determine the minimum height of a row
  /// row height is calculated by `rowHeight = heightPerMin * timeGap`
  final int timeGap;

  /// height in pixel per minute
  final double heightPerMin;

  /// background color of the even-indexed row
  final Color? evenRowColor;

  /// background color of the odd-indexed row
  final Color? oddRowColor;

  /// dividers that run vertically in the day view
  final VerticalDivider? verticalDivider;

  /// dividers that run horizontally in the day view
  final Divider? horizontalDivider;

  /// time label text style
  final TextStyle? timeTextStyle;

  /// event builder
  final CategoryDayViewEventBuilder<T> eventBuilder;

  /// call when you tap on an empty tile
  ///
  /// provide [EventCategory] and [TimeOfDay]  of that tile
  final CategoryDayViewTileTap? onTileTap;

  /// build category header
  final CategoryDayViewHeaderTileBuilder? headerTileBuilder;

  /// header row decoration
  final BoxDecoration? headerDecoration;

  @override
  Widget build(BuildContext context) {
    final timeList = getTimeList(
      startOfDay: startOfDay,
      endOfDay: endOfDay,
      timeGap: timeGap,
    );

    final rowHeight = heightPerMin * timeGap;
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final rowLength = constraints.maxWidth - 50;
          final tileWidth = rowLength / categories.length;
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              children: [
                horizontalDivider ?? const Divider(height: 0),
                DayViewHeader(
                  rowHeight: rowHeight,
                  verticalDivider: verticalDivider,
                  categories: categories,
                  headerTileBuilder: headerTileBuilder,
                  tileWidth: tileWidth,
                  headerDecoration: headerDecoration,
                ),
                horizontalDivider ?? const Divider(height: 0),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: timeList.length,
                  separatorBuilder: (context, index) =>
                      horizontalDivider ?? const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final time = timeList.elementAt(index);
                    final rowEvents = events
                        .where(
                          (event) => event.isInThisGap(time, timeGap),
                        )
                        .toList();
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? evenRowColor : oddRowColor,
                      ),
                      constraints: BoxConstraints(
                        minHeight: rowHeight,
                      ),
                      child: DayViewRow<T>(
                        time: time,
                        timeTextStyle: timeTextStyle,
                        verticalDivider: verticalDivider,
                        categories: categories,
                        rowEvents: rowEvents,
                        onTileTap: onTileTap,
                        tileWidth: tileWidth,
                        rowHeight: rowHeight,
                        eventBuilder: eventBuilder,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DayViewRow<T extends Object> extends StatelessWidget {
  const DayViewRow({
    super.key,
    required this.time,
    required this.timeTextStyle,
    required this.verticalDivider,
    required this.categories,
    required this.rowEvents,
    required this.onTileTap,
    required this.tileWidth,
    required this.rowHeight,
    required this.eventBuilder,
  });

  final TimeOfDay time;
  final TextStyle? timeTextStyle;
  final VerticalDivider? verticalDivider;
  final List<EventCategory> categories;
  final List<CategorizedDayEvent<T>> rowEvents;
  final CategoryDayViewTileTap<T>? onTileTap;
  final double tileWidth;
  final double rowHeight;
  final CategoryDayViewEventBuilder<T> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, "0")}",
                style: timeTextStyle,
              ),
            ),
          ),
          verticalDivider ?? const VerticalDivider(width: 0),
          ...categories
              .map((category) {
                final event = rowEvents
                    .firstWhereOrNull((e) => e.categoryId == category.id);

                final constraints = BoxConstraints(
                  minHeight: rowHeight,
                  maxWidth: tileWidth,
                );
                return [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (onTileTap == null || event != null)
                        ? null
                        : () => onTileTap!(category, time),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: tileWidth,
                        minHeight: rowHeight,
                      ),
                      child: event == null
                          ? const SizedBox.shrink()
                          : eventBuilder(
                              constraints,
                              category,
                              event,
                            ),
                    ),
                  ),
                  verticalDivider ?? const VerticalDivider(width: 0),
                ];
              })
              .expand((element) => element)
              .toList()
        ],
      ),
    );
  }
}

class DayViewHeader extends StatelessWidget {
  const DayViewHeader({
    super.key,
    required this.rowHeight,
    required this.verticalDivider,
    required this.categories,
    required this.headerTileBuilder,
    required this.tileWidth,
    this.headerDecoration,
  });

  final double rowHeight;
  final VerticalDivider? verticalDivider;
  final List<EventCategory> categories;
  final CategoryDayViewHeaderTileBuilder? headerTileBuilder;
  final double tileWidth;
  final BoxDecoration? headerDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: headerDecoration,
      constraints: BoxConstraints(minHeight: rowHeight),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const SizedBox(width: 50),
            verticalDivider ?? const VerticalDivider(width: 0),
            ...categories
                .map(
                  (category) => [
                    headerTileBuilder != null
                        ? headerTileBuilder!(
                            BoxConstraints(
                              maxHeight: rowHeight,
                              maxWidth: tileWidth,
                            ),
                            category,
                          )
                        : SizedBox(
                            width: tileWidth,
                            height: rowHeight,
                            child: Center(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                    verticalDivider ?? const VerticalDivider(width: 0),
                  ],
                )
                .expand((e) => e)
                .toList()
          ],
        ),
      ),
    );
  }
}

List<TimeOfDay> getTimeList({
  required TimeOfDay startOfDay,
  TimeOfDay? endOfDay,
  required int timeGap,
}) {
  final timeEnd = endOfDay ?? const TimeOfDay(hour: 23, minute: 0);

  final timeCount = ((timeEnd.hour * 60 + timeEnd.minute) - (startOfDay.hour * 60 + startOfDay.minute)) ~/ timeGap;
  DateTime first = DateTime.parse(
      "2012-02-27T${startOfDay.hour.toString().padLeft(2, '0')}:00");
  List<TimeOfDay> list = [];
  for (var i = 1; i <= timeCount; i++) {
    list.add(TimeOfDay.fromDateTime(first));
    first = first.add(Duration(minutes: timeGap));
  }
  return list;
}
