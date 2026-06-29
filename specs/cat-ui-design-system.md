# CatUI Design System

## Overview

**CatUI** is a **separate public GitHub repository** ([github.com/Eduardo0224/CatUI](https://github.com/Eduardo0224/CatUI)) that provides the design system for CatMatch — reusable UI components, design tokens, and view modifiers. It contains **zero business logic** — only visual elements. Added as an SPM dependency.

**Related Documentation:**
- Generic UI patterns: `skills/swiftui-components/SKILL.md`
- Architecture: `specs/architecture-reference.md`
- Localization: `skills/ios-localization/SKILL.md`

---

## Design Philosophy

Create a warm, playful interface inspired by cats while maintaining iOS platform conventions. Prioritize **clarity**, **warmth**, and **visual hierarchy**.

**Key Principles:**
- Cat imagery as primary visual element (breed photos)
- Warm, inviting color palette (rose accent inspired by Dribbble — Pet Marketplace)
- Generous whitespace for breathing room
- Clear typographic hierarchy with Coolvetica font family
- Intentional use of accent color
- Accessibility-first: VoiceOver labels, Dynamic Type

---

## Color Palette

Inspired by [Dribbble — Pet Marketplace](https://dribbble.com/shots/25955678-Pet-Marketplace-App-Mobile-Design).

### Design Tokens (in CatUI: `Tokens/CatColors.swift`)

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `.catAccent` | `#E22E57` | `#E22E57` | Primary buttons, like action |
| `.catAccentSubtle` | `#FFCEDE` | `#3D202B` | Badge backgrounds, highlights |
| `.catSurfacePrimary` | `#FFFFFF` | `#191617` | Screen backgrounds |
| `.catSurfaceSecondary` | `#FFF5F0` | `#2A2426` | Cards, elevated surfaces |
| `.catTextPrimary` | `#191617` | `#FFFFFF` | Headlines, body text |
| `.catTextSecondary` | `#6B5B5E` | `#B0A0A5` | Metadata, captions |
| `.catTextOnAccent` | `#FFFFFF` | `#FFFFFF` | Text over accent |

> **Accent**: `#E22E57` — a warm rose/red that is energetic and playful, fitting the cat theme.

### UIKit Bridge (in CatUI: `Tokens/CatUIColor+Tokens.swift`)

```swift
// UIKit colors (trait-collected for light/dark mode)
UIColor.catAccent
UIColor.catAccentSubtle
UIColor.catSurfacePrimary
UIColor.catSurfaceSecondary
UIColor.catTextPrimary
UIColor.catTextSecondary
UIColor.catTextOnAccent
```

### Color Usage Guidelines

| Element | Token | Example |
|---------|-------|---------|
| Primary button | `.catAccent` | Like/Dislike buttons |
| Accent background | `.catAccentSubtle` | Vote type badge, highlights |
| Card backgrounds | `.catSurfaceSecondary` | VoteCardView, CatRowView |
| Screen background | `.catSurfacePrimary` | ScrollView backgrounds |
| Main titles | `.catTextPrimary` | Breed names, screen titles |
| Supporting info | `.catTextSecondary` | Temperament, origin labels |
| Text on accent | `.catTextOnAccent` | Button labels |

---

## CatUI Package Structure

```
CatUI/
├── Package.swift
├── Sources/
│   └── CatUI/
│       ├── Tokens/
│       │   ├── CatColors.swift            ← Color tokens (light/dark)
│       │   ├── CatSpacing.swift           ← Spacing scale (4–32pt)
│       │   ├── CatRadius.swift            ← Corner radius scale (8–16pt)
│       │   ├── CatTypography.swift        ← Font tokens (Coolvetica + Dynamic Type)
│       │   ├── CatFontRegistration.swift  ← Coolvetica font registration
│       │   └── CatUIColor+Tokens.swift    ← UIKit color bridge
│       ├── Components/
│       │   ├── CatCardView.swift          ← Card container with shadow
│       │   ├── CatBadgeView.swift         ← Status badge (default/accent/outlined)
│       │   ├── CatImageView.swift         ← Async image with placeholder + shimmer
│       │   ├── CatButtonStyle.swift       ← ButtonStyle (primary/secondary/ghost)
│       │   ├── CatButton.swift            ← Convenience Button wrapper
│       │   ├── CatFloatingButton.swift    ← Circular floating action button
│       │   ├── CatLoadingView.swift       ← Loading indicator
│       │   ├── CatEmptyView.swift         ← Empty state
│       │   ├── CatErrorView.swift         ← Error state with retry
│       │   ├── CatVoteCellConfiguration.swift ← UIKit UIContentConfiguration for vote cells
│       │   └── CatUIPreview.swift         ← Reusable #Preview trait
│       ├── Modifiers/
│       │   ├── View+CatCard.swift         ← .catCardStyle()
│       │   ├── View+CatShimmer.swift      ← .shimmer() (ShimmerModifier)
│       │   └── View+CatSkeleton.swift     ← .catSkeleton() (redacted + shimmer + disabled)
│       └── Resources/
│           └── Fonts/
│               ├── Coolvetica-Regular.otf
│               ├── Coolvetica-Italic.otf
│               └── Coolvetica-HeavyComp.otf
└── Tests/
    └── CatUITests/
```

### Package.swift

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CatUI",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "CatUI", targets: ["CatUI"])
    ],
    targets: [
        .target(
            name: "CatUI",
            resources: [.process("Resources/Fonts")]
        ),
        .testTarget(name: "CatUITests", dependencies: ["CatUI"])
    ]
)
```

---

## Design Tokens

### Spacing Scale

```swift
// In CatUI: Tokens/CatSpacing.swift
public enum CatSpacing {
    public static let spacing4: CGFloat = 4
    public static let spacing8: CGFloat = 8
    public static let spacing12: CGFloat = 12
    public static let spacing16: CGFloat = 16
    public static let spacing24: CGFloat = 24
    public static let spacing32: CGFloat = 32
}
```

### Corner Radius

```swift
// In CatUI: Tokens/CatRadius.swift
public enum CatRadius {
    public static let radius8: CGFloat = 8
    public static let radius12: CGFloat = 12
    public static let radius16: CGFloat = 16
}
```

### Typography

```swift
// In CatUI: Tokens/CatTypography.swift
// Uses Coolvetica font family with Dynamic Type scaling

extension Font {
    /// Large breed name — Display style
    static let catDisplay = CatFontRegistration.display

    /// Screen titles — Title style
    static let catTitle = Font.system(.title, weight: .bold)

    /// Section headers — Headline style
    static let catHeadline = Font.system(.headline, weight: .semibold)

    /// Body text (descriptions)
    static let catBody = Font.system(.body)

    /// Supporting info (metadata, labels)
    static let catCaption = Font.system(.caption)
}
```

---

## Component Catalog

### CatCardView

Card container with shadow, radius, and surface background. Use as a container — it already has card styling built in.

```swift
public struct CatCardView<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(CatSpacing.spacing16)
            .background(Color.catSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius12))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
