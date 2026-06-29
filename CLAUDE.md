# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

- **Project**: CatMatch - iOS App
- **Language**: Swift (English-only code)
- **UI Framework**: SwiftUI (80%) + UIKit (20%) with Observation framework
- **Target**: iOS 26
- **Architecture**: Clean Architecture (4 layers) - Feature-based organization
- **Testing**: Swift Testing (unit) + XCTest (UI tests)
- **Localization**: String Catalog (Spanish & English)
- **API**: TheCatAPI (https://api.thecatapi.com)
- **Persistence**: SwiftData for local storage
- **Design System**: CatUI SPM Package

## Documentation Structure

This project uses **skills** (reusable patterns), **specs** (project-specific content), and **agents** (specialized subagents).

### Skills (Reusable Patterns)

Read the appropriate skill before implementing:

| Task | Required Skill |
|------|----------------|
| New feature | `skills/clean-architecture-ios/SKILL.md` |
| SwiftUI code | `skills/swiftui-observable/SKILL.md` |
| Create component | `skills/swiftui-components/SKILL.md` |
| Write tests | `skills/swift-testing-patterns/SKILL.md` |
| Add localization | `skills/ios-localization/SKILL.md` |

### Agents (Specialized Subagents)

Use these subagents for specific tasks. Each runs in its own context window with restricted tools.

| Task | Agent |
|------|-------|
| Review code changes | `.claude/agents/ios-code-reviewer.md` |
| Generate tests | `.claude/agents/test-generator.md` |
| Validate architecture | `.claude/agents/architecture-validator.md` |

### Specs (CatMatch-Specific Content)

Consult project-specific information:

| Information | Spec |
|-------------|------|
| Project overview | `specs/project-overview.md` |
| API endpoints | `specs/api-endpoints.md` |
| Architecture reference | `specs/architecture-reference.md` |
| CatUI design system | `specs/cat-ui-design-system.md` |

## Project Structure

```
CatMatch/
├── CLAUDE.md                          ← This file
├── README.md                          ← Project overview
├── PROJECT_PLAN.md                    ← Feature roadmap
├── CHANGELOG.md                       ← Version history
├── GITFLOW.md                         ← Git workflow
├── skills/                            ← Reusable iOS patterns
├── CatMatch.xcodeproj                 ← Xcode project
├── CatMatch/                          ← Main app target
│   ├── CatMatchApp.swift              ← App entry point
│   ├── ContentView.swift
│   ├── Core/                          ← Shared code (create as needed)
│   │   ├── Models/
│   │   ├── Services/
│   │   │   ├── Protocols/
│   │   │   ├── NetworkService.swift
│   │   │   └── CacheService.swift
│   │   ├── Extensions/
│   │   └── Components/                ← App-specific shared components
│   ├── Features/                      ← Feature modules (create as needed)
│   │   └── [FeatureName]/
│   │       ├── Models/
│   │       ├── Interactor/
│   │       │   ├── Protocols/
│   │       │   ├── [Feature]Interactor.swift
│   │       │   └── Mock[Feature]Interactor.swift
│   │       ├── ViewModel/
│   │       │   └── [Feature]ViewModel.swift
│   │       └── Views/
│   │           ├── [Feature]View.swift           ← SwiftUI
│   │           ├── [Feature]ViewController.swift ← UIKit (when applicable)
│   │           ├── [Feature]Representable.swift  ← UIViewRepresentable wrapper
│   │           └── Components/
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.xcstrings       ← When created
└── CatMatchTests/                     ← Test target (create as needed)
    └── Features/
        └── [FeatureName]/
            ├── [Feature]Tests.swift
            ├── [Feature]Tests+ViewModel.swift
            └── [Feature]Tests+Interactor.swift
```

## Golden Rules

1. ✅ Feature-based folder organization
2. ✅ One component = one file
3. ✅ Protocol-first for Interactors
4. ✅ `@Observable` for ViewModels (Observation framework)
5. ✅ `@State` for view-owned observable objects
6. ✅ `async/await` for all async operations
7. ✅ MARK comments in fixed order (see skills/swiftui-observable)
8. ✅ English code, localized UI (String Catalog)
9. ✅ Swift Testing for unit tests, XCTest for UI tests
10. ✅ LiquidGlass only where Apple recommends
11. ✅ Never commit secrets (use Secrets.xcconfig)
12. ✅ Dependency injection via initializers with default values
13. ✅ UIKit views: closure-based init, UIStackView > constraints, private scope
14. ✅ UIKit in SwiftUI via UIViewRepresentable/UIViewControllerRepresentable
15. ✅ Use CatUI components for shared UI (import CatUI)

## API Key Security

This project uses TheCatAPI which requires an API key.

### Setup

1. Copy `Secrets.xcconfig.example` to `Secrets.xcconfig`:
   ```bash
   cp Secrets.xcconfig.example Secrets.xcconfig
   ```

2. Replace the placeholder with your actual API key in `Secrets.xcconfig`:
   ```
   CATAPI_KEY = your-actual-api-key
   ```

3. The `Secrets.xcconfig` file is gitignored and will never be committed.

### Usage in Code

```swift
// Access the API key from Info.plist (configured via xcconfig)
let apiKey = Bundle.main.infoDictionary?["CATAPI_KEY"] as? String
```

## Common Commands

### Building and Running

```bash
# Open project in Xcode
open CatMatch.xcodeproj

# Build from command line
xcodebuild -project CatMatch.xcodeproj -scheme CatMatch -sdk iphonesimulator

# Clean build
xcodebuild clean -project CatMatch.xcodeproj -scheme CatMatch
```

### Testing

```bash
# Run all tests
xcodebuild test -project CatMatch.xcodeproj -scheme CatMatch -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

In Xcode:
- **⌘+B** to build
- **⌘+R** to run
- **⌘+U** to run all tests

## Architecture Overview

### Clean Architecture (4 Layers)

```
Views (SwiftUI + UIKit)   ← UI only, no logic
    ↓
ViewModels (@Observable)  ← Presentation logic, state
    ↓
Interactors (Protocol)    ← Business logic, data access
    ↓
Models (Structs)          ← Pure data, Codable/Sendable
```

**Framework split**:
- **SwiftUI** (`@State` + `@Observable`): Voting, CatList, CatDetail
- **UIKit** (`UIViewControllerRepresentable` + `@Observable`): VoteHistory
- Both observe the same `@Observable` ViewModel — no duplicate state

### Dependency Injection Pattern

All features use DI with protocol-first Interactors:

```swift
// View owns ViewModel via @State
struct CatListView: View {
    @State private var viewModel: CatListViewModel

    init(interactor: CatListInteractorProtocol = CatListInteractor()) {
        self.viewModel = CatListViewModel(interactor: interactor)
    }
}

// ViewModel receives Interactor
@Observable
@MainActor
final class CatListViewModel {
    @ObservationIgnored
    private let interactor: CatListInteractorProtocol

    init(interactor: CatListInteractorProtocol) {
        self.interactor = interactor
    }
}
```

### Testing with Spies

Always create Spy implementations for testing:

```swift
// Production
final class VotingInteractor: VotingInteractorProtocol { }

// Testing
final class SpyVotingInteractor: VotingInteractorProtocol {
    private(set) var saveVoteWasCalled = false
    var votesToReturn: [Vote] = []
}
```

## Key Patterns

### MARK Comment Order

Strictly follow this order:

1. `// MARK: - Private Properties`
2. `// MARK: - States` (@State, @Bindable, etc.)
3. `// MARK: - Bindings`
4. `// MARK: - Environment`
5. `// MARK: - Properties`
6. `// MARK: - Body`
7. `// MARK: - Initializers`
8. `// MARK: - Private Views`
9. `// MARK: - Private Functions`
10. `// MARK: - Functions`

### Test Structure

```swift
@Suite("Feature Name")
struct FeatureTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        // MARK: - Subject Under Test
        let spyInteractor = SpyInteractor()

        // MARK: - Tests
        @Test("Load data successfully")
        func loadDataSuccess() async { }
    }
}
```

## UIKit Integration Patterns

VoteHistory is implemented in UIKit using modern collection view APIs, wrapped for SwiftUI via `UIViewControllerRepresentable`.

### UIViewRepresentable Pattern

```swift
// SwiftUI wrapper for UIKit ViewController
struct VoteHistoryRepresentable: UIViewControllerRepresentable {
    let viewModel: VoteHistoryViewModel

    func makeUIViewController(context: Context) -> VoteHistoryViewController {
        VoteHistoryViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: VoteHistoryViewController, context: Context) {
        uiViewController.applySnapshot()
    }
}
```

### Modern UICollectionView Pattern (iOS 26+)

**Key principle**: DiffableDataSource stores **identifiers** (`Vote.ID`), not full model objects. The model itself doesn't need to be `Hashable` — only its `ID` does. This is more efficient and follows Apple's recommended approach.

```swift
// Use UICollectionViewCompositionalLayout for list layout
private func setupCollectionView() {
    var config = UICollectionLayoutListConfiguration(appearance: .plain)
    config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            self?.deleteVote(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    let layout = UICollectionViewCompositionalLayout.list(using: config)
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
}

// Use Vote.ID as item identifier type — NOT the full Vote model
private func setupDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<VoteCell, Vote.ID> { [weak self] cell, indexPath, voteID in
        // Look up the full model from the ViewModel using the identifier
        guard let vote = self?.viewModel.vote(for: voteID) else { return }
        cell.configure(with: vote)
    }

    dataSource = UICollectionViewDiffableDataSource<Section, Vote.ID>(
        collectionView: collectionView
    ) { collectionView, indexPath, voteID in
        collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: voteID
        )
    }
}

// Snapshots store identifiers, not full models
func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Vote.ID>()
    snapshot.appendSections([.main])
    snapshot.appendItems(viewModel.filteredVoteIDs)
    dataSource?.apply(snapshot, animatingDifferences: true)
}
```

**Why identifiers, not models?**
- `Vote.ID` (e.g., `UUID` or `String`) is naturally `Hashable`
- The `Vote` struct doesn't need `Hashable` conformance
- Identifiers are lightweight — snapshots are more performant
- The ViewModel owns the source of truth; the data source just references IDs

### UIKit View Initialization Rules

1. **Closure-based init**: All views initialized via closures (no `viewDidLoad` clutter)
2. **UIStackView preferred**: Use `UIStackView` over manual `NSLayoutConstraint` for layout simplicity
3. **Private scope**: All UIKit views declared as `private`
4. **No storyboards**: All UI done programmatically

```swift
final class VoteHistoryViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: VoteHistoryViewModel

    // MARK: - Private Views (closure-based)

    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()
}
```

## CatUI Package

**CatUI** is a **separate public GitHub repository** ([github.com/Eduardo0224/CatUI](https://github.com/Eduardo0224/CatUI)) that provides the design system. It is added as an SPM dependency in CatMatch.

### When to Use CatUI

| Component Type | Where to Put It |
|----------------|-----------------|
| Used in 2+ features | **CatUI package** |
| Feature-specific | Feature's `Views/Components/` |
| Business logic, ViewModels, Interactors | **Never** in CatUI |

### CatUI Components

- `CatCardView` - Card container with shadow and radius
- `CatBadgeView` - Badge with configurable style
- `CatImageView` - Async image with placeholder/shimmer
- `CatButton` + `CatButtonStyle` - Styled button (primary/secondary/ghost)
- `CatFloatingButton` - Circular floating action button
- `CatLoadingView` - Loading indicator
- `CatEmptyView` - Empty state with icon/text/action
- `CatErrorView` - Error state with retry
- `CatVoteCellConfiguration` - UIKit UIContentConfiguration for vote cells

### CatUI Design Tokens

```swift
import CatUI

// Colors
Color.catAccent
Color.catAccentSubtle
Color.catSurfacePrimary
Color.catSurfaceSecondary
Color.catTextPrimary
Color.catTextSecondary
Color.catTextOnAccent

// Spacing
CatSpacing.spacing4   // 4pt
CatSpacing.spacing8   // 8pt
CatSpacing.spacing12  // 12pt
CatSpacing.spacing16  // 16pt
CatSpacing.spacing24  // 24pt
CatSpacing.spacing32  // 32pt

// Radius
CatRadius.radius8
CatRadius.radius12
CatRadius.radius16

// Typography
Font.catDisplay
Font.catTitle
Font.catHeadline
Font.catBody
Font.catCaption

// Modifiers
.catCardStyle()
.shimmer()
.catSkeleton()
```

## TheCatAPI Notes

- **Base URL**: https://api.thecatapi.com/v1
- **Authentication**: API key via `x-api-key` header
- **Key Endpoints**:
  - `GET /breeds` - List cat breeds
  - `GET /breeds/search?q={query}` - Search breeds
  - `GET /images/search?breed_id={id}` - Get breed images
  - `GET /images/{id}` - Get specific image

### API Key in Requests

```swift
// Configure URLRequest with API key
var request = URLRequest(url: url)
request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
```
