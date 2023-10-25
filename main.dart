import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'assessment1_6701213114_iskandarsani',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Stock Code: INTC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<SahamPoint>> getPoints() async {
    final apiKey = 'V84DxZhe9tB8kips_eSjNSdW4AZDDTNF';
    final stockSymbol = 'INTC';
    final startDate = '2023-01-09';
    final endDate = '2023-02-09';

    final apiUrl = Uri.parse(
        'https://api.polygon.io/v2/aggs/ticker/$stockSymbol/range/1/day/$startDate/$endDate?adjusted=true&sort=asc&limit=120&apiKey=$apiKey');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];

        if (results != null) {
          List<SahamPoint> out = [];
          int i = 1;
          double firstPrice = 0.0;

          for (var result in results) {
            double elem = result['o'].toDouble();
            if (i == 1) {
              firstPrice = elem;
            }
            var point = SahamPoint(x: i.toDouble(), y: elem, firstPrice: firstPrice);
            out.add(point);
            i++;
          }
          return out;
        }
      }
    } catch (e) {
      // Handle network errors or exceptions here.
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {}); // Trigger a rebuild when the button is pressed
                },
                child: const Text('Refresh Data'),
              ),
              FutureBuilder<List<SahamPoint>>(
                future: getPoints(),
                builder: (BuildContext context, AsyncSnapshot<List<SahamPoint>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
                    return Center(
                      child: Text('No data available.'),
                    );
                  } else {
                    final data = snapshot.data!;
                    return LineChartWidget(data);
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class SahamPoint {
  final double x;
  final double y;
  final double firstPrice;

  SahamPoint({required this.x, required this.y, required this.firstPrice});
}

class LineChartWidget extends StatelessWidget {
  final List<SahamPoint> points;

  const LineChartWidget(this.points, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstPrice = points.isNotEmpty ? points.first.firstPrice : 0.0;

    return Column(
      children: [
        Text(
          'First Price: $firstPrice',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 2,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
                  isCurved: false,
                  colors: [Colors.blue], // Specify the color here
                  dotData: FlDotData(show: true),
                )
                ,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
