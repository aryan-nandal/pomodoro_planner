# Pomodoro Planner

> A cross-platform Flutter productivity app that combines a **task planner**, a **Pomodoro focus timer**, and **progress statistics**, backed by Firebase — built with a strong emphasis on **end-to-end integration testing against a real backend**.

Plan your day, focus on one task at a time with the Pomodoro technique, and watch your
productivity stats build up. Data syncs per-user through Firebase Auth and Cloud Firestore.

> [!IMPORTANT]
> **🧪 Automated End-to-End Testing** — the highlight of this project is a **sandboxed E2E test
> system** that runs the real app against a real Firebase backend (no mocks) in Docker.
>
> **→ Read the design & architecture doc: [`docs/e2e-integration-testing.md`](docs/e2e-integration-testing.md)**

## Features

- **Task Planner** — create tasks with categories, priorities, subtasks, and scheduling; search and an archive of past tasks. Completing all subtasks auto-completes the task.
- **Pomodoro Timer** — focus / short-break / long-break cycles (a long break after every 4 focus sessions), custom durations, and alarm + haptic + local-notification cues. Start a focus session directly from a task.
- **Statistics** — today's completed tasks, focus minutes today and over the last 7 days (charted), total Pomodoros, and a daily activity streak.
- **Accounts & Sync** — email/password auth with per-user data isolation in Cloud Firestore.

## Architecture

- **Feature-first clean architecture** — each feature is split into `domain` (entities + repository interfaces), `data` (Firestore repositories + models), and `presentation` (BLoC + screens/widgets).
- **State management** — [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) across auth, tasks, pomodoro, and statistics.
- **Backend** — Firebase Auth + Cloud Firestore, with per-user data scoped under `users/{uid}/…`.
- **Observability** — Sentry plus a custom `BlocObserver` for state-transition logging.

```
lib/
├── core/                 # theme, services (audio/haptic/notifications), observability
└── features/
    ├── auth/             # sign in / sign up
    ├── tasks/            # task planner (the core feature)
    ├── pomodoro/         # focus timer
    └── statistics/       # productivity stats
```

## Tech stack

Flutter · Dart · `flutter_bloc` · `firebase_core` / `firebase_auth` / `cloud_firestore` ·
`fl_chart` · `flutter_local_notifications` + `timezone` · `audioplayers` · `sentry_flutter` ·
`equatable` · `uuid`

## End-to-end integration testing

The standout part of this project is a **sandboxed E2E test system** that runs the real app
against a real Firebase backend — no mocks. Each test runs in a disposable Docker container
that boots the **Firebase Emulator Suite**, wipes and seeds the database from a JSON fixture,
drives the real app through headless Chromium, and captures screenshots of every key screen.

```bash
./run_integration_tests.sh    # requires only Docker
```

📄 **Design & rationale:** [`docs/e2e-integration-testing.md`](docs/e2e-integration-testing.md) — the problem, the key design decisions and trade-offs, and architecture/sequence diagrams.

## Getting started

```bash
flutter pub get
flutter run            # add -d chrome / -d <device> to target a platform
```

Firebase is configured via `lib/firebase_options.dart`. To point the app at local emulators
instead of the live project, build with `--dart-define=USE_EMULATOR=true`.
