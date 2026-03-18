class RequestModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String urgency;
  final String status;
  final String requesterName;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    required this.requesterName,
  });
}
