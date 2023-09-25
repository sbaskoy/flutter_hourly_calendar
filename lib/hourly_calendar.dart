library flutter_hourly_calendar;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hourly_calendar/extensions/datetime_extension.dart';
import 'package:flutter_hourly_calendar/extensions/string_extension.dart';
import 'package:flutter_hourly_calendar/flutter_hourly_calendar.dart';
import 'package:rxdart/rxdart.dart';

class HourlyCalendarController<T> {
  final List<CalendarHour> hours = List.generate(24, (index) => CalendarHour(index));
  final double oneHourHeight;

  HourlyCalendarController(List<CalendarData<T>> items, {this.oneHourHeight = 40, DateTime? date}) {
    this._items.sink.add(items);
    var firstItem = hours.indexWhere((element) => !element.isShift);
    if (date != null) {
      _selectedDate.sink.add(date);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      mainScrollController.animateTo(
        firstItem * oneHourHeight,
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
      );
    });
  }

  final _selectedId = BehaviorSubject<String>();
  Function(String) get setSelected => _selectedId.sink.add;
  Stream<String> get selectedIdStream => _selectedId.stream;

  final _selectedDate = BehaviorSubject.seeded(DateTime.now());

  Function(DateTime) get setSelectedDate => _selectedDate.sink.add;
  Stream<DateTime> get getSelectedDateStream => _selectedDate.stream;
  DateTime get selectedDate => _selectedDate.valueOrNull ?? DateTime.now();

  final _items = BehaviorSubject<List<CalendarData<T>>>.seeded([]);

  Stream<List<CalendarData<T>>> get getItemList => Rx.combineLatest2(_items, _selectedDate, (a, b) {
        var items = _items.valueOrNull ?? [];
        var selectedDate = _selectedDate.valueOrNull ?? DateTime.now();
        return items.where((item) {
          var startTime = item.startTime;
          var endTime = item.endTime;
          return selectedDate.isBetweenDaily(startTime, endTime);
        }).toList();
      });

  final ScrollController mainScrollController = ScrollController();
  void nextDate() {
    _selectedDate.sink.add(selectedDate.add(const Duration(days: 1)));
  }

  void previousDate() {
    _selectedDate.sink.add(selectedDate.add(const Duration(days: -1)));
  }
}

class HourlyCalendar<T> extends StatelessWidget {
  /// [BoxDecoration] main container decoration
  final BoxDecoration? mainContainerDecoration;

  /// [BoxDecoration] container decoration each hour
  final BoxDecoration? hourContainerDecoration;

  /// [TextStyle] text style each hour
  final TextStyle? hourTextStyle;

  /// [TextStyle] footer list text style
  final TextStyle? bottomListTitleStyle;

  /// [TextStyle] footer list duration style
  final TextStyle? bottomListHourStyle;

  /// [HourlyCalendarController] calendar controller
  final HourlyCalendarController<T> controller;

  /// [bool] hide header if is `true`
  final bool hideHeader;

  /// [bool] hide footer if is `true`
  final bool hideFooter;

  /// [double] header height
  final double headerHeight;

  /// [double] hours width
  final double hoursWidth;

  /// [TextStyle] header text style
  final TextStyle? headerDateTextStyle;

  /// [String] header date text date format
  final String headerDateFormat;

  /// build each hour
  /// ```dart
  /// (context,hour) =>  Container(
  ///    padding: const EdgeInsets.all(8),
  ///    decoration: hourContainerDecoration ??
  ///        BoxDecoration(
  ///          border: Border(
  ///            right: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.5)),
  ///          ),
  ///        ),
  ///    child: Center(
  ///      child: Text(
  ///        hour.text,
  ///        style: hourTextStyle ??
  ///            Theme.of(context).textTheme.bodyLarge!.copyWith(
  ///                  fontSize: 15,
  ///                  color: hour.isShift
  ///                      ? Theme.of(context).disabledColor.withOpacity(0.3)
  ///                      : Theme.of(context).disabledColor,
  ///                ),
  ///      ),
  ///    ),
  ///  )
  /// ```
  final Widget Function(BuildContext context, CalendarHour hour)? hourBuilder;

