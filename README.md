<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter hourly calendar

Flutter hourly calendar. Visualizes your event according to the selected time of day

## Screenshots

|                                                                                            |                                                                                            |
| :----------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------: |
| ![poc](https://github.com/sbaskoy/flutter_hourly_calendar/blob/main/images/1.png?raw=true) | ![poc](https://github.com/sbaskoy/flutter_hourly_calendar/blob/main/images/2.png?raw=true) |

|                                                                                            |                                                                                            |
| :----------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------: |
| ![poc](https://github.com/sbaskoy/flutter_hourly_calendar/blob/main/images/3.png?raw=true) | ![poc](https://github.com/sbaskoy/flutter_hourly_calendar/blob/main/images/4.png?raw=true) |

## Usage

```dart
 HourlyCalendar(
          controller: controller,
          onSelected: (selectedItem, controller) {
            print("${selectedItem.startTime} - ${selectedItem.endTime}");
          },
        ),
```

```dart
  var random = math.Random();
  late var items = List.generate(20, (index) {
    return CalendarData<String>(
        title: "Event $index",
        id: "$index",
        startTime: DateTime.now().add(const Duration(days: -5)).add(Duration(days: index)).copyWith(
              hour: random.nextInt(20) - 10,
              minute: random.nextInt(59),
            ),
        endTime: DateTime.now().add(const Duration(days: -5)).add(Duration(days: index)).copyWith(
              hour: random.nextInt(23) + 12,
              minute: random.nextInt(59),
            ),
        data: "event $index",
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
  });
  late final HourlyCalendarController controller = HourlyCalendarController(items, date: DateTime.now());
```

## Params

`HourlyCalendarController`

- `List<CalendarData<T>> items, {this.oneHourHeight = 40, DateTime? date}`

- `items` : your events. Type `List<CalendarData<T>>`

- `oneHourHeight`: 1 hour total height.All calculations are based on this value

```dart
  double _findHeight(DateTime start, DateTime end) {
    // total height of on second
    var perSecondHeight = controller.oneHourHeight / 3600;

    var diff = start.difference(end);
    // total event seconds
    var totalSecond = diff.inSeconds;
    // total event height
    return (totalSecond * perSecondHeight).toDouble().abs();
  }

```

`date` : selected calendar date. default is `DateTime.now()`

`HourlyCalendar`

- `controller [HourlyCalendarController]` calender controller. You must specify your events in the controller.

- ` mainContainerDecoration` - `[BoxDecoration]` main container decoration

- `hourContainerDecoration` - `[BoxDecoration]`container decoration each hour

- `hourTextStyle` - [TextStyle] text style each hour

- `bottomListTitleStyle` - [TextStyle] footer list text style

- `bottomListHourStyle` - [TextStyle] footer list duration style

- `controller` - [HourlyCalendarController] calendar controller

- `hideHeader` - [bool] hide header if is `true`

- `hideFooter` - [bool] hide footer if is `true`

- `headerHeight` - [double] header height

- `hoursWidth` - [double] hours width

- `headerDateTextStyle` - [TextStyle] header text style

- `headerDateFormat` - [String] header date text date format

- `hourBuilder` - build each hour

```dart
 (context,hour) =>  Container(
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
  )
```

- `itemBuilder` -> build each event

```dart

  (context,item,controller,selectedId) => InkWell(
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
   );
```

- `bottomItemListBuilder` -> build bottom event list

```dart
  (context,item,controller,selectedId)=>Row(children:[
   Text(item.startTime),
   Text(item.endTime),
  ])
```

- `onSelected` - onClicked Event `(selectedItem,controller) => void`
- `onRefresh` - onRefresh Event `() => void`

- `headerBuilder` - header builder

````dart
   (date,controller)=>Row(
     children:[
     Button(onPress:controller.previousDate,text:'Previous'),
     Expanded(child: Text(date.toString().format("HH:mm")),)
     Button(onPress:controller.nextDate,text:'Next')
   ])
     ```

````
