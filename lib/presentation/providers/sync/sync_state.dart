class SyncState {
  const SyncState({
    required this.isSyncing,
    required this.total,
    required this.completed,
    required this.failed,
  });

  final bool isSyncing;
  final int total;
  final int completed;
  final int failed;

  SyncState copyWith({
    bool? isSyncing,
    int? total,
    int? completed,
    int? failed,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      total: total ?? this.total,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
    );
  }

  static const idle = SyncState(isSyncing: false, total: 0, completed: 0, failed: 0);
}

