import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  // Base key names (will be prefixed with user UID)
  static const String _baseKeyArticlesRead = 'articles_read';
  static const String _baseKeyChallengesCompleted = 'challenges_completed';
  static const String _baseKeyQuizAnswered = 'quiz_answered';
  static const String _baseKeyVerificationsCount = 'verifications_count';
  static const String _baseKeyHighestChallengeScore = 'highest_challenge_score';
  static const String _baseKeyTotalXP = 'total_xp';
  static const String _baseKeyStreak = 'streak';
  static const String _baseKeyLastActiveDate = 'last_active_date';
  static const String _baseKeyReadArticleIds = 'read_article_ids';
  
  SharedPreferences? _prefs;
  String? _currentUid;
  
  // ============ USER-SCOPED KEY GENERATION ============
  
  /// Get current user UID, or 'guest' for unauthenticated users
  String get _uid {
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return _currentUid!;
  }
  
  /// Generate user-scoped key to isolate data per user
  String _key(String baseKey) => '${_uid}_$baseKey';
  
  // Initialize preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAndUpdateStreak();
  }
  
  // Ensure prefs is initialized
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  /// Call this when user signs out to clear the cached UID
  /// so next user doesn't see stale data
  void onUserChanged() {
    _currentUid = null;
  }
  
  // ============ GETTERS ============
  
  Future<int> get articlesRead async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyArticlesRead)) ?? 0;
  }
  
  Future<int> get challengesCompleted async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyChallengesCompleted)) ?? 0;
  }
  
  Future<int> get quizAnswered async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyQuizAnswered)) ?? 0;
  }
  
  Future<int> get verificationsCount async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyVerificationsCount)) ?? 0;
  }
  
  Future<int> get highestChallengeScore async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyHighestChallengeScore)) ?? 0;
  }
  
  Future<int> get totalXP async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyTotalXP)) ?? 0;
  }
  
  Future<int> get streak async {
    final p = await prefs;
    return p.getInt(_key(_baseKeyStreak)) ?? 0;
  }
  
  Future<List<String>> get readArticleIds async {
    final p = await prefs;
    return p.getStringList(_key(_baseKeyReadArticleIds)) ?? [];
  }
  
  // Get all stats at once
  Future<Map<String, int>> getAllStats() async {
    return {
      'articlesRead': await articlesRead,
      'challengesCompleted': await challengesCompleted,
      'quizAnswered': await quizAnswered,
      'verificationsCount': await verificationsCount,
      'highestChallengeScore': await highestChallengeScore,
      'totalXP': await totalXP,
      'streak': await streak,
    };
  }
  
  // ============ SETTERS/INCREMENTERS ============
  
  // Mark article as read and increment counter
  Future<bool> markArticleAsRead(String articleId) async {
    final p = await prefs;
    final key = _key(_baseKeyReadArticleIds);
    final readIds = p.getStringList(key) ?? [];
    
    // Check if already read
    if (readIds.contains(articleId)) {
      return false; // Already read, don't increment
    }
    
    // Add to read list
    readIds.add(articleId);
    await p.setStringList(key, readIds);
    
    // Increment articles read count
    final countKey = _key(_baseKeyArticlesRead);
    final current = p.getInt(countKey) ?? 0;
    await p.setInt(countKey, current + 1);
    
    // Add XP for reading
    await addXP(5);
    
    // Sync to Firebase
    await _syncToFirebase();
    
    return true;
  }
  
  // Check if article has been read
  Future<bool> hasReadArticle(String articleId) async {
    final readIds = await readArticleIds;
    return readIds.contains(articleId);
  }
  
  // Increment challenge completed
  Future<void> completedChallenge(int score) async {
    final p = await prefs;
    
    // Increment challenges completed
    final countKey = _key(_baseKeyChallengesCompleted);
    final current = p.getInt(countKey) ?? 0;
    await p.setInt(countKey, current + 1);
    
    // Update highest score if applicable
    final highKey = _key(_baseKeyHighestChallengeScore);
    final highScore = p.getInt(highKey) ?? 0;
    if (score > highScore) {
      await p.setInt(highKey, score);
    }
    
    // Add XP based on score
    await addXP(score);
    
    // Sync to Firebase
    await _syncToFirebase();
  }
  
  // Increment quiz answered
  Future<void> answeredQuiz(bool isCorrect) async {
    final p = await prefs;
    
    // Increment quiz count
    final countKey = _key(_baseKeyQuizAnswered);
    final current = p.getInt(countKey) ?? 0;
    await p.setInt(countKey, current + 1);
    
    // Add XP if correct
    if (isCorrect) {
      await addXP(10);
    }
    
    // Sync to Firebase
    await _syncToFirebase();
  }
  
  // Increment verifications count
  Future<void> completedVerification() async {
    final p = await prefs;
    
    final countKey = _key(_baseKeyVerificationsCount);
    final current = p.getInt(countKey) ?? 0;
    await p.setInt(countKey, current + 1);
    
    // Add XP for verification
    await addXP(15);
    
    // Sync to Firebase
    await _syncToFirebase();
  }
  
  // Add XP
  Future<void> addXP(int amount) async {
    final p = await prefs;
    final xpKey = _key(_baseKeyTotalXP);
    final current = p.getInt(xpKey) ?? 0;
    await p.setInt(xpKey, current + amount);
  }
  
  // Check and update streak
  Future<void> _checkAndUpdateStreak() async {
    final p = await prefs;
    final streakKey = _key(_baseKeyStreak);
    final dateKey = _key(_baseKeyLastActiveDate);
    final lastActiveStr = p.getString(dateKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (lastActiveStr == null) {
      // First time user
      await p.setInt(streakKey, 1);
      await p.setString(dateKey, todayStr);
      return;
    }
    
    if (lastActiveStr == todayStr) {
      // Already active today, no change
      return;
    }
    
    // Parse last active date
    final parts = lastActiveStr.split('-');
    if (parts.length != 3) {
      // Invalid date format, reset
      await p.setInt(streakKey, 1);
      await p.setString(dateKey, todayStr);
      return;
    }
    
    final lastActive = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    
    final difference = today.difference(lastActive).inDays;
    
    if (difference == 1) {
      // Consecutive day, increment streak
      final currentStreak = p.getInt(streakKey) ?? 0;
      await p.setInt(streakKey, currentStreak + 1);
    } else if (difference > 1) {
      // Streak broken, reset to 1
      await p.setInt(streakKey, 1);
    }
    
    await p.setString(dateKey, todayStr);
  }
  
  // ============ FIREBASE SYNC ============
  
  Future<void> _syncToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final stats = await getAllStats();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'stats': stats,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - local storage is primary
      print('Failed to sync stats to Firebase: $e');
    }
  }
  
  // Fetch from Firebase and merge with local
  Future<void> syncFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) return;
      
      final data = doc.data();
      if (data == null || data['stats'] == null) return;
      
      final cloudStats = data['stats'] as Map<String, dynamic>;
      final p = await prefs;
      
      // Merge: take the higher value (user-scoped keys)
      void mergeInt(String baseKey, String cloudKey) {
        final localVal = p.getInt(_key(baseKey)) ?? 0;
        final cloudVal = cloudStats[cloudKey] ?? 0;
        if (cloudVal > localVal) {
          p.setInt(_key(baseKey), cloudVal);
        }
      }
      
      mergeInt(_baseKeyArticlesRead, 'articlesRead');
      mergeInt(_baseKeyChallengesCompleted, 'challengesCompleted');
      mergeInt(_baseKeyTotalXP, 'totalXP');
      mergeInt(_baseKeyHighestChallengeScore, 'highestChallengeScore');
      mergeInt(_baseKeyQuizAnswered, 'quizAnswered');
      mergeInt(_baseKeyVerificationsCount, 'verificationsCount');
      
    } catch (e) {
      print('Failed to sync stats from Firebase: $e');
    }
  }
  
  // Reset all stats for current user
  Future<void> resetAllStats() async {
    final p = await prefs;
    await p.remove(_key(_baseKeyArticlesRead));
    await p.remove(_key(_baseKeyChallengesCompleted));
    await p.remove(_key(_baseKeyQuizAnswered));
    await p.remove(_key(_baseKeyVerificationsCount));
    await p.remove(_key(_baseKeyHighestChallengeScore));
    await p.remove(_key(_baseKeyTotalXP));
    await p.remove(_key(_baseKeyStreak));
    await p.remove(_key(_baseKeyLastActiveDate));
    await p.remove(_key(_baseKeyReadArticleIds));
  }
}

// Global instance for easy access
final userStats = UserStatsService();
