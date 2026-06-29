# CatMatch - Project Overview

## Project Description

**CatMatch** is a native iOS app that lets users browse cat breeds and vote on their favorites. Powered by **TheCatAPI**, it offers a Tinder-style voting experience where users can like or dislike breeds and review their voting history.

## Project Goals

- **Primary**: Deliver a functional MVP (v1.0.0) with voting, breed browsing, and vote history
- **Secondary**: Demonstrate senior iOS skills — SwiftUI + UIKit integration, Clean Architecture, SPM modularization
- **Technical**: Showcase professional patterns: protocol-first DI, Swift Testing, String Catalog localization

## Technology Stack

| Technology | Framework | Purpose |
|------------|-----------|---------|
| **Language** | Swift 6 | Primary development language |
| **UI Framework** | SwiftUI (80%) + UIKit (20%) | Declarative UI + imperative integration |
| **Target** | iOS 26 | iPhone |
| **Architecture** | Clean Architecture (4 layers) | Models → Interactors → ViewModels → Views |
| **Persistence** | SwiftData | Local vote storage |
| **Networking** | URLSession + async/await | Async networking with structured concurrency |
| **Testing** | Swift Testing (unit) + XCTest (UI) | Modern testing with Spy pattern |
| **Design System** | CatUI Swift Package | Reusable components and design tokens |
| **Localization** | String Catalog (.xcstrings) | Spanish & English |
| **Git Workflow** | Gitflow (simplified) | develop, feature/*, release/*, main |

## Core Features (v1.0.0 - MVP)

### 1. CatList & CatDetail (SwiftUI)
**Browse cat breeds with search and detail**

- Search breeds by name
- Adaptive layout with breed images
- Detail view: description, temperament, origin, life span, weight
- Skeleton loading with shimmer effect
- Error handling with retry

**Framework**: SwiftUI | **Files**: `Features/CatList/`, `Features/CatDetail/`

### 2. Voting (SwiftUI)
**Tinder-style like/dislike on cat breeds**

- Card-style UI with breed image and name
- Like and dislike buttons
- Smooth transitions between votes
- Votes persisted via SwiftData

**Framework**: SwiftUI | **Files**: `Features/Voting/`

### 3. VoteHistory (UIKit)
**Vote history with modern collection view**

- `UICollectionViewCompositionalLayout.list` for layout
- `UICollectionViewDiffableDataSource` with `Vote.ID` identifiers
- `UIStackView` for layout (minimal constraints)
- Closure-based view initialization (private)
- Swipe-to-delete
- Filter by vote type (All / Likes / Dislikes)
- Wrapped for SwiftUI via `UIViewControllerRepresentable`

**Framework**: UIKit | **Files**: `Features/VoteHistory/`

### 4. CatUI Design System (SPM Package)
**Reusable UI components and design tokens**

- Components: CatCardView, CatBadgeView, CatImageView, CatButton, CatLoadingView, CatEmptyView, CatErrorView
- Tokens: CatColors, CatSpacing, CatRadius, CatTypography
- Modifiers: `.catCardStyle()`, `.catShimmer()`

**Package**: `CatUI/` | **Reference**: `specs/cat-ui-design-system.md`

## SwiftUI / UIKit Split

```
┌──────────────────────────────────────────────┐
│  SwiftUI (80%)           │  UIKit (20%)       │
│                           │                    │
│  • VotingView             │  • VoteHistory     │
│  • CatListView            │    - ViewController│
│  • CatDetailView          │    - CollectionView│
│  • Search                 │    - DiffableData  │
│  • TabView navigation     │    - Compositional │
│  • All ViewModels         │    - UIViewRep     │
│  • All Interactors        │                    │
└──────────────────────────────────────────────┘
```

## Architecture

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

### Key Patterns

- **Dependency Injection**: Protocol-first with default parameter values
- **@Observable + @State**: Modern Observation framework (iOS 17+)
- **UIKit integration**: `UIViewControllerRepresentable` with shared `@Observable` ViewModel
- **Async/await**: Structured concurrency for all async operations
- **SwiftData**: Local persistence for voting history
- **Spy pattern**: Testable components with tracking
- **CatUI**: Reusable design system as SPM package

## External Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| **TheCatAPI** | REST API | Cat breed data and images |
| **CatUI** | SPM (local) | Design system package |

## API

- **Base URL**: https://api.thecatapi.com/v1
- **Auth**: API key via `x-api-key` header
- **Full reference**: `specs/api-endpoints.md`

## Platform Support

| Platform | Version | Status |
|----------|---------|--------|
| **iOS** | 26+ | ✅ v1.0.0 target |
| **iPadOS** | 26+ | 🔮 Post-v1.0.0 (planned) |

## Current Status

- ✅ Project scaffolded (Xcode project, Clean Architecture structure)
- ✅ Skills (5 reusable iOS patterns)
- ✅ Specs (project-specific documentation)
- ✅ GITFLOW.md, CLAUDE.md, README.md, CHANGELOG.md
- ✅ Secrets.xcconfig security setup
- 🔄 Next: Start CatList feature development (v0.2.0)
