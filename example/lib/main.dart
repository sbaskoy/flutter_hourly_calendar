import 'package:flutter/material.dart';
import 'package:flutter_hourly_calendar/flutter_hourly_calendar.dart';
import "dart:math" as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HourlyCalendar(
          
          controller: controller,
          onSelected: (selectedItem, controller) {
            print("${selectedItem.startTime} - ${selectedItem.endTime}");
          },
        ),
      ),
    );
  }
}
