import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getTime() async {
    //making the request
    Response response= await get (Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=Asia/Kathmandu'));
    Map data= jsonDecode(response.body);
    // print(data);
    // getting properties from data
    String date = data['date'];
    String time = data['time'];
    String day = data['dayOfWeek'];

    print (date);
    print (time);
    print(day);




  }
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    getTime();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Loading Screen'),
    );
  }
}