  /// item builder
  ///
  /// ```dart
  ///
  ///(context,item,controller,selectedId) => InkWell(
  ///   onLongPress: () {
  ///     controller.setSelected(item.id);
  ///     if (onSelected != null) {
  ///       onSelected!(item, controller);
  ///     }
  ///   },
  ///   onTap: () => controller.setSelected(item.id),
  ///   child: Container(
  ///     // width: 100,
  ///     height: mainContainerHeight,
  ///     decoration: BoxDecoration(
  ///       color: selectedId == item.id ? item.color : item.color.withAlpha(150),
  ///       borderRadius: BorderRadius.circular(5),
  ///     ),
  ///     child: Center(
  ///       child: RotatedBox(
  ///         quarterTurns: 1,
  ///         child: FittedBox(
  ///           child: Text(
  ///             item.title,
  ///             style: hourTextStyle ??
  ///                 Theme.of(context).textTheme.bodyLarge!.copyWith(
  ///                       fontSize: 15,
  ///                       color: Colors.white,
  ///                     ),
  ///           ),
  ///         ),
  ///       ),
  ///     ),
  ///   ),
  /// );
  /// ```
  final Widget Function(
          BuildContext context, CalendarData<T> item, HourlyCalendarController<T> controller, String? selectedId)?
      itemBuilder;

  ///
  ///```dart
  ///(context,item,controller,selectedId)=>Row(children:[
  /// Text(item.startTime),
  /// Text(item.endTime),
  ///])
  ///```
  final Widget Function(
          BuildContext context, CalendarData<T> item, HourlyCalendarController<T> controller, String? selectedId)?
      bottomItemListBuilder;
  final void Function(CalendarData<T> selectedItem, HourlyCalendarController<T> controller)? onSelected;

  /// refresh data
  final Future<void> Function()? onRefresh;

  /// header builder
  /// ```dart
  /// (date,controller)=>Row(
  ///   children:[
  ///   Button(onPress:controller.previousDate),
  ///   Text(date.toString().format("HH:mm")),
  ///   Button(onPress:controller.nextDate)
  /// ]
  /// )
  ///
  /// ```

  final Widget Function(DateTime date, HourlyCalendarController<T> controller)? headerBuilder;

