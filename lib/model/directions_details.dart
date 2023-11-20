class DirectionDetails {
  String? distanceText;
  String? durationText;
  int? distanceValue;
  int? durationValue;
  String? encodedPoints;

  DirectionDetails({
    this.distanceText,
    this.durationText,
    this.distanceValue,
    this.durationValue,
    this.encodedPoints,
  });

  // DirectionDetails.fromJson(Map<String, dynamic> json) {
  //   distanceText = json["distanceText"];
  //   durationText = json["durationText"];
  //   distanceValue = json["distanceValue"];
  //   durationValue = json["durationValue"];
  //   encodedPoints = json["steps"];
  // }
}
