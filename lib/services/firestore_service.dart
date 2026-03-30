import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';

/// Centralized Firestore service for all backend operations.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';
  String get _userName => _auth.currentUser?.displayName ?? 'Unknown';

  // ═══════════════════════════════════════════
  // REQUESTS
  // ═══════════════════════════════════════════

  CollectionReference get _requestsCol => _firestore.collection('requests');

  /// Create a new help request.
  Future<void> createRequest({
    required String title,
    required String description,
    required String category,
    required String urgency,
  }) async {
    if (_uid.isEmpty) return;

    // Fetch confirmed name from Firestore Profile to avoid "Unknown" if Auth displayName is missing
    final profile = await getUserProfile();
    final realName = (profile != null && profile.containsKey('name') && profile['name'].toString().isNotEmpty) 
        ? profile['name'] as String
        : _userName;

    final request = RequestModel(
      id: '',
      title: title,
      description: description,
      category: category,
      urgency: urgency,
      status: 'OPEN',
      requesterId: _uid,
      requesterName: realName,
    );
    await _requestsCol.add(request.toMap());
  }

  /// Stream all OPEN requests (real-time feed for home page).
  Stream<List<RequestModel>> streamOpenRequests() {
    return _requestsCol
        .where('status', isEqualTo: 'OPEN')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => RequestModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Check if current user has an active claim (CLAIMED or PENDING_CONFIRMATION).
  Future<bool> hasActiveClaim() async {
    if (_uid.isEmpty) return false;
    try {
      final snap = await _requestsCol
          .where('claimedBy', isEqualTo: _uid)
          .where('status', whereIn: ['CLAIMED', 'PENDING_CONFIRMATION'])
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Claim an open request.
  Future<void> claimRequest(String requestId) async {
    if (_uid.isEmpty) return;

    // Fetch confirmed name from Firestore Profile to avoid "Unknown"
    final profile = await getUserProfile();
    final realName = (profile != null && profile.containsKey('name') && profile['name'].toString().isNotEmpty) 
        ? profile['name'] as String
        : _userName;

    await _requestsCol.doc(requestId).update({
      'status': 'CLAIMED',
      'claimedBy': _uid,
      'claimedByName': realName,
      'claimedAt': Timestamp.now(),
    });
  }

  /// Helper marks "Help Done" → moves to PENDING_CONFIRMATION.
  Future<void> markHelpDone(String requestId) async {
    await _requestsCol.doc(requestId).update({
      'status': 'PENDING_CONFIRMATION',
      'helperConfirmed': true,
    });
  }

  /// Confirm completion (called by requester or helper).
  /// If both confirmed → COMPLETED + award points.
  Future<void> confirmCompletion(String requestId) async {
    if (_uid.isEmpty) return;
    final doc = _requestsCol.doc(requestId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;

    final requesterId = data['requesterId'] as String? ?? '';
    final helperId = data['claimedBy'] as String? ?? '';
    final isRequester = _uid == requesterId;
    final isHelper = _uid == helperId;

    // Determine which field to set
    Map<String, dynamic> updateData = {};
    if (isRequester) {
      updateData['requesterConfirmed'] = true;
    } else if (isHelper) {
      updateData['helperConfirmed'] = true;
    }

    if (updateData.isEmpty) return;
    await doc.update(updateData);

    // Re-read to check if both confirmed
    final updatedSnap = await doc.get();
    final updatedData = updatedSnap.data() as Map<String, dynamic>;
    final bothConfirmed = (updatedData['requesterConfirmed'] == true) &&
        (updatedData['helperConfirmed'] == true);

    if (bothConfirmed) {
      await doc.update({
        'status': 'COMPLETED',
        'completedAt': Timestamp.now(),
      });
      // Award 25 merit points to both
      if (requesterId.isNotEmpty) await addMeritPoints(requesterId, 25);
      if (helperId.isNotEmpty) await addMeritPoints(helperId, 25);
    }
  }

  /// Edit an existing open request.
  Future<void> editRequest({
    required String requestId,
    required String title,
    required String description,
    required String category,
    required String urgency,
  }) async {
    if (_uid.isEmpty) return;
    await _requestsCol.doc(requestId).update({
      'title': title,
      'description': description,
      'category': category,
      'urgency': urgency,
    });
  }

  /// Delete an existing open request.
  Future<void> deleteRequest(String requestId) async {
    if (_uid.isEmpty) return;
    await _requestsCol.doc(requestId).delete();
  }

  // ═══════════════════════════════════════════
  // MY CLAIMS (for helper)
  // ═══════════════════════════════════════════

  /// Stream requests claimed by current user (CLAIMED or PENDING_CONFIRMATION).
  Stream<List<RequestModel>> streamMyClaims() {
    if (_uid.isEmpty) return Stream.value([]);
    return _requestsCol
        .where('claimedBy', isEqualTo: _uid)
        .where('status', whereIn: ['CLAIMED', 'PENDING_CONFIRMATION'])
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => RequestModel.fromFirestore(d)).toList();
          list.sort((a, b) => (b.claimedAt ?? b.createdAt).compareTo(a.claimedAt ?? a.createdAt));
          return list;
        });
  }

  // ═══════════════════════════════════════════
  // MY REQUESTS (for requester)
  // ═══════════════════════════════════════════

  /// Stream requests created by current user that are NOT completed yet.
  Stream<List<RequestModel>> streamMyActiveRequests() {
    if (_uid.isEmpty) return Stream.value([]);
    return _requestsCol
        .where('requesterId', isEqualTo: _uid)
        .where('status', whereIn: ['OPEN', 'CLAIMED', 'PENDING_CONFIRMATION'])
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => RequestModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Stream requests created by current user that are pending confirmation.
  Stream<List<RequestModel>> streamMyPendingRequests() {
    if (_uid.isEmpty) return Stream.value([]);
    return _requestsCol
        .where('requesterId', isEqualTo: _uid)
        .where('status', isEqualTo: 'PENDING_CONFIRMATION')
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromFirestore(d)).toList());
  }

  // ═══════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════

  /// Stream history: requests where user was requester or helper and status is COMPLETED.
  Stream<List<RequestModel>> streamMyHistory() {
    if (_uid.isEmpty) return Stream.value([]);
    final asRequester = _requestsCol
        .where('requesterId', isEqualTo: _uid)
        .where('status', isEqualTo: 'COMPLETED')
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromFirestore(d)).toList());

    final asHelper = _requestsCol
        .where('claimedBy', isEqualTo: _uid)
        .where('status', isEqualTo: 'COMPLETED')
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromFirestore(d)).toList());

    // Merge and deduplicate
    return asRequester.asyncExpand((requesterList) {
      return asHelper.map((helperList) {
        final map = <String, RequestModel>{};
        for (final r in requesterList) {
          map[r.id] = r;
        }
        for (final r in helperList) {
          map[r.id] = r;
        }
        final list = map.values.toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
    });
  }

  // ═══════════════════════════════════════════
  // USERS & MERIT
  // ═══════════════════════════════════════════

  CollectionReference get _usersCol => _firestore.collection('users');

  /// Ensure user doc exists. Called on login/signup.
  Future<void> ensureUserProfile() async {
    if (_uid.isEmpty) return;
    try {
      final doc = _usersCol.doc(_uid);
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set({
          'uid': _uid,
          'name': _userName,
          'phone': _auth.currentUser?.phoneNumber ?? '',
          'tagline': 'Helping neighbours, one step at a time',
          'meritPoints': 0,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (_) {
      // Silently fail — profile will be created on next opportunity
    }
  }

  /// Get user profile data.
  Future<Map<String, dynamic>?> getUserProfile([String? uid]) async {
    final docId = uid ?? _uid;
    if (docId.isEmpty) return null;
    try {
      final snap = await _usersCol.doc(docId).get();
      if (!snap.exists) return null;
      return snap.data() as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Stream user profile data for real-time updates (e.g. sidebar).
  Stream<Map<String, dynamic>?> streamUserProfile([String? uid]) {
    final docId = uid ?? _uid;
    if (docId.isEmpty) return Stream.value(null);
    return _usersCol.doc(docId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data() as Map<String, dynamic>?;
    });
  }

  /// Update user profile fields.
  Future<void> updateUserProfile({String? name, String? tagline}) async {
    if (_uid.isEmpty) return;
    final updates = <String, dynamic>{};
    if (name != null) {
      updates['name'] = name;
      // Also update Firebase Auth display name so getters stay in sync
      try {
        await _auth.currentUser?.updateDisplayName(name);
      } catch (_) {}
    }
    if (tagline != null) updates['tagline'] = tagline;
    if (updates.isNotEmpty) {
      try {
        // Use set with merge to create doc if it doesn't exist
        await _usersCol.doc(_uid).set(updates, SetOptions(merge: true));
      } catch (_) {
        // Ignore — profile save failed
      }
    }
  }

  /// Add merit points to a user.
  Future<void> addMeritPoints(String uid, int points) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).set(
        {'meritPoints': FieldValue.increment(points)},
        SetOptions(merge: true),
      );
    } catch (_) {
      // Ignore
    }
  }

  /// Get current user's merit points.
  Future<int> getMyMeritPoints() async {
    final data = await getUserProfile();
    return (data?['meritPoints'] as int?) ?? 0;
  }

  /// Stream leaderboard — top users by merit.
  Stream<List<Map<String, dynamic>>> streamLeaderboard({int limit = 20}) {
    return _usersCol
        .orderBy('meritPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return {
                'uid': d.id,
                'name': data['name'] ?? 'Unknown',
                'meritPoints': data['meritPoints'] ?? 0,
              };
            }).toList());
  }

  // ═══════════════════════════════════════════
  // REPORTS
  // ═══════════════════════════════════════════

  CollectionReference get _reportsCol => _firestore.collection('reports');

  /// Report a user — also deducts merit points and increments reportCount.
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? requestId,
  }) async {
    if (_uid.isEmpty) return;
    await _reportsCol.add({
      'reportedBy': _uid,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'requestId': requestId,
      'createdAt': Timestamp.now(),
      'status': 'PENDING_REVIEW',
    });

    // Deduct merit points and increment report count on reported user
    if (reportedUserId.isNotEmpty) {
      await _usersCol.doc(reportedUserId).set({
        'meritPoints': FieldValue.increment(-25),
        'reportCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
  }

  /// Get a user's report count.
  Future<int> getReportCount(String uid) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await _usersCol.doc(uid).get();
      if (!snap.exists) return 0;
      final data = snap.data() as Map<String, dynamic>?;
      return (data?['reportCount'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
