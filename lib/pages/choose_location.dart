import 'package:flutter/material.dart';

import '../services/world_time.dart';
class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  List<WorldTime> locations = [
    WorldTime(url: 'Europe/London', location: 'London', flag: 'uk.png'),
    WorldTime(url: 'America/Chicago', location: 'Chicago', flag: 'usa.png'),
    WorldTime(url: 'America/New_York', location: 'New York', flag: 'usa.png'),
    WorldTime(url: 'Asia/Kathmandu', location: 'Kathmandu', flag: 'nepal.png'),
    WorldTime(url: 'Asia/Tokyo', location: 'Tokyo', flag: 'japan.png'),
    WorldTime(url: 'Asia/Shanghai', location: 'Shanghai', flag: 'china.png'),
    WorldTime(url: 'Australia/Sydney', location: 'Sydney', flag: 'australia.png'),
    WorldTime(url: 'America/Sao_Paulo', location: 'São Paulo', flag: 'brazil.png'),
  ];
  void updateTime (index) async{
    WorldTime instance =locations[index];
    await instance.getTime();
    //navigate to home screen
    Navigator.pop(context , {
      'location': instance.location,
      'presenttime': instance.presenttime,
      'flag': instance.flag,
      'presentday': instance.presentday,
      'isDayTime':instance.isDayTime,
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title:Text("Choose the location"),
        centerTitle: true,
        elevation: 0,

      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
            child: Card(
              child: ListTile(
                onTap: (){
                  updateTime(index);
                },
                title:Text(locations[index].location) ,
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/${locations[index].flag}'),
                ),
              )
              ,
            ),
          );
        },

      ),

    );
  }
}
