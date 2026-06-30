# CatMatch - Project Plan

## Project Overview

**CatMatch** is an iOS app that consumes TheCatAPI to let users browse cat breeds, vote on their favorites (like/dislike), and view their voting history. Built with Clean Architecture, targeting iOS 26.

**Framework split**: 80% SwiftUI + 20% UIKit (integrated via UIViewRepresentable)

## Project Goals

- **Primary**: Deliver a functional MVP with voting, breed browsing, and vote history
- **Secondary**: Demonstrate senior iOS skills: UIKit + SwiftUI integration, Clean Architecture, SPM modularization
- **Technical**: Showcase both declarative (SwiftUI) and imperative (UIKit) UI paradigms professionally

## Technology Stack

| Technology | Usage |
|------------|-------|
| **Swift** 6.0 | Language |
| **SwiftUI** | 80% of UI (Voting, CatList, CatDetail) |
| **UIKit** | 20% of UI (VoteHistory via UIViewRepresentable) |
| **Observation** | Reactive state with `@Observable` |
| **SwiftData** | Local persistence for votes |
| **SPM (CatUI)** | Design system package — external repo: `github.com/Eduardo0224/CatUI` |
| **URLSession** | Networking with async/await |
| **Swift Testing** | Unit tests |
| **XCTest** | UI tests |
| **String Catalog** | Spanish & English localization |

## API

**TheCatAPI**: https://api.thecatapi.com/v1

**Authentication**: API key via `x-api-key` header (stored in `Secrets.xcconfig` → Info.plist → `Bundle.main`)

**Key Endpoints**:
| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/breeds` | List all cat breeds |
| `GET` | `/breeds/search?q={query}` | Search breeds by name |
| `GET` | `/images/search?breed_id={id}&limit={n}` | Get images for a breed |
| `GET` | `/images/{id}` | Get a specific image |

---

## MVP Requirements (Version 1.0.0)

### Mandatory Features (from technical test)

1. ✅ Voting screen with like/dislike for cat breeds
2. ✅ Save votes locally with date, breed name, and vote type
3. ⬜ View voting history (UIKit implementation)
4. ✅ Cat breed list with images
5. ✅ Breed detail view (tap from list)

---

## Development Phases

### Phase 1: v0.2.0 - CatList + CatDetail (SwiftUI) ✅

#### Feature: CatList & CatDetail
**Framework**: SwiftUI
**Description**: Browseable list of cat breeds with search and detail navigation

**User Stories**:
- As a user, I want to see a list of cat breeds with images
- As a user, I want to search breeds by name
- As a user, I want to tap a breed to see its details (name, description, temperament, origin)

**Endpoints**:
- `GET /breeds` - List all breeds
- `GET /breeds/search?q={query}` - Search breeds
- `GET /images/search?breed_id={id}&limit=1` - Get breed image

**Models**:
- `CatBreed`: Breed info (id, name, description, origin, temperament, life_span, weight, etc.)
- `CatImage`: Image info (id, url, breed_id, width, height)

**UI Components**:
- `CatListView`: Breed list with search
- `CatRowView`: Individual breed row (uses CatUI components)
- `CatDetailView`: Breed detail with full info

---

### Phase 2: v0.3.0 - Voting (SwiftUI) ✅

#### Feature: Voting
**Framework**: SwiftUI
**Description**: Tinder-style voting screen for cat breeds

**User Stories**:
- As a user, I want to see a cat breed image and vote like/dislike
- As a user, I want smooth card-style transitions between votes
- As a user, I want my votes saved locally with date and breed name

**Endpoints**:
- `GET /breeds` - Get list of breeds to vote on
- `GET /images/search?breed_id={id}&limit=1` - Get breed image for card

**Models**:
- `Vote`: Local vote record (breedId, breedName, imageUrl, voteType, date) — SwiftData

**UI Components**:
- `VotingView`: Main voting screen with like/dislike buttons
- `VoteCardView`: Card with breed image and name (uses CatUI)

---

### Phase 3: v0.4.0 - VoteHistory (UIKit) ✅ COMPLETED (2026-06-30)

#### Feature: VoteHistory
**Framework**: UIKit (via UIViewRepresentable)
**Description**: Vote history list using modern UIKit collection views

**User Stories**:
- As a user, I want to see my past votes with date, breed name, and vote type
- As a user, I want to filter votes by type (All, Likes, Dislikes)
- As a user, I want to delete individual votes with swipe action

**UIKit Patterns Used**:
- `UICollectionViewCompositionalLayout.list(using:)` for list layout
- `UICollectionViewDiffableDataSource` for data management with snapshots (using `Vote.ID` identifiers, not full models)
- `UIStackView` for layout (avoid constraint complexity)
- Closure-based view initialization (private lazy vars)
- `UIViewRepresentable` wrapper for SwiftUI integration

**Persistence**:
- SwiftData (shared with Voting feature)

**UI Components** (all UIKit, private, closure-initialized):
- `VoteHistoryViewController`: UIViewController with UICollectionView
- `VoteHistoryRepresentable`: UIViewRepresentable wrapper
- `VoteCell`: UICollectionViewCell subclass

---

### Phase 4: v1.0.0 - MVP Integration & Polish

- Integrate all features into TabView navigation
- CatUI package with reusable components
- Accessibility audit (VoiceOver labels, Dynamic Type)
- UI Tests for critical flows
- Final testing and App Store preparation

---

## SwiftUI / UIKit Split (80/20)

```
┌──────────────────────────────────────────────────────┐
│  SwiftUI (80%)              │  UIKit (20%)           │
│                              │                        │
│  • VotingView                │  • VoteHistoryView     │
│  • VoteCardView              │    - UIViewController  │
│  • CatListView               │    - UICollectionView  │
│  • CatRowView                │    - DiffableDataSource│
│  • CatDetailView             │    - CompositionalLayout│
│  • TabView navigation        │    - UIStackView       │
│  • Search                    │  • UIViewRepresentable │
│  • All ViewModels            │    wrapper for SwiftUI │
│  • All Interactors           │                        │
└──────────────────────────────────────────────────────┘
```

### UIKit Integration Pattern

```swift
// UIViewRepresentable wrapper for SwiftUI
struct VoteHistoryRepresentable: UIViewControllerRepresentable {
    let viewModel: VoteHistoryViewModel

