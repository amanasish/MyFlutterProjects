import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HeartRateTab extends StatefulWidget {
  @override
  _HeartRateTabState createState() => _HeartRateTabState();
}

class _HeartRateTabState extends State<HeartRateTab> {
  int heartRate = 0;
  String heartbeatType = 'normal';
  DateTime timestamp = DateTime.now();
  Timer? timer;
  List<Map<String, dynamic>> recentReadings = [];

  // Use correct URL for web, emulator, or device
  late final String baseUrl;

  @override
  void initState() {
    super.initState();

    // Set backend URL to the live Render service
    baseUrl = 'https://elderly-care-backend-giv2.onrender.com/api/heart';

    fetchHeartData();
    timer = Timer.periodic(Duration(seconds: 1), (_) => fetchHeartData());
  }

  Future<void> fetchHeartData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          heartRate = data['heart_rate'];
          heartbeatType = data['heartbeat_type'];
          timestamp = DateTime.parse(data['timestamp']);
          recentReadings.insert(0, {
            'heart_rate': heartRate,
            'heartbeat_type': heartbeatType,
            'timestamp': timestamp,
          });
          if (recentReadings.length > 10) recentReadings.removeLast();
        });
      } else {
        print('Error: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching heart data: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color typeColor = heartbeatType == 'normal' ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Rate Monitor'), // removed emoji for font safety
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Circular Gauge
            CircularPercentIndicator(
              radius: 120,
              lineWidth: 15,
              percent: heartRate.clamp(0, 200) / 200,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: typeColor, size: 40),
                  SizedBox(height: 8),
                  Text(
                    '$heartRate bpm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              progressColor: typeColor,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            SizedBox(height: 24),

            // Status Card
            Card(
              color: typeColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.info, color: typeColor),
                title: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  heartbeatType.toUpperCase(),
                  style: TextStyle(color: typeColor),
                ),
                trailing: Text(
                  '${timestamp.toLocal().hour}:${timestamp.toLocal().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),

            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Readings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),

            Column(
              children: recentReadings
                  .map((reading) => _timelineCard(reading))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineCard(Map<String, dynamic> reading) {
    Color typeColor = reading['heartbeat_type'] == 'normal'
        ? Colors.green
        : Colors.red;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.favorite, color: typeColor),
        title: Text(
          '${reading['heart_rate']} bpm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(reading['heartbeat_type']),
        trailing: Text(
          '${reading['timestamp'].hour}:${reading['timestamp'].minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
