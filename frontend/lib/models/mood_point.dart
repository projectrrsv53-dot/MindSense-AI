//    models/mood_point.dart

class MoodPoint {

  final String day;

  final double score;

  MoodPoint({
    required this.day,
    required this.score,
  });

  factory MoodPoint.fromJson(
      Map<String, dynamic> json,
      ) {

    return MoodPoint(

      day:
      json['day']
          .toString(),

      score:
      (json['score'] as num)
          .toDouble(),
    );
  }
}