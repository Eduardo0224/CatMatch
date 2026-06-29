# Changelog

All notable changes to the CatMatch project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- CatUI v0.3.0 SPM dependency — design system package connected, ready for feature integration

### Planned for v1.0.0

- **CatList & CatDetail** (SwiftUI) - Browse breeds with search, tap for detail
- **Voting** (SwiftUI) - Tinder-style like/dislike on cat breeds
- **VoteHistory** (UIKit) - Vote history with UICollectionView modern APIs

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

- **0.2.0**: CatList & CatDetail (SwiftUI) - Breed browsing with search and detail
- **0.3.0**: Voting (SwiftUI) - Tinder-style like/dislike with SwiftData
- **0.4.0**: VoteHistory (UIKit) - UICollectionView + DiffableDataSource + CompositionalLayout
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
