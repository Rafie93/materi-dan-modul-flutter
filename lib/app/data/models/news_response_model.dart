import 'article_model.dart';

/// Model untuk response dari News API
/// Berisi status, total hasil, dan list artikel
class NewsResponseModel {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;

  NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  /// Factory method untuk parsing response JSON dari API
  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      status: json['status'] as String? ?? '',
      totalResults: json['totalResults'] as int? ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((article) => ArticleModel.fromJson(article as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
