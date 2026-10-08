# Learning Dashboard — Senior Mobile Technical Assignment

A robust, offline-first mobile application built with **Flutter** and **GetX State Management**, demonstrating production-grade architecture, predictable reactive state handling, offline persistence, and automated unit testing.

---

## 1. Architecture
### Why Clean Architecture + MVVM with GetX?
We adopted **Clean Architecture with MVVM** structured into strict unidirectional layers:
```
Presentation (Views + Controllers + Bindings)
      ↓
Domain (Repository Interfaces + Entities)
      ↓
Data (Repository Implementations + Remote & Local DataSources)
```
- **Separation of Concerns & Testability**: Business logic and progress calculation are isolated from the UI rendering layer. Controllers interact solely with domain abstraction interfaces (`CourseRepository`, `AuthRepository`), enabling 100% deterministic unit testing with test doubles.
- **Predictable Reactive State (`StateMixin`)**: Instead of ad-hoc booleans, we utilize GetX's `StateMixin<List<CourseModel>>` to model exact deterministic UI states: `Loading`, `Success`, `Empty`, and `Error`.
- **Decoupled Dependency Injection**: GetX `Bindings` (`InitialBinding`, `DashboardBinding`, `AuthBinding`) wire dependencies lazily and manage lifecycle teardown automatically without polluting UI widgets.

---

## 2. Offline Support
### Storing and Loading Offline Data
- **Offline-First Repository Strategy**:
  1. **Online**: Remote courses are fetched via `CourseRemoteDataSource`, merged with any locally modified progress, and persisted to `GetStorage` key-value cache.
  2. **Offline**: When network connectivity is unavailable (or network call fails), `CourseRepositoryImpl` seamlessly falls back to `CourseLocalDataSource.getCachedCourses()`.
  3. **Progress Recalculation & Mutation**: Toggling a lesson dynamically updates completion, calculates `(completed / total * 100)%`, and writes back to local cache immediately so offline user progress is never lost across app restarts.
- **Interactive Evaluator Sandbox**: The Dashboard features top toolbar controls allowing the evaluator to toggle between simulated offline, API 500 error, and empty list states on demand.

---

## 3. Security
### Production Authentication Token Storage
In a production app, mock storage would be replaced with hardware-backed encryption:
- **Storage Location**:
  - **iOS/macOS**: iOS Keychain via `kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
  - **Android**: Android Keystore via EncryptedSharedPreferences (AES-256-GCM hardware-backed MasterKey).
  - **Flutter Plugin**: `flutter_secure_storage`.
- **Token Lifecycle & Network Security**:
  - Store tokens as ephemeral access tokens with automatic silent refresh via HTTP `401 Unauthorized` interceptors.
  - Implement **SSL Pinning** (using Certificate/Public Key hashes) to prevent Man-in-the-Middle (MITM) attacks.
  - Prevent tokens from leaking into crash reports, logs, or unencrypted backups (`allowBackup="false"`).

---

## 4. Scale (1 Million Users + Hundreds of Courses)
To scale the application to 1M+ active users and large catalogs:
1. **Server-Driven Pagination & Cursor Pagination**: Shift from bulk array responses to cursor-based infinite scroll (e.g. `pageSize=20`) to minimize mobile memory footprint and payload size.
2. **HTTP Caching with ETags / `304 Not Modified`**: Use Conditional GET requests with HTTP ETags / `If-None-Match` headers so clients only download payloads when the course catalog actually changes, reducing server egress by ~80%.
3. **Embedded Relational/Object Database**: Migrate from single JSON key-value cache to an indexed SQLite (`drift`) or Isar/ObjectBox database for sub-millisecond querying, multi-table relations (Course ↔ Module ↔ Lesson), and incremental transactional diffs.
4. **CDN Edge Caching**: Distribute static course syllabus metadata and media assets via Cloudflare / CloudFront edge nodes close to end-users.

---

## 5. Second Platform Transition
### How to implement this in Native Android (Kotlin / Jetpack Compose) & iOS/macOS (Swift / SwiftUI)

#### Native Android (Kotlin + Jetpack Compose)
- **UI**: Jetpack Compose (`@Composable CourseDashboardScreen`, `LazyColumn`, `LinearProgressIndicator`).
- **State Management**: Android Architecture Components `ViewModel` exposing `StateFlow<CourseUiState>` with sealed classes (`Loading`, `Success`, `Empty`, `Error`).
- **Offline Storage**: **Room Database** (`@Entity`, `@Dao`) with Flow queries for automatic reactive SQLite updates.
- **DI & Networking**: **Dagger / Hilt** for dependency injection and **Retrofit + OkHttp** for API requests.

#### Native iOS/macOS (Swift + SwiftUI)
- **UI**: SwiftUI (`List`, `ProgressView`, `@Observable` or `@StateObject`).
- **State Management**: `ObservableObject` / Swift 5.9 `@Observable` with `@Published var state: CourseState`.
- **Offline Storage**: **SwiftData** or **CoreData** with SQLite persistent store for offline persistence.
- **DI & Networking**: Protocol-oriented dependency injection with `URLSession` and `async/await` actors.

---

## Quick Start & Verification

### Run Automated Unit Tests:
```bash
flutter test
```

### Run Static Analysis:
```bash
flutter analyze
```

### Run on Connected Device / Simulator:
```bash
# Run on macOS desktop:
flutter run -d macos

# Or run on Android emulator:
flutter run -d emulator-5554
```

### Credentials for Demo:
- **Default Valid Login**: `learner@example.com` / `password123` *(Tap "Valid Login" chip on login screen)*
- **Simulate Login Error**: Password `wrongpassword` *(Tap "Invalid Login" chip)*
