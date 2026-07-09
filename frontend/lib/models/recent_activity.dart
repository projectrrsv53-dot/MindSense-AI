class RecentActivity {

  final String type;
  final String title;
  final String time;

  RecentActivity({
    required this.type,
    required this.title,
    required this.time,
  });

  factory RecentActivity.fromJson(
      Map<String,dynamic> json){

    return RecentActivity(

      type: json["type"],

      title:
      json["name"] ??
          json["patient"] ??
          "",

      time:
      json["time"].toString(),

    );

  }

}