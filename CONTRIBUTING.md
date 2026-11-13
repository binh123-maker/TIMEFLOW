# Contributing to TIMEFLOW

Thank you for your interest in contributing to **TIMEFLOW**!  
TIMEFLOW is a free, open-source, local-first application licensed under the [GNU General Public License v3.0](LICENSE). We welcome community contributions, bug reports, documentation enhancements, and feature suggestions.

---

## Code of Conduct

Please treat everyone with respect, kindness, and professionalism. We are committed to providing a welcoming, constructive environment for contributors of all experience levels.

---

## Architectural Principles

Before submitting code, please keep in mind our core project principles:
1. **Local-First & Offline-First:** Core functionality must operate 100% offline without remote server dependencies.
2. **Privacy by Default:** No telemetry, analytics, ad networks, or hidden trackers are permitted.
3. **No Unnecessary Permissions:** Do not introduce broad permissions (such as `INTERNET` in release mode or location access) unless explicitly approved.
4. **Platform Harmony:** Maintain clean separation between platform-agnostic Flutter code and Android Native Kotlin implementations.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x stable)
- [Dart SDK](https://dart.dev/get-dart) (^3.11.4)
- Java Development Kit (JDK 17)
- Android SDK (API 34/35)

### Setup Workflow
1. **Fork the repository** on GitHub.
2. **Clone your fork locally:**
   ```bash
   git clone https://github.com/<your-username>/TIMEFLOW.git
   cd TIMEFLOW
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Verify static analysis and tests:**
   ```bash
   flutter analyze
   flutter test
   ```
5. **Run the application:**
   ```bash
   flutter run -d android
   ```

---

## Development Guidelines

- **Code Formatting:** Format all Dart files before committing:
  ```bash
  dart format lib test
  ```
- **Static Analysis:** Ensure zero errors or warnings:
  ```bash
  flutter analyze
  ```
- **Testing:** Include unit tests or widget tests for all new business logic:
  ```bash
  flutter test
  ```
- **Database Migrations:** If modifying Drift SQLite tables (`lib/data/database/tables/`), write explicit migration strategies and update database unit tests. Run code generation:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## Submitting a Pull Request (PR)

1. Create a descriptive feature branch from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
2. Commit your changes with clear, semantic commit messages (e.g., `feat: ...`, `fix: ...`, `docs: ...`).
3. Push to your fork and submit a Pull Request to the `main` branch of `binh123-maker/TIMEFLOW`.
4. Provide a thorough summary of your changes, reference any related issues, and attach screenshots or testing steps where applicable.

