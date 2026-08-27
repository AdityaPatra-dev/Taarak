# TAARAK backend stub

**Not required to build or run the app.** The Flutter app now talks to a real, hosted Firebase project unconditionally (see the root README's "Firebase" section) — nothing in `lib/` points at this stub anymore. It's kept here for historical reference only; skip this whole directory unless you're specifically curious about the client/server contract `SyncCoordinatorService` was originally built against.

This is **not a production backend**. It exists to answer one question honestly: does the Flutter app's auth + sync client contract actually work against a real server, or only against mocks?

Until now, nothing on the other end of `ApiClient`/`ApiSyncTransport` had ever run. This stub implements just enough of that contract — login/register, and the generic `/sync/<table>` push endpoint `SyncCoordinatorService` already speaks — to validate it for real.

## What it is not

- Not deployed anywhere. Runs on your machine, over plain HTTP, on `localhost:8080`.
- Not persistent. All accounts and synced data live in memory and reset every time you restart it (seeded demo accounts come back automatically).
- Not authorized beyond login. It doesn't check the `Authorization` header on `/sync` requests.
- Not secure. Passwords are compared in plaintext, no HTTPS, no rate limiting. Never point a real device at this over an untrusted network.

If/when TAARAK gets a real deployed backend, that service should implement the same contract (documented below) — this stub is the spec by example, not something to harden into production.

## Running it

```
cd backend
dart pub get
dart run bin/server.dart
```

You'll see the seeded demo accounts printed — same emails/passwords as the app's `DevMockAuthRemoteDataSource`, so switching the app off mock auth doesn't change what you log in with.

To point the Flutter app at it, set in `lib/core/config/app_config.dart`:

```dart
factory AppConfig.development() => const AppConfig(
  environment: Environment.development,
  apiBaseUrl: 'http://localhost:8080/api',
  useMockAuth: false, // now backed by a real server
);
```

Android emulators can't reach your machine's `localhost` directly — use `http://10.0.2.2:8080/api` instead when testing on the emulator. A real device needs your machine's LAN IP.

## The contract

### `POST /api/auth/login`
Request: `{"email": "...", "password": "..."}`
Response `200`: `{"user": {"id", "name", "email", "role"}, "token": "..."}`
Response `401`: invalid credentials

### `POST /api/auth/register`
Request: `{"name": "...", "email": "...", "password": "..."}`
Response `200`: same shape as login. New accounts are always `citizen` role.
Response `422`: email already registered

### `POST /api/sync/<table>`
Request: `{"entityId": "...", "operation": "create|update|delete", "payload": "<json-encoded string>"}`
Response `200`: `{"conflict": false}` — accepted
Response `200`: `{"conflict": true, "serverVersion": N}` — the payload's own `version` field wasn't strictly newer than what the server already has for this `table:entityId`; nothing was overwritten. This is what `SyncEngine.resolveConflict` on the client already expects and handles.

## Running its own tests

```
cd backend
dart test
```
