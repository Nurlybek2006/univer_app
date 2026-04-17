/// Жаңалықтар моделі
class NewsItem {
  final String title;       // Тақырып
  final String description; // Сипаттама
  final String? imageUrl;   // Сурет сілтемесі (міндетті емес)
  final DateTime date;

  const NewsItem({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
  });
}