    func makeUIViewController(context: Context) -> VoteHistoryViewController {
        VoteHistoryViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: VoteHistoryViewController, context: Context) {
        uiViewController.applySnapshot()
    }
}

// UIKit ViewController with modern collection view
final class VoteHistoryViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: VoteHistoryViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, Vote.ID>?
    private var collectionView: UICollectionView!

    // MARK: - Private Views (closure-based initialization)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    // MARK: - Initializers

    init(viewModel: VoteHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }
}
```

---

## CatUI Design System (SPM Package)

**CatUI** is a **separate public GitHub repository** ([github.com/Eduardo0224/CatUI](https://github.com/Eduardo0224/CatUI)) added as an SPM dependency in CatMatch. It contains reusable UI components and design tokens.

### Package Structure (in its own repo)

```
CatUI/
├── Package.swift
├── Sources/
│   └── CatUI/
│       ├── Tokens/
│       │   ├── CatColors.swift
│       │   ├── CatSpacing.swift
│       │   ├── CatRadius.swift
│       │   └── CatTypography.swift
│       ├── Components/
│       │   ├── CatCardView.swift
│       │   ├── CatBadgeView.swift
│       │   ├── CatImageView.swift
│       │   ├── CatButton.swift
│       │   ├── CatLoadingView.swift
│       │   ├── CatEmptyView.swift
│       │   └── CatErrorView.swift
│       └── Modifiers/
│           ├── View+CatCard.swift
│           └── View+CatShimmer.swift
└── Tests/
    └── CatUITests/
```

### Design Tokens

**Color Palette** (inspired by [Dribbble — Pet Marketplace](https://dribbble.com/shots/25955678-Pet-Marketplace-App-Mobile-Design)):
| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `.catAccent` | `#E22E57` | `#E22E57` | Primary buttons, like action |
| `.catAccentSubtle` | `#FFCEDE` | `#3D202B` | Badge backgrounds, highlights |
| `.catSurfacePrimary` | `#FFFFFF` | `#191617` | Screen backgrounds |
| `.catSurfaceSecondary` | `#FFF5F0` | `#2A2426` | Cards, elevated surfaces |
| `.catTextPrimary` | `#191617` | `#FFFFFF` | Headlines, body text |
| `.catTextSecondary` | `#6B5B5E` | `#B0A0A5` | Metadata, captions |
| `.catTextOnAccent` | `#FFFFFF` | `#FFFFFF` | Text over accent |

