import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String urgency;
  String status; // OPEN, CLAIMED, PENDING_CONFIRMATION, COMPLETED
  final String requesterId;
  final String requesterName;
  final String? requesterAvatarUrl;
  final String? photoUrl;
  String? claimedBy;
  String? claimedByName;
  DateTime? claimedAt;
  bool requesterConfirmed;
  bool helperConfirmed;
  DateTime? completedAt;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    required this.requesterId,
    required this.requesterName,
    this.requesterAvatarUrl,
    this.photoUrl,
    this.claimedBy,
    this.claimedByName,
    this.claimedAt,
    this.requesterConfirmed = false,
    this.helperConfirmed = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'urgency': urgency,
      'status': status,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterAvatarUrl': requesterAvatarUrl,
      'photoUrl': photoUrl,
      'claimedBy': claimedBy,
      'claimedByName': claimedByName,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
      'requesterConfirmed': requesterConfirmed,
      'helperConfirmed': helperConfirmed,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      urgency: data['urgency'] ?? 'Normal',
      status: data['status'] ?? 'OPEN',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? 'Unknown',
      requesterAvatarUrl: data['requesterAvatarUrl'],
      photoUrl: data['photoUrl'],
      claimedBy: data['claimedBy'],
      claimedByName: data['claimedByName'],
      claimedAt: (data['claimedAt'] as Timestamp?)?.toDate(),
      requesterConfirmed: data['requesterConfirmed'] ?? false,
      helperConfirmed: data['helperConfirmed'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