  const HourlyCalendar({
    super.key,
    required this.controller,
    this.hourBuilder,
    this.itemBuilder,
    this.hourTextStyle,
    this.mainContainerDecoration,
    this.bottomItemListBuilder,
    this.bottomListTitleStyle,
    this.bottomListHourStyle,
    this.onSelected,
    this.onRefresh,
    this.hideHeader = false,
    this.hideFooter = false,
    this.headerBuilder,
    this.headerDateTextStyle,
    this.headerDateFormat = "DD.MM.YYYY dddd",
    this.headerHeight = 40,
    this.hoursWidth = 75,
    this.hourContainerDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hideHeader != true) _buildHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh ?? () async {},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: controller.mainScrollController,
              child: SizedBox(
                height: controller.hours.length * controller.oneHourHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                        children: controller.hours.map((e) {
                      return SizedBox(
                        height: controller.oneHourHeight,
                        width: hoursWidth,
                        child: hourBuilder != null ? hourBuilder!(context, e) : _buildHour(context, e),
                      );
                    }).toList()),
                    Expanded(
                      child: _buildItemBuilder(context),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hideFooter != true) _buildBottomList(context),
      ],
    );
  }

  StreamBuilder<DateTime> _buildHeader() {
    return StreamBuilder<DateTime>(
        stream: controller.getSelectedDateStream,
        builder: (context, snapshot) {
          var date = snapshot.data ?? DateTime.now();
          return SizedBox(
            height: headerHeight,
            child: headerBuilder != null
                ? headerBuilder!(date, controller)
                : Row(
                    children: [
                      IconButton(onPressed: controller.previousDate, icon: const Icon(Icons.arrow_back)),
                      Expanded(
                        child: Center(
                          child: Text(
                            date.toString().format(headerDateFormat),
                            style: headerDateTextStyle ??
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(onPressed: controller.nextDate, icon: const Icon(Icons.arrow_forward)),
                    ],
                  ),
          );
        });
  }

  Widget _buildBottomList(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
          color: Theme.of(context).disabledColor.withOpacity(0.5),
        ))),
        child: SingleChildScrollView(
          child: StreamBuilder<String>(
              stream: controller.selectedIdStream,
              builder: (context, snapshot) {
                var selectedId = snapshot.data;

                return StreamBuilder<List<CalendarData<T>>>(
                    stream: controller.getItemList,
                    builder: (context, snapshot) {
                      var items = snapshot.data ?? [];
                      return Column(
                          children: items.map((e) {
                        if (bottomItemListBuilder != null) {
                          return bottomItemListBuilder!(context, e, controller, selectedId);
                        }
                        var startDate = e.startTime.toString();
                        var stopDate = e.endTime.toString();
                        return InkWell(
                          onTap: () {
                            controller.setSelected(e.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: selectedId == e.id ? 1.2 : 1,
                                  child: CircleAvatar(
                                    backgroundColor: e.color,
                                    radius: 10,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    e.title,
                                    style: bottomListTitleStyle ??
                                        Theme.of(context).textTheme.bodyLarge!.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (onSelected != null) {
                                      onSelected!(e, controller);
                                    }
                                  },
                                  child: Wrap(
                                    runSpacing: 5,
                                    spacing: 5,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "${startDate.format('HH:mm')} - ${stopDate.format('HH:mm')}",
                                        style: bottomListHourStyle ??
                                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context).disabledColor.withOpacity(0.1),
                                        radius: 12,
                                        child: Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: Theme.of(context).disabledColor.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList());
                    });
              }),
        ),
      ),
    );
  }

  Widget _buildItemBuilder(BuildContext context) {
    return StreamBuilder<List<CalendarData<T>>>(
        stream: controller.getItemList,
        builder: (context, snapshot) {
          var items = snapshot.data ?? [];
          return Container(
            decoration: mainContainerDecoration ??
                const BoxDecoration(
                    //color: Colors.blue,
                    ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildItems(context, items),
              ),
            ),
          );
        });
  }

  List<Widget> _buildItems(BuildContext context, List<CalendarData<T>> items) {
    return items.map((item) {
      var startDate = item.startTime;
      var stopDate = item.endTime;
      var selectedDate = controller.selectedDate;
      // eğer secili tarihler arasında degillerse o araya sıkıştır
      if (startDate.getOnlyDate().isBefore(selectedDate.getOnlyDate())) {
        startDate = selectedDate.copyWith(hour: 0, minute: 0);
      }
      if (stopDate.getOnlyDate().isAfter(selectedDate.getOnlyDate())) {
        stopDate = selectedDate.copyWith(hour: 23, minute: 59);
      }

      var emptyStartContainerHeight = _findHeight(selectedDate.copyWith(hour: 0, minute: 0, second: 0), startDate);
      var mainContainerHeight = _findHeight(startDate, stopDate);
      var emptyEndContainerHeight = _findHeight(stopDate, selectedDate.copyWith(hour: 23, minute: 59, second: 59));

      return StreamBuilder<String>(
          stream: controller.selectedIdStream,
          builder: (context, snapshot) {
            var selectedId = snapshot.data;

            return Expanded(
              child: Container(
                // height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    border: Border(
                  right: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.1)),
                )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      // color: item.color.withOpacity(0.1),
                      height: emptyStartContainerHeight,
                    ),
                    itemBuilder != null
                        ? itemBuilder!(context, item, controller, selectedId)
                        : InkWell(
                            onLongPress: () {
                              controller.setSelected(item.id);
                              if (onSelected != null) {
                                onSelected!(item, controller);
                              }
                            },
                            onTap: () => controller.setSelected(item.id),
                            child: Container(
                              // width: 100,
                              height: mainContainerHeight,
                              decoration: BoxDecoration(
                                color: selectedId == item.id ? item.color : item.color.withAlpha(150),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: FittedBox(
                                    child: Text(
                                      item.title,
                                      style: hourTextStyle ??
                                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Container(
                      //color: item.color.withOpacity(0.1),
                      height: emptyEndContainerHeight,
                    ),
                  ],
                ),
              ),
            );
          });
    }).toList();
  }

  double _findHeight(DateTime start, DateTime end) {
    // var totalDailySecond = 86400;
    var perSecondHeight = controller.oneHourHeight / 3600;
    // 60 saniye 40 ise 1 saniye
    var diff = start.difference(end);
    var totalSecond = diff.inSeconds;
    return (totalSecond * perSecondHeight).toDouble().abs();
  }

  Widget _buildHour(BuildContext context, CalendarHour hour) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: hourContainerDecoration ??
          BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.5)),
            ),
          ),
      child: Center(
        child: Text(
          hour.text,
          style: hourTextStyle ??
              Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 15,
                    color: hour.isShift
                        ? Theme.of(context).disabledColor.withOpacity(0.3)
                        : Theme.of(context).disabledColor,
                  ),
        ),
      ),
    );
  }
}
