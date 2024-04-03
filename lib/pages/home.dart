import 'package:flutter/material.dart';
import 'komponen/data_temperature.dart';
import 'komponen/firerecord.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'komponen/FireAlert.dart';
import 'komponen/notif.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
  final timeFormat = DateFormat('HH:mm', 'id_ID');
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('realtimeData');

  HomePage(){
      _ensureLoggedIn();
  }
  String get_salam_appbar() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi!';
    } else if (hour < 17) {
      return 'Selamat Siang!';
    } else if (hour < 20) {
      return 'Selamat Sore!';
    } else {
      return 'Selamat Malam!';
    }
  }

  Stream<Map<dynamic, dynamic>> get realtimeDataStream {
    return databaseReference.onValue.map((event) {
      return Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    });
  }

  String getFormattedTimeWithTimeZone() {
    final now = DateTime.now();
    final formattedTime = timeFormat.format(now);
    final timeZoneOffset = now.timeZoneOffset;
    String timeZoneSuffix = 'WIB';

    if (timeZoneOffset == Duration(hours: 8)) {
      timeZoneSuffix = 'WITA';
    } else if (timeZoneOffset == Duration(hours: 9)) {
      timeZoneSuffix = 'WIT';
    }

    return "$formattedTime $timeZoneSuffix";
  }
  Stream<String> get currentTimeStream {
    return Stream.periodic(Duration(seconds: 1), (_) {
      return getFormattedTimeWithTimeZone();
    });
  }
  Future<void> _ensureLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
      user = FirebaseAuth.instance.currentUser;
    }
    return;
  }
  String formatTemperatureChange(double temperature, double humidity, double api) {
    return "${temperature.toStringAsFixed(1)}° - ${humidity.toStringAsFixed(1)}% - ${api.toStringAsFixed(1)}%";
  }

  void addFireRecordToDatabase(Map<dynamic, dynamic> data) {
    final kebakaran = data['kebakaran'];
    final temperature = data['temperature'].toDouble();
    final humidity = data['humidity'].toDouble();
    final api = data['api'].toDouble();
    
    if (kebakaran) {
      final now = DateTime.now();
      final String formattedDate = dateFormat.format(now);
      final String formattedTime = getFormattedTimeWithTimeZone();
      final String dayOfWeek = DateFormat('EEEE', 'id_ID').format(now);
      final String temperatureChange = formatTemperatureChange(temperature, humidity, api);

      final DatabaseReference fireHistoryRef = FirebaseDatabase.instance.ref().child('fireHistory');
      final newFireHistoryKey = fireHistoryRef.push().key;
      if (newFireHistoryKey != null) {
        fireHistoryRef.child(newFireHistoryKey).set({
          'date': formattedDate,
          'day': dayOfWeek,
          'temperatureChange': temperatureChange,
          'time': formattedTime,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = 40.0 + MediaQuery.of(context).padding.top;
    final double blueBackgroundHeight = MediaQuery.of(context).size.height * 0.4;
    final currentDate = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 32, 81, 229),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 12.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      get_salam_appbar(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Pastikan Sistem Kebakaranmu Siap Pakai!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
      body: FutureBuilder(
        future: _ensureLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamBuilder<Map<dynamic, dynamic>>(
                    stream: realtimeDataStream,
                    builder: (context, snapshot) {
                      List<Widget> children = [];

                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        if (data['kebakaran'] == true) {
                          LocalNotificationService.showNotificationWithCustomSound();
                          addFireRecordToDatabase(data);
                          children.add(
                            Container(
                              color: Color.fromARGB(255, 32, 81, 229),
                              child: FireAlert(
                                message: 'Terjadi Kebakaran! segera lakukan tindakan',
                                onDismissed: () {
                                  // Logika pencet x
                                },
                              ),
                            ),
                          );
                        }
                        children.add(
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Container(
                              color: const Color.fromARGB(255, 32, 81, 229),
                              height: blueBackgroundHeight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: StreamBuilder<String>(
                                    stream: currentTimeStream,
                                    builder: (context, timeSnapshot) {
                                      final time = timeSnapshot.data ?? getFormattedTimeWithTimeZone();
                                      return DateTemperatureCard(
                                        date: currentDate,
                                        time: time,
                                        temperature: data['temperature'].toDouble(),
                                        humidity: data['humidity'].toDouble(),
                                        api: data['api'].toDouble(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                        children.add(FireRecords());

                        return Column(children: children);
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error signing in: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}