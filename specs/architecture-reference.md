# Architecture Reference — CatMatch

## Overview

This document describes the architecture decisions, project structure, and key patterns used in CatMatch. It complements the reusable patterns in `skills/` with CatMatch-specific architectural choices.

> **Platform scope**: iOS 26 only. iPadOS may be added post-v1.0.0.
> **CatUI**: External public repo at `github.com/Eduardo0224/CatUI`. Added as SPM dependency.

---

## Project Structure

```
CatMatch/
├── CatMatch.xcodeproj
├── CatMatch/                           ← Main app target
│   ├── CatMatchApp.swift               ← @main entry point
│   ├── Core/
│   │   ├── Models/                     ← CatBreed, CatImage (shared models)
│   │   ├── Services/
│   │   │   ├── Protocols/
│   │   │   │   └── NetworkServiceProtocol.swift
│   │   │   └── NetworkService.swift
│   │   ├── Extensions/
│   │   │   └── L10n.swift              ← Type-safe localization
│   │   └── Components/                 ← App-specific shared components
│   ├── Features/
│   │   ├── CatList/
│   │   │   ├── Interactor/
│   │   │   │   ├── Protocols/CatListInteractorProtocol.swift
│   │   │   │   ├── CatListInteractor.swift
│   │   │   │   └── MockCatListInteractor.swift
│   │   │   ├── ViewModel/CatListViewModel.swift
│   │   │   └── Views/CatListView.swift, CatRowView.swift
│   │   ├── CatDetail/
│   │   │   ├── ViewModel/CatDetailViewModel.swift
│   │   │   └── Views/CatDetailView.swift
│   │   ├── Voting/
│   │   │   ├── Models/Vote.swift       ← SwiftData model
│   │   │   ├── Interactor/
│   │   │   │   ├── Protocols/VotingInteractorProtocol.swift
│   │   │   │   ├── VotingInteractor.swift
│   │   │   │   └── MockVotingInteractor.swift
│   │   │   ├── ViewModel/VotingViewModel.swift
│   │   │   └── Views/VotingView.swift, VoteCardView.swift
│   │   └── VoteHistory/                ← UIKit feature
│   │       ├── ViewModel/VoteHistoryViewModel.swift
│   │       └── Views/
│   │           ├── VoteHistoryRepresentable.swift  ← UIViewRepresentable
│   │           ├── VoteHistoryViewController.swift ← UIViewController
│   │           └── VoteCell.swift                  ← UICollectionViewCell
│   └── Resources/
│       ├── Assets.xcassets
│       └── *.xcstrings                 ← String Catalog files
└── CatMatchTests/
    ├── Shared/Spies/                   ← Spy implementations
    └── Features/
        ├── CatList/
        ├── Voting/
        └── VoteHistory/
```

---

## Clean Architecture in Practice

### Layer Responsibilities

| Layer | Responsibility | Must NOT do |
|-------|---------------|-------------|
| **Models** | Pure data, Codable, Sendable | Business logic, UI code |
| **Interactors** | Business logic, API calls, data access | UI code, SwiftUI imports |
| **ViewModels** | State management, error handling, presentation logic | Direct API calls without Interactor |
| **Views** | UI rendering, delegate actions to ViewModel | Business logic, API calls |

### Dependency Flow

```
CatMatchApp
  └─ ContentView (TabView)
       ├─ CatListView (SwiftUI)
       │    └─ @State CatListViewModel
       │         └─ CatListInteractorProtocol
       │              └─ NetworkServiceProtocol
       │                   └─ URLSession
       ├─ VotingView (SwiftUI)
       │    └─ @State VotingViewModel
       │         └─ VotingInteractorProtocol
       │              └─ NetworkServiceProtocol + SwiftData
       └─ VoteHistoryView (UIKit via UIViewRepresentable)
            └─ VoteHistoryViewController
                 └─ VoteHistoryViewModel (@Observable)
                      └─ SwiftData (shared with Voting)
```

### Dependency Injection Pattern

Every layer receives its dependencies via initializer with default values:

