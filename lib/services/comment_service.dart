// lib/services/comment_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment_model.dart';

class CommentService {
  static const String _keyPrefix = 'comments_';

  Future<List<Comment>> getComments(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$contentId';
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Comment.fromJson(json)).toList();
  }

  Future<void> saveComments(String contentId, List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$contentId';
    final jsonString = json.encode(comments.map((c) => c.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  Future<void> addComment(String contentId, Comment comment) async {
    final comments = await getComments(contentId);
    comments.insert(0, comment);
    await saveComments(contentId, comments);
  }

  Future<void> addReply(String contentId, String parentCommentId, Comment reply) async {
    final comments = await getComments(contentId);
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
      await saveComments(contentId, comments);
    }
  }

  Future<void> toggleLike(String contentId, String commentId) async {
    final comments = await getComments(contentId);
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
      await saveComments(contentId, comments);
    }
  }
}