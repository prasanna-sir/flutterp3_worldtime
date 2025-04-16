import 'package:flutter/material.dart';
import 'package:world_time/services/world_time.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setupWorldTime() async {

      WorldTime obj = WorldTime(location: 'Kathmandu', flag: 'flag.png', url: 'Asia/Kathmandu');
      await obj.getTime();

      // Navigate only if mounted (widget still exists)
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'location': obj.location,
        'presenttime': obj.presenttime,
        'flag': obj.flag,
        'presentday': obj.presentday,
        'isDayTime':obj.isDayTime,
      });
   }
  @override
  void initState() {
    super.initState();
    // Delay setup to allow build context to be fully ready
    Future.delayed(Duration.zero, () {
      setupWorldTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitChasingDots(
          color:Colors.green,
          size: 36,
        ),
      ),
    );
  }
}
