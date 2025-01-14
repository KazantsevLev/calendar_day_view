import 'package:example/utils.dart';
import 'package:flutter/material.dart';

import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EventDayViewTab extends StatelessWidget {
  const EventDayViewTab({
    Key? key,
    required this.events,
  }) : super(key: key);
  final List<DayEvent<String>> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return EventCalendarDayView(
      events: events,
      eventDayViewItemBuilder: (context, index, event) {
        return HookBuilder(builder: (context) {
          final randomColor = useMemoized(() => getRandomColor());
          return Container(
            decoration: BoxDecoration(
              color:
                  index % 2 == 0 ? colorScheme.primary : colorScheme.secondary,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            height: 50,
            child: Center(
              child: Text(
                event.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
