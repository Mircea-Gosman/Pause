/**-----------------------------------------------------------
 * Page routes mapping
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'login/LoginPage.dart';
import 'homePage/HomePage.dart';
import 'profile/ProfilePage.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/Login": (BuildContext context) => LoginPage(),
  "/Home": (BuildContext context) => HomePage(),
  "/Profile": (BuildContext context) => ProfilePage(),
};