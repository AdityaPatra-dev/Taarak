/// Which side of a version conflict [SyncEngine.resolveConflict] picked.
/// [localWins] means the queued local change is strictly newer than what
/// the server reported and should be retried (pushed again to overwrite);
/// [serverWins] means the server is already at an equal or newer version,
/// so the local push is redundant and can be dropped without error.
enum SyncConflictResolution { localWins, serverWins }
