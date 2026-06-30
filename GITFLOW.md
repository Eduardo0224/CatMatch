# Git Workflow Strategy

This document defines the Git workflow and branching strategy for the CatMatch project.

## Overview

We follow a **simplified Gitflow** workflow optimized for a single developer with clear feature separation and professional commit history.

## Branch Structure

```
main (production-ready)
  ↑
develop (integration)
  ↑
feature/* (individual features)
```

### Branch Types

| Branch | Purpose | Lifetime | Protected |
|--------|---------|----------|-----------|
| `main` | Production-ready code, tagged releases | Permanent | ✅ Yes |
| `develop` | Integration branch for features | Permanent | ⚠️ Semi |
| `feature/*` | Individual feature development | Temporary | ❌ No |
| `release/*` | Release preparation (optional) | Temporary | ❌ No |
| `hotfix/*` | Emergency fixes for production | Temporary | ❌ No |

---

## Branch Naming Conventions

### Feature Branches
```
feature/<feature-name>
```

**Examples**:
- `feature/cat-list`
- `feature/cat-detail`
- `feature/voting`
- `feature/search`

### Release Branches (optional)
```
release/v<version>
```

**Examples**:
- `release/v1.0.0`
- `release/v2.0.0`

### Hotfix Branches
```
hotfix/<issue-description>
```

**Examples**:
- `hotfix/fix-pagination-crash`
- `hotfix/image-loading-memory-leak`

---

## Commit Message Format

All commits MUST follow this format (configured in `.gitmessage`):

```
[type](scope): emoji title_in_english

Detailed description of changes:
- What changed
- Why it changed
- Any breaking changes or important notes
```

### Commit Types

| Type | Usage | Emoji |
|------|-------|-------|
| `feat` | New feature | ✨ |
| `fix` | Bug fix | 🐛 |
| `docs` | Documentation changes | 📚 |
| `style` | Code style changes (formatting) | 🎨 |
| `refactor` | Code refactoring | ♻️ |
| `test` | Adding or updating tests | ✅ |
| `chore` | Build process, tools, config | 🔧 |
| `perf` | Performance improvements | ⚡️ |

### Commit Scopes

| Scope | Usage |
|-------|-------|
| `CatList` | CatList feature |
| `CatDetail` | CatDetail feature |
| `Voting` | Voting feature |
| `VoteHistory` | VoteHistory feature |
| `CatUI` | CatUI design system |
| `Core` | Core services/models |
| `Config` | Project configuration |
| `Network` | Networking layer |
| `Persistence` | Data persistence |

### Commit Examples

```bash
# Good commits
[feat](Voting): ✨ Add voting screen with like/dislike

Implemented breed voting with image display and local vote persistence.

- Added Vote model with SwiftData
- Created VotingInteractor to handle vote storage
- VotingViewModel tracks current breed and vote state

[fix](CatDetail): 🐛 Fix crash when cat has no image URL

Added nil check for image URL to prevent force unwrap crash.

[refactor](Core): ♻️ Extract network error handling to separate type

Created NetworkError enum to centralize error handling across all interactors.

[test](Voting): ✅ Add tests for voting CRUD operations

Added comprehensive test suite for:
- Liking a cat breed
- Disliking a cat breed
- Viewing vote history
```

---

## Development Workflow

### 1. Initial Setup (One-time)

```bash
# Create and push develop branch
git checkout -b develop
git push -u origin develop

# Set develop as default branch on GitHub (optional)
```

### 2. Starting a New Feature

```bash
# Ensure develop is up to date
git checkout develop
git pull origin develop

# Create feature branch from develop
git checkout -b feature/cat-list

# Push feature branch to remote
git push -u origin feature/cat-list
```

### 3. Working on a Feature

```bash
# Make changes and commit frequently
git add .
git commit -m "[feat](CatList): ✨ Add cat list models

Created models for CatBreed, CatImage, and Vote.
All models conform to Codable and Sendable protocols.
"

# Push to remote regularly
git push origin feature/cat-list
```

### 4. Completing a Feature

```bash
# Ensure all tests pass
xcodebuild test -project CatMatch.xcodeproj -scheme CatMatch -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Ensure feature branch is up to date with develop
git checkout develop
git pull origin develop
git checkout feature/cat-list
git merge develop

# Resolve any conflicts, test again

# Merge feature into develop (using --no-ff to preserve history)
git checkout develop
git merge --no-ff feature/cat-list

# Push develop
git push origin develop

# Delete feature branch (local and remote)
git branch -d feature/cat-list
git push origin --delete feature/cat-list
```

### 5. Creating a Release

