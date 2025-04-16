import 'package:flutter/material.dart';
import 'package:world_time/services/world_time.dart';
import 'package:world_time/pages/loading.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data: ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    print(data);

    //set background
    String bgImage = data['isDayTime']==true ? 'dayimg.jpg': 'nightimg.jpg';
    Color bgColor = data['isDayTime'] ==true ? Colors.cyan.shade200 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/$bgImage'),
            fit: BoxFit.cover,
            )
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 110, 0, 0),
            child: Column(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () async{
                    dynamic result= await Navigator.pushNamed(context, '/location');
                    setState(() {
                      data={
                        'presenttime':result['presenttime'],
                        'location' :result['location'],
                        'presentday' :result['presentday'],
                        'flag':result['flag'],
                        'isDayTime':result['isDayTime']

                      };
                    });
                  },
                  icon: Icon(Icons.edit_location),
                  label: Text(
                    'change location',
                    style: TextStyle(fontSize: 25,
                    color: Colors.white54
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data ['location'],
                      style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 2,
                          color: Colors.white70
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Text(data['presenttime'],style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                    color: Colors.white70

                ),),
                SizedBox(height: 10,),
                Text(data['presentday'],style: TextStyle(
                  fontSize: 40,
                  letterSpacing: 2,
                    color: Colors.white54
                ),)

              ],
            ),
          ),
        ),
      ),
    );
  }
}
