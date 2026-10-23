# CyberEncrypt — Flutter Frontend

Flutter replacement for the React frontend, talking to your **unchanged**
Node.js/Express backend (`server.js`, port 5001).

## 1. Fix the backend first (1 file, 3 lines)

`backend/settings.js` has a pre-existing bug: `authMiddleware` sets
`req.user`, but `settings.js` reads `req.userId` (which is always
`undefined`). This breaks `GET /api/settings`, `PUT /api/settings/profile`,
and `PUT /api/settings/password` — independent of any frontend.

Replace your `backend/routes/settings.js` with the corrected version
(`req.userId` → `req.user._id`, 3 occurrences) before testing Settings from
the Flutter app. The rest of your backend needs ZERO changes — everything
else was already correct.

## 2. Project structure

```
cyberencrypt_flutter/
├── pubspec.yaml
└── lib/
    ├── main.dart                    # entrypoint, auth gate (loading/login/dashboard)
    ├── theme/
    │   └── matrix_theme.dart        # green/black theme, ported from index.css
    ├── models/
    │   └── user_model.dart          # mirrors backend User schema
    ├── services/
    │   ├── api_service.dart         # ALL http calls — every route verified against your backend
    │   └── auth_provider.dart       # token persistence (SharedPreferences = localStorage equivalent)
    ├── widgets/
    │   ├── matrix_rain.dart         # CustomPainter port of the canvas rain effect
    │   └── user_avatar.dart         # ONE avatar widget used everywhere (real pic + initials fallback)
    └── screens/
        ├── auth_screen.dart         # login/signup, port of AuthForm.js
        ├── dashboard_screen.dart    # sidebar shell, port of pages/Dashboard.js
        ├── encryption_screen.dart   # port of EncryptionTool.js
        ├── messages_screen.dart     # port of MessageBox.js
        ├── history_screen.dart      # port of HistoryLog.js (Clear-All removed, see bugs)
        ├── blockchain_screen.dart   # port of BlockchainViewer.js
        ├── settings_screen.dart     # port of Settings.js + missing profile-pic field added
        └── profile_screen.dart      # port of Profile.js, now shows real avatars
```

## 3. Setup commands (run in order)

```bash
# 1. Create/confirm Flutter is installed
flutter --version

# 2. From inside cyberencrypt_flutter/, fetch dependencies
flutter pub get

# 3. Point the app at your backend.
#    Emulator/simulator -> defaults already work (10.0.2.2 = Android emulator's
#    view of your host machine's localhost). For a real device or iOS
#    simulator, override at run time:
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5001

# iOS simulator / flutter web / desktop can usually just use:
flutter run --dart-define=API_BASE_URL=http://localhost:5001

# 4. Start your (unchanged, except the settings.js fix) backend separately:
cd backend/backend
npm run dev
```

If you don't pass `--dart-define`, it defaults to `http://10.0.2.2:5001`
(Android emulator talking to your host machine).

## 4. Bugs fixed vs. the original React app

1. Hardcoded `http://localhost:5001` scattered across components →
   single `ApiConfig.baseUrl`, configurable at build/run time.
2. `EncryptionTool.js` posted to `/api/history/add`, which doesn't exist on
   the backend → removed; if you want per-operation history logging, add a
   real `POST /api/history` route server-side first.
3. `HistoryLog.js` called `DELETE /api/history`, which doesn't exist →
   "Clear All" removed from the Flutter History screen for the same reason.
4. `userList.js` called `/api/users` (404) instead of `/api/users/all` →
   fixed (this component is superseded by `profile_screen.dart` anyway).
5. `Profile.js` / `Header.js` never rendered `user.profilePic`, always
   showing initials → new shared `UserAvatar` widget shows the real image
   everywhere, with initials only as a fallback (matches what `userList.js`
   already did correctly).
6. `Settings.js` had no UI to change `profilePic` even though the backend
   route supports it → added a "Profile Picture URL" field.
7. Profile.js's "Send Message" button just called `alert(...)` → now shows a
   real action (extend this to actually switch tabs + prefill the recipient
   in `messages_screen.dart` if you want one-tap messaging).
8. `settings.js` backend bug (`req.userId` vs `req.user._id`) — see step 1
   above.

## 5. Things that need a decision from you (not guessed at)

- **Google OAuth on mobile**: your backend's `/api/auth/google/callback`
  redirects to `${FRONTEND_URL}?token=...`, which assumes a web frontend.
  For Flutter, you'll want either (a) a WebView that intercepts the
  redirect, or (b) change the backend callback to redirect to a custom URL
  scheme (`cyberencrypt://auth?token=...`) and register that scheme in
  `android/app/src/main/AndroidManifest.xml` / iOS `Info.plist`. I left
  `_continueWithGoogle()` opening the URL in an external browser as a
  starting point — tell me which approach you want and I'll wire it up.
- **Real profile picture upload** (not just a URL): needs a new backend
  endpoint (multer + local disk or cloud storage like S3/Cloudinary) since
  the current schema/route only stores a URL string.
