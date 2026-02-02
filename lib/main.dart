import 'package:flutter/material.dart';
import 'view/home.dart';
import 'view/login.dart';
import 'view/quality_pl/quality_dashboard.dart';
import 'view/quality_tk/quality_dashboard.dart';
import 'view/quality_tt/quality_dashboard.dart';
import 'view/quality_pb/quality_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginForm(),
      routes: <String, WidgetBuilder>{
        '/HomeWB': (BuildContext context) => HomeWB(datauser[0]['name']),
        '/LoginForm': (BuildContext context) => LoginForm(),
        '/QualityDashboardPL': (BuildContext context) => QualityDashboardPL(),
        '/QualityDashboardTK': (BuildContext context) => QualityDashboardTK(),
        '/QualityDashboardTT': (BuildContext context) => QualityDashboardTT(),
        '/QualityDashboardPB': (BuildContext context) => QualityDashboardPB(),
      },
    );
  }
}
