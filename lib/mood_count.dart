import 'package:flutter/material.dart';
import 'mood.dart';

class MoodCount extends StatelessWidget{
final Map<DateTime, String> moodEvents;
Map<String, int> moodCounts = {};

MoodCount({
  required this.moodEvents,
});

  @override
  Widget build(BuildContext context){
    print("count 통계 페이지");
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Count"),
      ),
    );

    // TODO : implement build
    throw UnimplementedError();
  }
}
