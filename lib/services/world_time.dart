import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  late String location; // location name for the UI
  late String presenttime; // time of the location
  late String flag; // URL to the asset flag icon
  late String url;
  late String presentday; // location URL for API endpoint
  late bool isDayTime ;

  WorldTime({required this.location, required this.flag, required this.url});

  Future<void> getTime() async {
    try {
      //make the request
      Response response = await get(Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=$url'));
      Map data =jsonDecode(response.body);


        // Getting properties from data
        String date = data['date'] ;
        String time = data['time'] ;
        String day = data['dayOfWeek'] ;

        presenttime = time;
        presentday = day;

      List<String> timeParts = time.split(':');
      int hour = int.parse(timeParts[0]);

      isDayTime = hour >= 6 && hour < 18 ? true: false;

    }
    catch (e) {
      print('Caught error: $e');
      presenttime = 'Could not get time';
      presentday = 'unknown';
      isDayTime = false;
    }
  }
}
