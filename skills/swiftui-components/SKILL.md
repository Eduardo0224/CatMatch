---
name: swiftui-components
description: >-
  Reusable SwiftUI component patterns: one component per file, @ViewBuilder usage,
  custom ViewModifiers, Liquid Glass (iOS 26), preview best practices, and stateless
  component design. Use when creating UI components, building a design system, adding
  previews, implementing iOS 26 glass effects, or user mentions "component", "ViewBuilder",
  "ViewModifier", "Liquid Glass", "reusable view", or "preview traits".
user-invocable: true
---

## Overview

Build reusable, stateless SwiftUI components. One component per file. Prefer stateless views that receive data via properties. Use `@ViewBuilder` for conditional composition. Use custom `ViewModifier` + `View` extension for reusable styling. Provide multiple preview variants per component.

## Instructions

1. **Create file** — one component per file in `Components/` folder
2. **Define properties** — data via `let` properties, callbacks via closures
3. **Build body** — use `@ViewBuilder` computed properties for conditional sections
4. **Add modifier extension** — if styling is reusable, create `ViewModifier` + `extension View`
5. **Write previews** — at least 3 variants: default, dark mode, and a state variant
6. **For Liquid Glass** — use `.glassEffect()` directly (no availability check needed, minimum deployment is iOS 26)

## Rules

### Component Design

- **One component per file** — never put multiple public components in one file
- **Stateless by default** — prefer `let` properties over `@State`; only add `@State` when the component genuinely owns ephemeral UI state
- **Closure callbacks** — use `var action: () -> Void` not delegates or bindings for single actions
- **No business logic** — components render data and report actions; never call APIs or interactors
- **Design system components** live in the SPM package; feature-specific components live in `Features/[Feature]/Views/Components/`

### @ViewBuilder Usage

- Use `@ViewBuilder` on computed properties that switch between states (loading/error/empty/data)
- Use `@ViewBuilder` in init for container components that accept child content
- Never put complex logic inside `@ViewBuilder` — just switch/if-else for view selection

### Custom ViewModifiers

- Create a `struct` conforming to `ViewModifier` with a `func body(content:) -> some View`
- Add an `extension View` with a function that calls `.modifier(YourModifier())`
- Name modifiers as nouns describing the result: `.cardStyle()`, `.shimmer()`, `.glassEffect()`

### Liquid Glass (iOS 26)

- **Only** for floating elements over dynamic content (FABs, overlays on images/video)
- **Never** on static backgrounds, list rows, or nested elements
- Use `.glassEffect()` directly — no `#available` guard needed (iOS 26 is the minimum deployment target)

### Preview Best Practices

- Use `.traits` for sizing: `.sizeThatFitsLayout`, `.fixedLayout(width:height:)`
- Use `@Previewable @State` for interactive state in previews
- Provide at least 3 variants: default, dark mode (`.preferredColorScheme(.dark)`), and edge case (empty, long text, error)
- Use Mock interactors for container previews that need data

### Sample Data

- Add static `sample` and `samples` properties in model extensions
- Keep sample data in the same file as the model (or in `Model+Samples.swift`)
- Sample data must match real data shape exactly — used by both previews and tests

## Verification Checklist

- [ ] One component per file
- [ ] Stateless when possible (data via `let` properties)
- [ ] `@ViewBuilder` for conditional views
- [ ] Custom ViewModifiers for reusable styling
- [ ] Liquid Glass only on floating elements over dynamic content
- [ ] No unnecessary `#available` guards — deployment target is iOS 26
- [ ] No nested Liquid Glass
- [ ] Previews with `.traits` sizing
- [ ] Multiple preview variants (default, dark, state)
- [ ] Sample data in model extensions
- [ ] Design system components in SPM package, feature components in feature folder

## Common Mistakes

- **Overusing Liquid Glass** → Use sparingly — only floating elements over dynamic backgrounds. List rows and static cards use solid colors.
- **Unnecessary `#available(iOS 26.0, *)` guard** → The deployment target IS iOS 26. Availability checks are dead code that suggests the developer doesn't know the project's minimum version.
- **Multiple components per file** → Each component gets its own file for discoverability.
- **Stateful when stateless works** → Remove `@State` if the component only displays data.
- **Single preview variant** → Add dark mode + edge case variants. Previews are documentation.

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full component implementations: AsyncImage, Badge, Card, EmptyState, Shimmer modifier, Glass modifier, preview patterns
