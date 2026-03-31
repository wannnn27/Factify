import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import 'comment_widget.dart';

class DiscussionSection extends StatefulWidget {
  final String contentId;
  final String contentTitle;

  const DiscussionSection({
    super.key,
    required this.contentId,
    required this.contentTitle,
  });

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _replyingToId;
  String _replyingToName = '';
  String _currentUserName = 'Pengguna';
  String _currentUserAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadComments();
  }

  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _currentUserName = 'Tamu';
      _currentUserAvatar = '';
      return;
    }

    _currentUserName =
        user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : (user.email?.split('@').first ?? 'Pengguna');
    _currentUserAvatar = user.photoURL ?? '';
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    final comments = await _commentService.getComments(widget.contentId);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: _currentUserName,
      userAvatar: _currentUserAvatar,
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    if (_replyingToId != null) {
      await _commentService.addReply(
        widget.contentId,
        _replyingToId!,
        newComment,
      );
      setState(() => _replyingToId = null);
    } else {
      await _commentService.addComment(widget.contentId, newComment);
    }

    _commentController.clear();
    await _loadComments();
  }

  Future<void> _toggleLike(String commentId) async {
    await _commentService.toggleLike(widget.contentId, commentId);
    await _loadComments();
  }

  void _startReply(String commentId) {
    final comment = _comments.firstWhere((c) => c.id == commentId);
    setState(() {
      _replyingToId = commentId;
      _replyingToName = comment.userName;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF2D2D44)),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.forum_outlined,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diskusi & Komentar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_comments.length} komentar',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4ECDC4),
                    ),
                  )
                : _comments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return CommentWidget(
                            comment: _comments[index],
                            onLike: _toggleLike,
                            onReply: _startReply,
                          );
                        },
                      ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Reply Indicator
                  if (_replyingToId != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.reply,
                            size: 16,
                            color: Color(0xFF4ECDC4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Membalas $_replyingToName',
                              style: const TextStyle(
                                color: Color(0xFF4ECDC4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF4ECDC4),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() => _replyingToId = null);
                            },
                          ),
                        ],
                      ),
                    ),

                  // Input Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _addComment(),
                          decoration: InputDecoration(
                            hintText: _replyingToId != null
                                ? 'Tulis balasan...'
                                : 'Tulis komentar...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: const Color(0xFF1A1A2E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _addComment,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada komentar',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadilah yang pertama berkomentar!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}