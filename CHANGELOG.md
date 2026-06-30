# Changelog

All notable changes to the CatMatch project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v1.0.0

- Accessibility, UI tests, final polish for MVP release

---

## [0.4.0] - 2026-06-30

### Added

- **VoteHistory feature** (UIKit) — Vote history with modern UICollectionView APIs
  - `VoteHistoryViewController`: `UICollectionViewDiffableDataSource<Section, Vote.ID>` with `UICollectionViewCompositionalLayout.list(.grouped)`
  - `UISegmentedControl` filter (All / Likes / Dislikes) embedded in `navigationItem.titleView`
  - Swipe-to-delete with `UIContextualAction` and destructive style
  - `UIBackgroundConfiguration.clear()` for cells, CatUI design tokens for backgrounds
  - `VoteHistoryRepresentable`: `UIViewControllerRepresentable` wrapping a `UINavigationController`
  - `VoteHistoryViewModel`: `@Observable @MainActor` with `latestVotesByBreed` deduplication — one vote per breed, most recent determines status
  - `TabView` integration via `Tab()` API with `@State` ownership in `ContentView`
  - Empty state with `L10n.VoteHistory.empty` message
- **Voting upsert** — `saveVote()` now fetches existing vote by `breedId` and updates type/date instead of always inserting; guarantees one vote per breed
- **DiffableDataSource fix** — `snapshot.reconfigureItems()` forces cell content refresh on upsert where `Vote.ID` stays the same but vote type changes (like ↔ dislike)
- **VoteHistory localizations** — filter labels, title, empty state (en + es)

### Tests (14 tests)

- **VoteHistory ViewModel** (14): loadVotes (all/empty), filteredVoteIDs (all/likes/dislikes), setFilter, deleteVote (success/unknown ID), vote(for:), isEmpty (true/false), setModelContext
- In-memory `ModelConfiguration` with `ModelContainer` stored as property to prevent deallocation

---

## [0.3.0] - 2026-06-29

### Added

- **Voting feature** (SwiftUI) — Tinder-style horizontal card voting with SwiftData persistence
  - Horizontal `ScrollView` with `.viewAligned` snap-to-card, peek effect, and `scrollTransition`
  - `VotingViewModel`: `@Observable @MainActor` with breed queue from `BreedStore`, like/dislike advancing with `withAnimation(.snappy)`, SwiftData persistence via `saveVote()`
  - `VotingView`: 4-state UI (loading/error/empty/voting) with `CatButton` like/dislike
  - `VoteCardView`: Portrait card (1:1.4 ratio) with `frame(width:height:)` fixed dimensions, shadow, rounded corners
  - `Vote` model: SwiftData `@Model` with `VoteType` enum (like/dislike)
  - `CatMatchApp`: `.modelContainer(for: Vote.self)` for SwiftData
  - `ContentView`: `TabView` with Breeds + Vote tabs
- **BreedStore** (Core) — Shared `@MainActor @Observable` store eliminating duplicate `/breeds` requests
  - `BreedStoreProtocol` + `MockBreedStore` for DI in previews and tests
  - `loadIfNeeded()` idempotent, `withTaskGroup` for parallel image fetch
  - Captured Sendable `network` in task group closures (no Swift 6 warnings)
  - `CatListViewModel` refactored to use `BreedStore` for breed data
- **Voting.xcstrings**: title, like, dislike, empty keys (en + es)

### Changed

- **CatListViewModel**: Refactored to accept `BreedStore` for breed loading; `CatListInteractor` retained for search
- **CatDetailView**: Removed "Inku pattern" comments; `@MainActor` on `BreedStore` for concurrency safety
- **NetworkService**: Fixed query params embedded in endpoint strings being stripped by empty `queryItems`
- **NetworkError**: Added `Equatable` conformance for test assertions

### Tests (45 tests)

- **Voting ViewModel** (12): loadData, likeBreed/dislikeBreed advancement, setModelContext with in-memory store, retry, computed properties
- **CatList ViewModel** (14): Updated for `BreedStore` injection
- **CatList Interactor** (7): fetchBreedsWithImages, search, fetchImage
- **CatDetail ViewModel** (10): preloadedImage, network error, computed props
- **CatDetail Interactor** (3): fetchImage tests

---

## [0.2.0] - 2026-06-29

### Added

- **CatList feature** (SwiftUI) — Browse all cat breeds with thumbnail images and async image caching
  - `CatListInteractor`: Fetches breeds via `GET /breeds` and images in parallel via `withTaskGroup`
  - `CatListViewModel`: `@Observable @MainActor` with search debounce (500ms), error handling, retry
  - `CatListView`: `List` + `.searchable` with loading/empty/error states via CatUI components
  - `CatListRowView`: Reusable row with `CatImageView` (120×120 thumbnail) + breed name + temperament
  - Search with non-blocking error handling — preserves previous results on search failure
  - `breedImages` dictionary shared as `preloadedImage` to CatDetail to avoid redundant fetches
