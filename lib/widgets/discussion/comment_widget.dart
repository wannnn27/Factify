import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/comment_model.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(String) onLike;
  final Function(String) onReply;
  final bool isReply;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 40 : 0,
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12),
        border: isReply
            ? Border.all(
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4ECDC4),
                child: Text(
                  comment.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      timeago.format(comment.timestamp, locale: 'id'),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            comment.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Actions
          Row(
            children: [
              // Like Button
              InkWell(
                onTap: () => onLike(comment.id),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: comment.isLiked
                            ? Colors.red
                            : const Color(0xFF4ECDC4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.likes > 0 ? '${comment.likes}' : 'Suka',
                        style: TextStyle(
                          color: comment.isLiked
                              ? Colors.red
                              : const Color(0xFF4ECDC4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Reply Button (only for main comments)
              if (!isReply) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onReply(comment.id),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Color(0xFF4ECDC4),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Balas',
                          style: TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...comment.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CommentWidget(
                  comment: reply,
                  onLike: onLike,
                  onReply: onReply,
                  isReply: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}