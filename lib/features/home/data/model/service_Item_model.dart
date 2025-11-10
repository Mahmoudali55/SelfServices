class ServiceItem {
  final int id;
  final String nameAr;
  final String nameEn;
  final String image;
  

  ServiceItem({required this.id, required this.nameAr, required this.nameEn, required this.image});

  String getName(String langCode) {
    return langCode == 'ar' ? nameAr : nameEn;
  }
}
