import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yanxuan/page/main/main_page.dart';
import 'package:flutter_yanxuan/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1242, 2208),
      builder: () => MaterialApp(
        theme: ThemeData(
          backgroundColor: Colors.transparent,
          primarySwatch: Colors.red,
        ),
        title: "yanxuan",
        routes: routes,
        home: ChangeNotifierProvider(
          create: (context) => TabbarModel(),
          child: MainPage(),
        ),
      ),
    );
  }
}