- **CatDetail feature** (SwiftUI) — Breed detail with hero image, temperament badges, and metadata
  - `CatDetailInteractor`: Fallback image fetch via `GET /images/{id}` when no preloaded image
  - `CatDetailViewModel`: `@Observable @MainActor` with preloaded image skip, computed display properties
  - `CatDetailView`: `ZStack` with `heroBackground` (blur + thinMaterial + gradient) and `ScrollView` content
  - `GeometryReader`-constrained image layout prevents horizontal overflow from `scaledToFill()`
  - Temperament traits as horizontal `CatBadgeView` scroll, detail rows for origin/weight/life span
- **Image caching** via CatUI `CatImageView` → `ImageCacheService` (actor-based, memory 100 items + disk)
  - Same URL deduplication — multiple views sharing the same URL reuse the in-flight download task
  - Default 150pt max width for cached thumbnails, with screen-scale-aware resizing
- **Font registration** — `CatFontRegistration.registerAll()` in `CatMatchApp.init()` loads Coolvetica
- **String Catalogs** — `CatList.xcstrings`, `CatDetail.xcstrings`, `Error.xcstrings` (en + es)

### Fixed

- **NetworkService**: Query params embedded in endpoint strings (e.g., `/breeds/search?q=Bengal`) were stripped by `URLComponents.queryItems = nil`. Now only overwrites when `queryItems` is non-empty.
- **Image layout**: `scaledToFill()` images no longer overflow horizontal padding — constrained via `GeometryReader` + `frame(width:height:)` fixed dimensions
- **Redundant breed re-fetch**: `CatListViewModel.loadBreeds()` now guards on `breeds.isEmpty` to prevent re-fetching on every view appearance

### Tests (32 tests)

- **CatList ViewModel** (14): loadBreeds (success/empty/error/re-entry/cancellation), image(for:), retry, searchQuery (empty/text/debounce/error/non-blocking)
- **CatList Interactor** (7): fetchBreedsWithImages (success/partial failure/breed error), searchBreeds, fetchImage
- **CatDetail ViewModel** (10): preloadedImage skip, loadImage (success/error/no refID/re-entry), computed properties
- **CatDetail Interactor** (3): fetchImage (success/error propagation/nil)
- Actor-based spies (no `@unchecked Sendable`) — `SpyCatListInteractor`, `SpyNetworkService`, `SpyCatDetailInteractor`
- Test target configured for iOS SDK with `TEST_HOST` + `BUNDLE_LOADER`, `CatMatch.xcscheme` with test action

### Changed

- `CatBreed`, `Weight`: Added `Hashable` conformance
- `NetworkError`: Added `Equatable` conformance for test assertions
- `CatMatch.xcodeproj`: Test target reconfigured from watchOS to iOS SDK

---

## [0.1.0] - 2026-06-29

### Added

- Initial Xcode project setup with iOS 26 target
- Clean Architecture project structure (feature-based organization)
- Skills documentation (5 reusable iOS patterns)
  - `skills/clean-architecture-ios/SKILL.md`
  - `skills/swiftui-observable/SKILL.md`
  - `skills/swiftui-components/SKILL.md`
  - `skills/swift-testing-patterns/SKILL.md`
  - `skills/ios-localization/SKILL.md`
- Specs documentation (4 project-specific references)
  - `specs/project-overview.md` - CatMatch project overview
  - `specs/api-endpoints.md` - TheCatAPI endpoint reference
  - `specs/architecture-reference.md` - Architecture decisions & patterns
  - `specs/cat-ui-design-system.md` - CatUI design system
- Project documentation
  - `CLAUDE.md` - AI assistant guidance (with skills + specs references)
  - `README.md` - Project overview
  - `PROJECT_PLAN.md` - Feature roadmap (4 features: CatList, Voting, VoteHistory, CatUI)
  - `GITFLOW.md` - Git workflow strategy
  - `LICENSE` - MIT License
  - `.gitmessage` - Commit message template
- Security configuration
  - `Secrets.xcconfig.example` - API key template
  - `.gitignore` - Protected files exclusion
- Git repository initialization

---

## Version Guidelines

### Semantic Versioning

- **0.x.x**: Pre-release versions (development phase)
- **1.0.0**: First stable release (MVP complete)
- **Major (x.0.0)**: Breaking changes, major new features
- **Minor (1.x.0)**: New features, backward compatible
- **Patch (1.0.x)**: Bug fixes, minor improvements

### Planned Versions

- **0.2.0**: CatList & CatDetail (SwiftUI) - Breed browsing with search and detail ✅
- **0.3.0**: Voting (SwiftUI) - Tinder-style like/dislike with SwiftData ✅
- **0.4.0**: VoteHistory (UIKit) - UICollectionView + DiffableDataSource + CompositionalLayout ✅
- **1.0.0**: MVP Release - Integration, accessibility, UI tests, polish

### Change Categories

- **Added**: New features or functionality
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

---

**Project**: CatMatch - Cat Breed Voting & Browsing
**Target Platform**: iOS 26+
**Language**: Swift 6
**UI Framework**: SwiftUI + Observation
**Architecture**: Clean Architecture (4 layers)
**Testing**: Swift Testing framework
**Localization**: Spanish & English