```swift
// View → ViewModel → Interactor → Services

struct CatListView: View {
    @State private var viewModel: CatListViewModel

    init(interactor: CatListInteractorProtocol = CatListInteractor()) {
        self.viewModel = CatListViewModel(interactor: interactor)
    }
}

@Observable @MainActor
final class CatListViewModel {
    @ObservationIgnored
    private let interactor: CatListInteractorProtocol

    init(interactor: CatListInteractorProtocol = CatListInteractor()) {
        self.interactor = interactor
    }
}

final class CatListInteractor: CatListInteractorProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
}
```

**Testing**: Inject Spy/Mock implementations through the same initializer.

---

## SwiftUI + UIKit Integration

### Pattern: UIViewControllerRepresentable

```swift
// VoteHistoryRepresentable.swift — SwiftUI wrapper
struct VoteHistoryRepresentable: UIViewControllerRepresentable {
    let viewModel: VoteHistoryViewModel

    func makeUIViewController(context: Context) -> VoteHistoryViewController {
        VoteHistoryViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ vc: VoteHistoryViewController, context: Context) {
        vc.applySnapshot()
    }
}

// Usage in SwiftUI
struct VotingView: View {
    @State private var viewModel: VotingViewModel

    var body: some View {
        TabView {
            VotingCardView(viewModel: viewModel)
                .tabItem { Label("Vote", systemImage: "heart") }

            VoteHistoryRepresentable(viewModel: viewModel.historyViewModel)
                .tabItem { Label("History", systemImage: "clock") }
        }
    }
}
```

### Shared ViewModel

The same `@Observable` ViewModel is used by both SwiftUI and UIKit views. UIKit reads state through the representable's `updateUIViewController` cycle.

---

## Navigation Architecture

### TabView Structure (v1.0.0)

```swift
TabView {
    CatListView()
        .tabItem { Label("Breeds", systemImage: "pawprint") }

    VotingView()
        .tabItem { Label("Vote", systemImage: "heart") }
}
```

### Navigation Within Features

- **CatList → CatDetail**: `NavigationStack` + `navigationDestination(for: CatBreed.self)`
- **Voting → VoteHistory**: Internal tab within VotingView or separate tab

---

## Testing Architecture

### Test Target Structure

```
CatMatchTests/
├── Shared/
│   ├── Spies/
│   │   ├── SpyNetworkService.swift
│   │   ├── SpyCatListInteractor.swift
│   │   └── SpyVotingInteractor.swift
│   └── Samples/
│       └── CatBreed+Samples.swift
└── Features/
    ├── CatList/
    │   ├── CatListTests.swift
    │   └── CatListTests+ViewModel.swift
    ├── Voting/
    │   ├── VotingTests.swift
    │   └── VotingTests+ViewModel.swift
    └── VoteHistory/
        ├── VoteHistoryTests.swift
        └── VoteHistoryTests+ViewModel.swift
```

### Testing Strategy

| Test Type | Framework | What to Test |
|-----------|-----------|--------------|
| **Unit (ViewModel)** | Swift Testing | State changes, error handling, Spy verification |
| **Unit (Interactor)** | Swift Testing | API calls, data transformation, error mapping |
| **UI Tests** | XCTest | Critical flows: vote → save → view history |

---

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **iOS 26 minimum** | Allows modern APIs, no legacy fallback code |
| **SwiftUI 80% / UIKit 20%** | SwiftUI for productivity, UIKit to demonstrate integration skill |
| **SwiftData over Core Data** | Modern, Swift-native, less boilerplate |
| **CatUI as SPM** | Separates design concerns, reusable across features |
| **String Catalog over .strings** | Modern Xcode-native, type-safe with `String(localized:)` |
| **Swift Testing over XCTest** (unit) | Modern, `@Test`/`#expect`, parameterized tests |
| **XCTest for UI tests** | Swift Testing doesn't yet support UI testing |
| **UICollectionViewDiffableDataSource with IDs** | Models don't need `Hashable`, snapshots are identifier-based |
| **Closure-based UIKit view init** | Cleaner than `viewDidLoad` clutter, consistent style |
| **UIStackView over constraints** | Simpler layout code, less error-prone |

---

## Future: iPadOS Support (Post-v1.0.0)

When iPad support is added:

- Use `horizontalSizeClass` for adaptive layouts (`.regular` → 2+ column grids)
- `NavigationSplitView` for sidebar on iPad
- Shared feature code (same ViewModels, Interactors)
- Platform-specific UI adaptations only in Views layer
- No separate target needed — adaptive SwiftUI handles this
