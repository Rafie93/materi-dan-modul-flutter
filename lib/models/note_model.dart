/// Note Model - Representasi data catatan dalam aplikasi
/// 
/// Model ini digunakan untuk:
/// 1. Struktur data yang konsisten
/// 2. Konversi data dari/ke database (toMap/fromMap)
/// 3. Konversi data dari/ke JSON (toJson/fromJson)
class Note {
  int? id; // Primary key (nullable karena auto-increment)
  String title; // Judul catatan (required)
  String content; // Isi catatan
  DateTime createdAt; // Tanggal dibuat
  DateTime updatedAt; // Tanggal terakhir diupdate

  /// Constructor
  Note({
    this.id,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Konversi dari Map ke Note object
  /// 
  /// Digunakan saat membaca data dari database
  /// Database mengembalikan data dalam bentuk Map<String, dynamic>
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Konversi dari Note object ke Map
  /// 
  /// Digunakan saat menyimpan data ke database
  /// Database menerima data dalam bentuk Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // id hanya disertakan jika sudah ada
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Konversi dari JSON ke Note object
  /// 
  /// Berguna untuk API atau penyimpanan data lainnya
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Konversi dari Note object ke JSON
  /// 
  /// Berguna untuk API atau penyimpanan data lainnya
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Membuat copy Note dengan beberapa field yang diubah
  /// 
  /// Berguna untuk update data tanpa mengubah object original
  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Override toString untuk debugging
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}..., createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