```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# Bump version, update CHANGELOG.md, final testing
# Make any last-minute fixes

# Merge to main
git checkout main
git merge --no-ff release/v1.0.0

# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0 - MVP

Features:
- CatList with pagination and filters
- CatDetail view
- Voting functionality
- Local vote history
"

# Push main and tags
git push origin main
git push origin v1.0.0

# Merge back to develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# Delete release branch
git branch -d release/v1.0.0
```

### 6. Creating a Hotfix

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-pagination-crash

# Fix the issue
git commit -m "[fix](CatList): 🐛 Fix pagination crash

Fixed index out of bounds crash when loading last page.
Added bounds checking before accessing pagination metadata.
"

# Merge to main
git checkout main
git merge --no-ff hotfix/fix-pagination-crash

# Tag with patch version
git tag -a v1.0.1 -m "Hotfix v1.0.1 - Fix pagination crash"
git push origin main
git push origin v1.0.1

# Merge back to develop
git checkout develop
git merge --no-ff hotfix/fix-pagination-crash
git push origin develop

# Delete hotfix branch
git branch -d hotfix/fix-pagination-crash
```

---

## Versioning Strategy

We follow **Semantic Versioning** (semver): `MAJOR.MINOR.PATCH`

### Version Numbers

- **0.x.x**: Development phase (pre-release)
- **1.0.0**: MVP release (first stable version)
- **MAJOR**: Breaking changes, major new features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, minor improvements

### Version Examples

```
0.1.0 → Initial development
0.2.0 → CatList & CatDetail feature complete
0.3.0 → Voting feature complete
0.4.0 → VoteHistory feature complete
0.5.0 → CatUI design system package
0.9.0 → All MVP features complete, testing phase
1.0.0 → MVP Release 🎉
1.1.0 → Add accessibility & polish
1.2.0 → Add cloud sync (future)
2.0.0 → Major redesign (future)
```

---

## Git Tags

### Annotated Tags (Preferred)

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0 - MVP

Major Features:
- Cat browsing with pagination
- Advanced search and filters
- Collection management
- iPad support
- Spanish/English localization
"

# Push tag
git push origin v1.0.0

# Push all tags
git push origin --tags
```

### Listing Tags

```bash
# List all tags
git tag

# Show tag details
git show v1.0.0
```

### Deleting Tags

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

---

## Branch Protection Rules (GitHub)

### For `main` branch:
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass (tests)
- ✅ Require branches to be up to date
- ✅ Require conversation resolution before merging
- ✅ Do not allow force pushes
- ✅ Do not allow deletions

### For `develop` branch:
- ⚠️ Require pull request reviews (optional for solo dev)
- ✅ Require status checks to pass (tests)
- ⚠️ Allow force pushes (only by admins)
- ✅ Do not allow deletions

---

## Best Practices

### ✅ DO

- Commit frequently with clear messages
- Keep commits focused (one logical change per commit)
- Write descriptive commit messages
- Test before pushing
- Use feature branches for all features
- Delete branches after merging
- Tag all releases
- Keep `main` always deployable
- Update CHANGELOG.md with each release
- Use `--no-ff` for merges to preserve history

### ❌ DON'T

- Don't commit directly to `main`
- Don't force push to `main` (except for initial setup if needed)
- Don't commit broken code to `develop`
- Don't leave stale branches
- Don't use generic commit messages ("fix", "update", "changes")
- Don't commit secrets or sensitive data
- Don't commit large binary files

---

## Quick Reference

```bash
# Setup
git checkout -b develop
git push -u origin develop

# Start feature
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Work on feature
git add .
git commit -m "[feat](Scope): ✨ Description"
git push origin feature/my-feature

# Finish feature
git checkout develop
git merge --no-ff feature/my-feature
git push origin develop
git branch -d feature/my-feature
git push origin --delete feature/my-feature

# Release
git checkout -b release/v1.0.0
# ... final changes ...
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop
```

---

## Current Status

- ✅ `main` branch created and pushed
- ✅ `develop` branch created and pushed
- ✅ Commit template configured
- ✅ Initial commit with project setup
- ✅ Completed: `feature/cat-list` — CatList & CatDetail features
- ✅ Completed: `feature/voting` — Voting (SwiftUI) with like/dislike and SwiftData
- 🔄 Next: `feature/vote-history` — VoteHistory (UIKit) with UICollectionView modern APIs

---

## Integration with PROJECT_PLAN.md

This gitflow strategy is designed to work seamlessly with the feature development outlined in `PROJECT_PLAN.md`. Each feature in the roadmap should have its own feature branch following this workflow.
