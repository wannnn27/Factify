import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  // Keys for SharedPreferences
  static const String _keyArticlesRead = 'user_articles_read';
  static const String _keyChallengesCompleted = 'user_challenges_completed';
  static const String _keyQuizAnswered = 'user_quiz_answered';
  static const String _keyVerificationsCount = 'user_verifications_count';
  static const String _keyHighestChallengeScore = 'user_highest_challenge_score';
  static const String _keyTotalXP = 'user_total_xp';
  static const String _keyStreak = 'user_streak';
  static const String _keyLastActiveDate = 'user_last_active_date';
  static const String _keyReadArticleIds = 'user_read_article_ids';
  
  SharedPreferences? _prefs;
  
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
  
  // ============ GETTERS ============
  
  Future<int> get articlesRead async {
    final p = await prefs;
    return p.getInt(_keyArticlesRead) ?? 0;
  }
  
  Future<int> get challengesCompleted async {
    final p = await prefs;
    return p.getInt(_keyChallengesCompleted) ?? 0;
  }
  
  Future<int> get quizAnswered async {
    final p = await prefs;
    return p.getInt(_keyQuizAnswered) ?? 0;
  }
  
  Future<int> get verificationsCount async {
    final p = await prefs;
    return p.getInt(_keyVerificationsCount) ?? 0;
  }
  
  Future<int> get highestChallengeScore async {
    final p = await prefs;
    return p.getInt(_keyHighestChallengeScore) ?? 0;
  }
  
  Future<int> get totalXP async {
    final p = await prefs;
    return p.getInt(_keyTotalXP) ?? 0;
  }
  
  Future<int> get streak async {
    final p = await prefs;
    return p.getInt(_keyStreak) ?? 0;
  }
  
  Future<List<String>> get readArticleIds async {
    final p = await prefs;
    return p.getStringList(_keyReadArticleIds) ?? [];
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
    final readIds = p.getStringList(_keyReadArticleIds) ?? [];
    
    // Check if already read
    if (readIds.contains(articleId)) {
      return false; // Already read, don't increment
    }
    
    // Add to read list
    readIds.add(articleId);
    await p.setStringList(_keyReadArticleIds, readIds);
    
    // Increment articles read count
    final current = p.getInt(_keyArticlesRead) ?? 0;
    await p.setInt(_keyArticlesRead, current + 1);
    
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
    final current = p.getInt(_keyChallengesCompleted) ?? 0;
    await p.setInt(_keyChallengesCompleted, current + 1);
    
    // Update highest score if applicable
    final highScore = p.getInt(_keyHighestChallengeScore) ?? 0;
    if (score > highScore) {
      await p.setInt(_keyHighestChallengeScore, score);
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
    final current = p.getInt(_keyQuizAnswered) ?? 0;
    await p.setInt(_keyQuizAnswered, current + 1);
    
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
    
    final current = p.getInt(_keyVerificationsCount) ?? 0;
    await p.setInt(_keyVerificationsCount, current + 1);
    
    // Add XP for verification
    await addXP(15);
    
    // Sync to Firebase
    await _syncToFirebase();
  }
  
  // Add XP
  Future<void> addXP(int amount) async {
    final p = await prefs;
    final current = p.getInt(_keyTotalXP) ?? 0;
    await p.setInt(_keyTotalXP, current + amount);
  }
  
  // Check and update streak
  Future<void> _checkAndUpdateStreak() async {
    final p = await prefs;
    final lastActiveStr = p.getString(_keyLastActiveDate);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    if (lastActiveStr == null) {
      // First time user
      await p.setInt(_keyStreak, 1);
      await p.setString(_keyLastActiveDate, todayStr);
      return;
    }
    
    if (lastActiveStr == todayStr) {
      // Already active today, no change
      return;
    }
    
    // Parse last active date
    final parts = lastActiveStr.split('-');
    final lastActive = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    
    final difference = today.difference(lastActive).inDays;
    
    if (difference == 1) {
      // Consecutive day, increment streak
      final currentStreak = p.getInt(_keyStreak) ?? 0;
      await p.setInt(_keyStreak, currentStreak + 1);
    } else if (difference > 1) {
      // Streak broken, reset to 1
      await p.setInt(_keyStreak, 1);
    }
    
    await p.setString(_keyLastActiveDate, todayStr);
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
      
      // Merge: take the higher value
      final localArticles = p.getInt(_keyArticlesRead) ?? 0;
      final cloudArticles = cloudStats['articlesRead'] ?? 0;
      if (cloudArticles > localArticles) {
        await p.setInt(_keyArticlesRead, cloudArticles);
      }
      
      final localChallenges = p.getInt(_keyChallengesCompleted) ?? 0;
      final cloudChallenges = cloudStats['challengesCompleted'] ?? 0;
      if (cloudChallenges > localChallenges) {
        await p.setInt(_keyChallengesCompleted, cloudChallenges);
      }
      
      final localXP = p.getInt(_keyTotalXP) ?? 0;
      final cloudXP = cloudStats['totalXP'] ?? 0;
      if (cloudXP > localXP) {
        await p.setInt(_keyTotalXP, cloudXP);
      }
      
      final localHighScore = p.getInt(_keyHighestChallengeScore) ?? 0;
      final cloudHighScore = cloudStats['highestChallengeScore'] ?? 0;
      if (cloudHighScore > localHighScore) {
        await p.setInt(_keyHighestChallengeScore, cloudHighScore);
      }
      
    } catch (e) {
      print('Failed to sync stats from Firebase: $e');
    }
  }
  
  // Reset all stats (for testing or account reset)
  Future<void> resetAllStats() async {
    final p = await prefs;
    await p.remove(_keyArticlesRead);
    await p.remove(_keyChallengesCompleted);
    await p.remove(_keyQuizAnswered);
    await p.remove(_keyVerificationsCount);
    await p.remove(_keyHighestChallengeScore);
    await p.remove(_keyTotalXP);
    await p.remove(_keyStreak);
    await p.remove(_keyLastActiveDate);
    await p.remove(_keyReadArticleIds);
  }
}

// Global instance for easy access
final userStats = UserStatsService();
