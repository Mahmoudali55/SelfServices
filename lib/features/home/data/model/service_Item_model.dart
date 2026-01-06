class ServiceItem {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameUr;
  final String image;

  ServiceItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameUr,
    required this.image,
  });

  String getName(String langCode) {
    if (langCode == 'ar') {
      return nameAr;
    } else if (langCode == 'ur') {
      return nameUr;
    } else {
      return nameEn;
    }
  }
}
