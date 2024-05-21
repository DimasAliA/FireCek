import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';

class DateTemperatureCard extends StatelessWidget {
  final String date;
  final String time;
  final double temperature;
  final double humidity;
  final bool api;

  DateTemperatureCard({
    required this.date,
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthScaleFactor = screenWidth / 412;
    double textScaleFactor = widthScaleFactor > 1 ? 1 + (widthScaleFactor - 1) * 0.5 : widthScaleFactor;
    // double cardVerticalPadding = 60 * widthScaleFactor;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        top: 24 * widthScaleFactor,
        left: 16 * widthScaleFactor,
        right: 16 * widthScaleFactor,
        bottom: 60 * widthScaleFactor,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 24 * widthScaleFactor,
            horizontal: 24 * widthScaleFactor,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0 * widthScaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2 * widthScaleFactor,
                blurRadius: 5 * widthScaleFactor,
                offset: Offset(0, 3 * widthScaleFactor),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FIRE',
                    style: GoogleFonts.openSans(
                      fontSize: 25 * textScaleFactor,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      shadows: [
                            Shadow(
                              offset: Offset(2.0, 1.0),
                              blurRadius: 5.0,
                              color: Color.fromARGB(255, 150, 146, 146),
                            ),
                          ],
                    ),
                  ),
                  SizedBox(width: 4 * widthScaleFactor),
                  Icon(Icons.check_circle, color: Colors.black, size: 45 * widthScaleFactor),
                  SizedBox(width: 4 * widthScaleFactor),
                  Text(
                    'CEK',
                    style: GoogleFonts.openSans(
                      fontSize: 25 * textScaleFactor,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      shadows: [
                            Shadow(
                              offset: Offset(2.0, 1.0),
                              blurRadius: 5.0,
                              color: Color.fromARGB(255, 150, 146, 146),
                            ),
                          ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * widthScaleFactor),
              Divider(color: Colors.grey, thickness: 2 * widthScaleFactor),
              SizedBox(height: 8 * widthScaleFactor),
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.black, size: 20 * textScaleFactor),
                    SizedBox(width: 8 * widthScaleFactor),
                    Text(
                      date,
                      style: GoogleFonts.openSans(
                        fontSize: 16 * textScaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4 * widthScaleFactor),
              Text(
                time,
                style: GoogleFonts.openSans(
                  fontSize: 40 * textScaleFactor,
                  fontWeight: FontWeight.w900,
                  shadows: [
                      Shadow(
                        offset: Offset(2.0, 1.0),
                        blurRadius: 5.0,
                        color: Color.fromARGB(255, 150, 146, 146),
                      ),
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
        Positioned(
          top: 240 * widthScaleFactor,
          left: screenWidth * 0.1,
          right: screenWidth * 0.1,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(24.0 * widthScaleFactor),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 15 * widthScaleFactor,
                horizontal: 20 * widthScaleFactor,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0 * widthScaleFactor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDetailColumn('Suhu', '${temperature.toStringAsFixed(1)}°C', WeatherIcons.thermometer, Colors.green, textScaleFactor),
                  _buildDetailColumn('Kelembapan', '${humidity.toStringAsFixed(0)}%', WeatherIcons.humidity, Colors.blue, textScaleFactor),
                  _buildDetailColumn('API', '${api}', WeatherIcons.fire, Colors.red, textScaleFactor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value, IconData icon, Color color, double textScaleFactor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20 * textScaleFactor),
        SizedBox(height: 8 * textScaleFactor),
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * textScaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * textScaleFactor,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
