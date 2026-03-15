/// Enum untuk kategori pengguna
/// Digunakan untuk menyesuaikan tingkat kesulitan challenge
enum UserCategory {
  pelajar,    // Pelajar SMP/SMA - level pemula
  mahasiswa,  // Mahasiswa - level menengah
  pekerja,    // Pekerja/Profesional - level lanjutan
}

/// Extension untuk UserCategory
extension UserCategoryExtension on UserCategory {
  /// Mendapatkan nama tampilan dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case UserCategory.pelajar:
        return 'Pelajar';
      case UserCategory.mahasiswa:
        return 'Mahasiswa';
      case UserCategory.pekerja:
        return 'Pekerja';
    }
  }

  /// Mendapatkan deskripsi kategori
  String get description {
    switch (this) {
      case UserCategory.pelajar:
        return 'Siswa SMP/SMA yang sedang belajar literasi digital';
      case UserCategory.mahasiswa:
        return 'Mahasiswa yang ingin meningkatkan kemampuan berpikir kritis';
      case UserCategory.pekerja:
        return 'Profesional yang membutuhkan skill verifikasi informasi';
    }
  }

  /// Mendapatkan icon untuk kategori
  String get iconName {
    switch (this) {
      case UserCategory.pelajar:
        return 'school';
      case UserCategory.mahasiswa:
        return 'account_balance';
      case UserCategory.pekerja:
        return 'work';
    }
  }

  /// Mendapatkan level kesulitan (1-3)
  int get difficultyLevel {
    switch (this) {
      case UserCategory.pelajar:
        return 1; // Pemula
      case UserCategory.mahasiswa:
        return 2; // Menengah
      case UserCategory.pekerja:
        return 3; // Lanjutan
    }
  }

  /// Konversi ke string untuk penyimpanan di Firestore
  String toFirestoreValue() {
    return name;
  }

  /// Konversi dari string Firestore ke enum
  static UserCategory fromFirestoreValue(String? value) {
    switch (value) {
      case 'pelajar':
        return UserCategory.pelajar;
      case 'mahasiswa':
        return UserCategory.mahasiswa;
      case 'pekerja':
        return UserCategory.pekerja;
      default:
        return UserCategory.pelajar; // Default jika null atau tidak valid
    }
  }
}
