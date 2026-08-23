import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// On some Linux dev machines only the versioned `libsqlite3.so.0` is
/// installed (the unversioned `libsqlite3.so` symlink ships with a
/// `-devel` package that usually isn't). Point sqlite3's FFI loader at the
/// versioned file that's actually present. Real devices always get their
/// native library from `sqlite3_flutter_libs`, so this only matters for
/// `flutter test` running on the host.
void configureSqlite3ForLocalTests() {
  if (!Platform.isLinux) return;
  open.overrideFor(
    OperatingSystem.linux,
    () => DynamicLibrary.open('libsqlite3.so.0'),
  );
}
