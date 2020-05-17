/**-----------------------------------------------------------
 * Application homepage
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';

import '../profile/ProfileBar.dart';

/// Homepage Parent Widget
class HomePage extends StatefulWidget {
  // Create state
  @override
  _HomePageState createState() => _HomePageState();
}

/// Homepage State
class _HomePageState extends State<HomePage> {

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileBar(),
    );
  }
}
