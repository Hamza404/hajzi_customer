
import 'package:flutter/cupertino.dart';

class Constants {

  static String getServiceNameById(int id) {
    final services = [
      {"id": 1, "name": "Hair & Styling"},
      {"id": 2, "name": "Car Wash & Services"},
      {"id": 3, "name": "Restaurant"},
      {"id": 4, "name": "Beauty Parlor"},
      {"id": 5, "name": "Massage"},
      {"id": 6, "name": "Medical & Dental"},
    ];

    final service = services.firstWhere(
          (item) => item["id"] == id,
      orElse: () => {},
    );

    return service["name"].toString();
  }

  static double getResponsiveFontSize(BuildContext context, double size) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;

    return size * (screenWidth / baseWidth);
  }

}