```

### CatImageView

Async image loader with placeholder, shimmer, and error states.

```swift
public struct CatImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = CatRadius.radius12

    public init(url: URL?, cornerRadius: CGFloat = CatRadius.radius12) {
        self.url = url
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder.shimmer()
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                placeholder.overlay {
                    Image(systemName: "cat").foregroundStyle(.secondary)
                }
            @unknown default:
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        Rectangle().fill(Color.catSurfaceSecondary)
    }
}
```

### CatButtonStyle

ButtonStyle with primary, secondary, and ghost variants.

```swift
public struct CatButtonStyle: ButtonStyle {
    public enum Variant {
        case primary, secondary, ghost
    }

    let variant: Variant

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.catHeadline)
            .padding(.horizontal, CatSpacing.spacing24)
            .padding(.vertical, CatSpacing.spacing12)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius12))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: .catTextOnAccent
        case .secondary: .catTextPrimary
        case .ghost: .catAccent
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: .catAccent
        case .secondary: .catSurfaceSecondary
        case .ghost: .clear
        }
    }
}
```

### CatButton

Convenience component wrapping `Button` with `CatButtonStyle`.

```swift
public struct CatButton: View {
    let title: String
    let variant: CatButtonStyle.Variant
    let action: () -> Void

    public init(_ title: String, variant: CatButtonStyle.Variant = .primary, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
        }
        .catButtonStyle(variant: variant)
    }
}
```

### CatFloatingButton

Circular floating button with like/dislike/share variants.

```swift
public struct CatFloatingButton: View {
    public enum Action {
        case like, dislike, share
    }

