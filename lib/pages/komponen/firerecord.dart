import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FireRecord {
  final String day;
  final String date;
  final String temperatureChange;
  final String time;

  FireRecord({
    required this.day,
    required this.date,
    required this.temperatureChange,
    required this.time,
  });

  factory FireRecord.fromMap(Map<dynamic, dynamic> data) {
    return FireRecord(
      day: data['day'] as String? ?? '',
      date: data['date'] as String? ?? '',
      temperatureChange: data['temperatureChange'] as String? ?? '',
      time: data['time'] as String? ?? '',
    );
  }
}

class FireRecords extends StatefulWidget {
  @override
  _FireRecordsState createState() => _FireRecordsState();
}

class _FireRecordsState extends State<FireRecords> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('fireHistory');
  bool isExpanded = false;
  Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            isExpanded = false;
          });
        },
        child: ExpansionTileCard(
          baseColor: Color.fromARGB(255, 77, 109, 227),
          expandedColor: Colors.white,
          title: Text(
            'CATATAN KEBAKARAN',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          subtitle: Text(
            'Klik untuk melihat detail',
            style: TextStyle(color: textColor.withOpacity(0.6)),
          ),
          leading: Icon(
            Icons.warning,
            color: textColor,
          ),
          trailing: Icon(
            Icons.arrow_drop_down,
            color: textColor,
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              isExpanded = expanded;
              textColor = expanded ? Colors.black : Colors.white;
            });
          },
          initiallyExpanded: isExpanded,
          children: <Widget>[
            Divider(height: 1, thickness: 1),
            StreamBuilder<DatabaseEvent>(
              stream: databaseRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  Map<dynamic, dynamic> values = snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
                  List<FireRecord> records = values.entries.map((entry) {
                    return FireRecord.fromMap(Map<dynamic, dynamic>.from(entry.value));
                  }).toList();
                  records.sort((a, b) {
                    DateFormat dateFormat = DateFormat('d MMMM yyyy HH:mm', 'id_ID');
                    DateTime aDateTime = dateFormat.parse(a.date + ' ' + a.time);
                    DateTime bDateTime = dateFormat.parse(b.date + ' ' + b.time);
                    return bDateTime.compareTo(aDateTime);
                  });
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: records.map(_buildRecordItem).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(FireRecord record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        title: Text(record.day + ', ' + record.date, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(record.temperatureChange),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.history_rounded, color: Colors.blue),
            SizedBox(height: 4),
            Text(record.time),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Records')),
        body: FireRecords(),
      ),
    ),
  );
}

