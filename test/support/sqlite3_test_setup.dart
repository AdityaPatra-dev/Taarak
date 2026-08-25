/// sqlite3 3.x resolves its native library via Dart's native-assets build
/// hooks instead of the old manual `DynamicLibrary` override this used to
/// do — there's nothing left for a test to configure here. Kept as a
/// no-op so the ~20 test files that already call it don't need editing.
void configureSqlite3ForLocalTests() {}
