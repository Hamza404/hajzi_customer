
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

}