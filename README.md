# Technical Assignment — Learning Dashboard

Submission for Senior Mobile App Developer technical assignment.
Built using Flutter and GetX with Clean MVVM architecture, offline persistence, and automated unit tests.

---

### 1. Architecture
**Why Clean Architecture + MVVM?**
- **Layer Decoupling**: The codebase is split into Presentation, Domain, and Data layers. The UI widgets only bind to Controllers/ViewModels, and Controllers only communicate through Repository interfaces (`CourseRepository`, `AuthRepository`).
- **Testability**: Keeping business logic (progress calculation, lesson state changes, offline fallbacks) in pure domain/data units allows straightforward, fast unit tests without inflating the widget tree.
- **Predictable Reactive State**: Using GetX's `StateMixin` keeps UI states explicit (`Loading`, `Success`, `Empty`, `Error`) rather than juggling scattered boolean flags across widgets.
- **Dependency Injection**: Dependencies are registered lazily via `Bindings` (`Get.lazyPut`), keeping lifecycle management out of the widget build methods.

---

### 2. Offline Support
**How offline data is stored and loaded:**
- **Local Cache**: Handled via `GetStorage` key-value store in `CourseLocalDataSource`.
- **Offline-First Strategy**:
  1. When network is active, courses are loaded from the mock remote datasource, merged with existing local progress, and written to disk.
  2. When the device is offline (or when a remote request fails), `CourseRepositoryImpl` returns the cached data immediately.
  3. When a user marks a lesson completed, the controller recalculates the course progress percentage and writes the updated course state directly to local storage.
- **Testing Offline**: The app bar includes a Wi-Fi toggle button and an options menu (`More` icon) to toggle offline mode, simulate 500 errors, or simulate empty states for testing.

---

### 3. Security
**Where would authentication tokens be stored in a production application?**
- In production, plain local storage is not used for tokens. Tokens should be stored in platform-level secure storage:
  - **iOS/macOS**: iOS Keychain via `kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
  - **Android**: Android Keystore backed by `EncryptedSharedPreferences` (AES-256 GCM).
  - **Flutter**: Using `flutter_secure_storage`.
- Access tokens should be short-lived with an automated refresh token rotation flow handled via an HTTP interceptor.
- For API communication, SSL Pinning (public key pinning) should be enabled to prevent MITM attacks.

---

### 4. Scale
**If this app had 1 million users and hundreds of courses, what would you improve?**
1. **Pagination & Lazy Loading**: Replace full-catalog fetching with cursor-based pagination (e.g. 20 courses per page) to reduce network payload and client memory consumption.
2. **Local Database Migration**: Replace simple JSON file storage with an embedded relational database (SQLite via `drift` or Room/CoreData) with indexed fields for fast querying, filtering, and incremental sync.
3. **HTTP Caching**: Implement conditional requests using `ETag` and `If-None-Match` headers so the client receives `304 Not Modified` when course data hasn't changed.
4. **CDN & Edge Caching**: Offload course syllabus, instructor metadata, and multimedia assets to CDN edge servers.

---

### 5. Second Platform Implementation
**How this architecture maps to native Android and iOS/macOS:**

- **Android (Kotlin / Jetpack Compose)**:
  - **UI**: Jetpack Compose (`LazyColumn`, `LinearProgressIndicator`).
  - **State**: Android Architecture Components `ViewModel` exposing `StateFlow<UiState>` with sealed classes (`Loading`, `Success`, `Empty`, `Error`).
  - **Persistence**: **Room Database** (`@Dao`, `@Entity`) with Coroutine Flow for reactive database queries.
  - **DI & Network**: **Hilt** and **Retrofit + OkHttp**.

- **iOS / macOS (Swift / SwiftUI)**:
  - **UI**: SwiftUI (`List`, `ProgressView`).
  - **State**: `@Observable` (or `@StateObject` with `ObservableObject`) managing state enums.
  - **Persistence**: **SwiftData** or **CoreData** with SQLite store.
  - **DI & Network**: Protocol-oriented DI with native `URLSession` async/await.

---

### Running the Project

#### Unit Tests
```bash
flutter test
```

#### Run on Device / Simulator
```bash
# macOS Desktop
flutter run -d macos

# Android Emulator
flutter run -d emulator-5554
```

#### Demo Credentials
- **Email**: `learner@example.com`
- **Password**: `password123`
*(Invalid password for error testing: `wrongpassword`)*
