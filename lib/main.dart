import 'package:flutter/material.dart';
import 'package:world_time/pages/MapPage.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';
import 'package:world_time/pages/choose_location.dart';
import 'package:world_time/pages/MapPage.dart';

void main() => runApp(MaterialApp(
  routes: {
    '/' :(context) => Loading(),
    '/home' : (context) => Home(),
    '/location' :(context) => ChooseLocation(),
    '/map' : (context)=> MapPage(),

  },


));
 