**Components** (10 total): `CatCardView`, `CatBadgeView`, `CatButtonStyle` + `CatButton`, `CatFloatingButton`, `CatImageView`, `CatLoadingView`, `CatEmptyView`, `CatErrorView`, `CatVoteCellConfiguration`

**Modifiers** (3): `.catCardStyle()`, `.shimmer()`, `.catSkeleton()`
- **Spacing**: `CatSpacing.spacing4` through `CatSpacing.spacing32`
- **Radius**: `CatRadius.radius8`, `CatRadius.radius12`, `CatRadius.radius16`
- **Typography**: `.catDisplay`, `.catTitle`, `.catHeadline`, `.catBody`, `.catCaption`

---

## Architecture

### Clean Architecture (4 Layers)

```
Views (SwiftUI + UIKit)    ← UI only, no logic
    ↓
ViewModels (@Observable)   ← Presentation logic, state
    ↓
Interactors (Protocol)     ← Business logic, data access
    ↓
Models (Structs)           ← Pure data, Codable/Sendable
```

> **Note**: UIKit views observe ViewModels via the UIViewRepresentable update cycle.
> The ViewModel remains `@Observable` — UIKit reads state changes through the representable's `updateUIViewController` method.

### Feature-Based Organization

```
CatMatch/
├── CatMatch.xcodeproj
├── CatMatch/                           ← Main app target
│   ├── CatMatchApp.swift
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── CatBreed.swift
│   │   │   └── CatImage.swift
│   │   ├── Services/
│   │   │   ├── Protocols/
│   │   │   │   └── NetworkServiceProtocol.swift
│   │   │   └── NetworkService.swift
│   │   ├── Extensions/
│   │   │   └── L10n.swift
│   │   └── Components/
│   ├── Features/
│   │   ├── CatList/
│   │   │   ├── Interactor/
│   │   │   │   ├── Protocols/CatListInteractorProtocol.swift
│   │   │   │   ├── CatListInteractor.swift
│   │   │   │   └── MockCatListInteractor.swift
│   │   │   ├── ViewModel/
│   │   │   │   └── CatListViewModel.swift
│   │   │   └── Views/
│   │   │       ├── CatListView.swift
│   │   │       └── Components/
│   │   │           └── CatRowView.swift
│   │   ├── CatDetail/
│   │   │   ├── ViewModel/
│   │   │   │   └── CatDetailViewModel.swift
│   │   │   └── Views/
│   │   │       └── CatDetailView.swift
│   │   ├── Voting/
│   │   │   ├── Models/
│   │   │   │   └── Vote.swift
│   │   │   ├── Interactor/
│   │   │   │   ├── Protocols/VotingInteractorProtocol.swift
│   │   │   │   ├── VotingInteractor.swift
│   │   │   │   └── MockVotingInteractor.swift
│   │   │   ├── ViewModel/
│   │   │   │   └── VotingViewModel.swift
│   │   │   └── Views/
│   │   │       ├── VotingView.swift
│   │   │       └── Components/
│   │   │           └── VoteCardView.swift
│   │   └── VoteHistory/                ← UIKit feature
│   │       ├── ViewModel/
│   │       │   └── VoteHistoryViewModel.swift
│   │       └── Views/
│   │           ├── VoteHistoryRepresentable.swift  ← UIViewRepresentable
│   │           ├── VoteHistoryViewController.swift ← UIViewController
│   │           └── VoteCell.swift                  ← UICollectionViewCell
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.xcstrings
└── CatMatchTests/
    └── Features/
        ├── CatList/
        ├── Voting/
        └── VoteHistory/
```

### Key Patterns

- **Dependency Injection**: Protocol-first with default parameter values
- **@Observable**: Modern Observation framework (iOS 17+)
- **@State ownership**: ViewModels owned by views (SwiftUI)
- **UIViewRepresentable**: UIKit integration into SwiftUI
- **Async/await**: Structured concurrency for all async operations
- **SwiftData**: Local persistence for voting history
- **Closure-based view init**: Private UIKit views initialized via closures
- **UIStackView**: Preferred over manual NSLayoutConstraint
- **UICollectionViewDiffableDataSource**: Uses `Vote.ID` identifiers (not full models) — models don't need `Hashable`
- **UICollectionViewCompositionalLayout**: Modern list layout (iOS 26+)
- **Spy pattern**: Testable components with tracking