    let action: Action
    let onTap: () -> Void

    public init(action: Action, onTap: @escaping () -> Void) {
        self.action = action
        self.onTap = onTap
    }

    // Renders a circular button with SF Symbol icon
    // Like → heart.fill, Dislike → xmark, Share → square.and.arrow.up
}
```

### CatBadgeView

Small badge for status labels (temperament traits, origin).

```swift
public struct CatBadgeView: View {
    let text: String
    var style: Style = .default

    public enum Style {
        case `default`, accent, outlined
    }
}
```

### CatVoteCellConfiguration (UIKit)

UIKit `UIContentConfiguration` for vote history cells. Used with `UICollectionViewDiffableDataSource`.

```swift
public struct CatVoteCellConfiguration: UIContentConfiguration {
    let breedName: String
    let voteType: String
    let date: String
    let imageURL: URL?

    public init(breedName: String, voteType: String, date: String, imageURL: URL?)
}
```

### CatLoadingView, CatEmptyView, CatErrorView

Standard state views following the patterns documented in `skills/swiftui-components/SKILL.md`.

---

## View Modifiers

### .catCardStyle()

Apply card appearance (padding, background, radius, shadow) to any view. **Do NOT use on `CatCardView`** — it already has card styling built in.

```swift
extension View {
    public func catCardStyle() -> some View {
        self
            .padding(CatSpacing.spacing16)
            .background(Color.catSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius12))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
```

### .shimmer()

Gradient shimmer animation for loading placeholders. Defined by `ShimmerModifier`. Apply only to individual shapes (text, rectangles), **never** to scrollable containers (ScrollView, List).

```swift
extension View {
    public func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}
```

**Shimmer animation parameters:**
- Phase: `-1 → 1.5`
- Duration: `1.2s`
- Opacity: `0.35`
- Respects `@Environment(\.accessibilityReduceMotion)`

### .catSkeleton()

Combines `.redacted(.placeholder)` + `.shimmer()` + `.disabled(true)`. Defined by `CatSkeletonModifier`. Apply only to individual shapes, **never** to scrollable containers.

```swift
extension View {
    public func catSkeleton() -> some View {
        self.modifier(CatSkeletonModifier())
    }
}
```

---

## When to Use CatUI vs Feature Components

| Component Type | Where | Example |
|----------------|-------|---------|
| Used in 2+ features | **CatUI package** | CatCardView, CatButton |
| Feature-specific | Feature's `Views/Components/` | VoteCardView (specific to Voting) |
| Business logic | **Never** in CatUI | ViewModels, Interactors |

---

## Accessibility

All CatUI components must support:
- **VoiceOver**: Meaningful accessibility labels
- **Dynamic Type**: Use `.font(.catBody)` tokens (scaled automatically)
- **High Contrast**: Ensure text/background contrast ratios
- **Reduce Motion**: Respect `@Environment(\.accessibilityReduceMotion)` (shimmer disabled when enabled)

---

## Integration

CatUI v0.3.0 is a **separate public GitHub repository**. Add it as a remote SPM dependency:

```swift
// In Xcode: File → Add Package Dependencies
// URL: https://github.com/Eduardo0224/CatUI
// Version: 0.3.0

// Import in any file
import CatUI

// Use tokens
Text(breed.name).foregroundStyle(Color.catTextPrimary)

// Use components — CatCardView already has card styling built in
// Do NOT apply .catCardStyle() on top.
CatCardView {
    CatImageView(url: breed.imageURL)
    Text(breed.name).font(.catTitle)
}

// Use .catCardStyle() on non-CatCardView containers that need card appearance
VStack { ... }
    .catCardStyle()

// Use shimmer for loading placeholders
Rectangle()
    .fill(Color.catSurfaceSecondary)
    .shimmer()

// Use skeleton for full-component loading state
MyCard()
    .catSkeleton()
```
