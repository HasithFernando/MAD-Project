class Review {
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating']?.toDouble() ?? 0,
      comment: map['comment'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
