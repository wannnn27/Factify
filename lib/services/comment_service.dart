import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment_model.dart';

/// CommentService — stores comments in Firebase Firestore so all users
/// can see and interact with them (community discussion).
/// Falls back to local SharedPreferences for guest/offline mode.
class CommentService {
  static const String _localKeyPrefix = 'comments_';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns Firestore collection ref for a content's comments
  CollectionReference<Map<String, dynamic>> _commentsRef(String contentId) {
    return _firestore.collection('comments').doc(contentId).collection('messages');
  }

  bool get _isAuthenticated => FirebaseAuth.instance.currentUser != null;

  // ============ GET COMMENTS ============

  Future<List<Comment>> getComments(String contentId) async {
    if (_isAuthenticated) {
      return _getCommentsFromFirestore(contentId);
    }
    return _getCommentsFromLocal(contentId);
  }

  Future<List<Comment>> _getCommentsFromFirestore(String contentId) async {
    try {
      final snapshot = await _commentsRef(contentId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Compute isLiked per-user from liked_by array
        final likedBy = List<String>.from(data['liked_by'] ?? []);
        data['isLiked'] = likedBy.contains(currentUid);
        data['likes'] = likedBy.isNotEmpty ? likedBy.length : (data['likes'] ?? 0);
        return Comment.fromJson(data);
      }).toList();
    } catch (e) {
      print('[CommentService] Firestore read error: $e');
      // Fallback to local
      return _getCommentsFromLocal(contentId);
    }
  }

  Future<List<Comment>> _getCommentsFromLocal(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localKeyPrefix$contentId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Comment.fromJson(json)).toList();
  }

  // ============ ADD COMMENT ============

  Future<void> addComment(String contentId, Comment comment) async {
    if (_isAuthenticated) {
      await _addCommentToFirestore(contentId, comment);
    } else {
      await _addCommentToLocal(contentId, comment);
    }
  }

  Future<void> _addCommentToFirestore(String contentId, Comment comment) async {
    try {
      await _commentsRef(contentId).doc(comment.id).set(comment.toJson());
    } catch (e) {
      print('[CommentService] Firestore write error: $e');
      // Fallback to local
      await _addCommentToLocal(contentId, comment);
    }
  }

  Future<void> _addCommentToLocal(String contentId, Comment comment) async {
    final comments = await _getCommentsFromLocal(contentId);
    comments.insert(0, comment);
    await _saveCommentsToLocal(contentId, comments);
  }

  // ============ ADD REPLY ============

  Future<void> addReply(String contentId, String parentCommentId, Comment reply) async {
    if (_isAuthenticated) {
      await _addReplyToFirestore(contentId, parentCommentId, reply);
    } else {
      await _addReplyToLocal(contentId, parentCommentId, reply);
    }
  }

  Future<void> _addReplyToFirestore(String contentId, String parentCommentId, Comment reply) async {
    try {
      // Store reply as a sub-document under the parent comment
      final parentRef = _commentsRef(contentId).doc(parentCommentId);
      final parentDoc = await parentRef.get();

      if (parentDoc.exists) {
        final data = parentDoc.data()!;
        final replies = List<Map<String, dynamic>>.from(data['replies'] ?? []);
        replies.add(reply.toJson());
        await parentRef.update({'replies': replies});
      }
    } catch (e) {
      print('[CommentService] Firestore reply error: $e');
      await _addReplyToLocal(contentId, parentCommentId, reply);
    }
  }

  Future<void> _addReplyToLocal(String contentId, String parentCommentId, Comment reply) async {
    final comments = await _getCommentsFromLocal(contentId);
    final parentIndex = comments.indexWhere((c) => c.id == parentCommentId);

    if (parentIndex != -1) {
      final updatedReplies = List<Comment>.from(comments[parentIndex].replies)..add(reply);
      comments[parentIndex] = Comment(
        id: comments[parentIndex].id,
        userName: comments[parentIndex].userName,
        userAvatar: comments[parentIndex].userAvatar,
        content: comments[parentIndex].content,
        timestamp: comments[parentIndex].timestamp,
        likes: comments[parentIndex].likes,
        isLiked: comments[parentIndex].isLiked,
        replies: updatedReplies,
      );
      await _saveCommentsToLocal(contentId, comments);
    }
  }

  // ============ TOGGLE LIKE ============

  Future<void> toggleLike(String contentId, String commentId) async {
    if (_isAuthenticated) {
      await _toggleLikeFirestore(contentId, commentId);
    } else {
      await _toggleLikeLocal(contentId, commentId);
    }
  }

  Future<void> _toggleLikeFirestore(String contentId, String commentId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final ref = _commentsRef(contentId).doc(commentId);
      final doc = await ref.get();
      if (doc.exists) {
        final data = doc.data()!;
        final likedBy = List<String>.from(data['liked_by'] ?? []);
        final uid = currentUser.uid;

        if (likedBy.contains(uid)) {
          likedBy.remove(uid);
        } else {
          likedBy.add(uid);
        }

        await ref.update({
          'liked_by': likedBy,
          'likes': likedBy.length,
        });
      }
    } catch (e) {
      print('[CommentService] Firestore like error: $e');
      await _toggleLikeLocal(contentId, commentId);
    }
  }

  Future<void> _toggleLikeLocal(String contentId, String commentId) async {
    final comments = await _getCommentsFromLocal(contentId);
    final index = comments.indexWhere((c) => c.id == commentId);

    if (index != -1) {
      final comment = comments[index];
      comments[index] = Comment(
        id: comment.id,
        userName: comment.userName,
        userAvatar: comment.userAvatar,
        content: comment.content,
        timestamp: comment.timestamp,
        likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
        isLiked: !comment.isLiked,
        replies: comment.replies,
      );
      await _saveCommentsToLocal(contentId, comments);
    }
  }

  // ============ STREAM (real-time updates for authenticated users) ============

  /// Get a real-time stream of comments for live updates
  Stream<List<Comment>> getCommentsStream(String contentId) {
    if (!_isAuthenticated) {
      // For guest mode, return a single-shot stream from local
      return Stream.fromFuture(_getCommentsFromLocal(contentId));
    }

    return _commentsRef(contentId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            
            final likedBy = List<String>.from(data['liked_by'] ?? []);
            data['isLiked'] = likedBy.contains(currentUid);
            data['likes'] = likedBy.isNotEmpty ? likedBy.length : (data['likes'] ?? 0);
            
            return Comment.fromJson(data);
          }).toList();
        });
  }

  // ============ LOCAL HELPERS ============

  Future<void> _saveCommentsToLocal(String contentId, List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localKeyPrefix$contentId';
    final jsonString = json.encode(comments.map((c) => c.toJson()).toList());
    await prefs.setString(key, jsonString);
  }
}