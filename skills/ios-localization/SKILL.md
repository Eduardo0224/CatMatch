---
name: ios-localization
description: >-
  iOS localization with String Catalog (.xcstrings) and type-safe L10n enum pattern.
  Covers feature-based catalogs, pluralization, string interpolation, and SPM package
  localization. Use when adding localization, creating .xcstrings files, localizing UI
  strings, or user mentions "String Catalog", "xcstrings", "L10n", "localization",
  "pluralization", "Spanish", or "multi-language".
user-invocable: true
---

## Overview

Use String Catalog (`.xcstrings`) for all user-facing strings. Create type-safe access via a `L10n` enum with nested feature enums. Each feature gets its own `.xcstrings` file. Use `String(localized:table:)` with explicit table names for feature-specific strings. Keys follow `SCREAMING_SNAKE_CASE`.

## Instructions

1. **Create String Catalog** — Xcode → File → New → String Catalog → `[FeatureName].xcstrings` in `Resources/`
2. **Add languages** — select the catalog, Inspector → Localizations → click `+` to add Spanish
3. **Add keys** — use `SCREAMING_SNAKE_CASE` with context prefix: `FEATURE_CONTEXT_IDENTIFIER`
4. **Create L10n enum** — `enum L10n {}` with nested enums per feature, each with a `private static let table`
5. **Reference in Views** — use `L10n.Feature.Context.key` instead of hardcoded strings
6. **Add pluralization** — use `String(localized: "KEY \(count)", table: table)` with plural variations in the catalog

## Rules

### Key Naming

- Format: `FEATURE_CONTEXT_IDENTIFIER`
- Contexts: `SCREEN_`, `SECTION_`, `BUTTON_`, `LABEL_`, `PLACEHOLDER_`, `EMPTY_`, `ERROR_`, `ALERT_`, `A11Y_`, `COMMON_`
- Always uppercase with underscores — never camelCase, kebab-case, or PascalCase
- Example keys: `MOVIE_LIST_SCREEN_TITLE`, `SEARCH_PLACEHOLDER_SEARCH`, `COMMON_CANCEL`

### L10n Enum Structure

- Top-level `enum L10n {}` in `Core/Extensions/L10n.swift`
- Common strings in `L10n.Common` (uses default `Localizable.xcstrings`)
- Feature strings in `L10n.FeatureName` with `private static let table = "FeatureName"`
- Each feature enum has nested context enums: `Screen`, `Button`, `Label`, `Placeholder`, `Empty`, `Error`, `Alert`
- Pluralization functions: `static func itemCount(_ count: Int) -> String { String(localized: "ITEM_COUNT \(count)", table: table) }`
- Interpolation functions: `static func ratingValue(_ value: Double) -> String { String(localized: "RATING \(value)", table: table) }`

### App vs Package Localization

- **Main app**: uses default bundle, reference with `table: "FeatureName"`
- **Swift Package**: uses `bundle: #bundle` (no fallback needed — iOS 26 is the minimum)
- Package strings go in `Sources/[Package]/Resources/[Package].xcstrings`

### String Catalog Files

- `Localizable.xcstrings` — Common strings (OK, Cancel, Retry, generic errors)
- `[FeatureName].xcstrings` — One per feature with feature-specific keys
- Add all supported languages to each catalog
- Use the visual editor for plural variations and interpolation placeholders

### Pluralization

- Use string interpolation for the count: `String(localized: "KEY \(count)", table: table)`
- In the catalog, add variations: `zero`, `one`, `other` (English), `zero`, `one`, `other` (Spanish)
- For complex plurals, use positional format specifiers: `%1$@`, `%2$lld`

### Testing

- Add preview variants with `.environment(\.locale, Locale(identifier: "es"))`
- Test pseudo-localization in Xcode scheme: "Double-Length Pseudolanguage"
- Test VoiceOver with Accessibility Inspector

## Verification Checklist

- [ ] All user-facing strings use `L10n` — no hardcoded strings
- [ ] Keys follow `SCREAMING_SNAKE_CASE` convention
- [ ] Feature-specific strings use `table:` parameter
- [ ] Pluralization uses String Catalog plural variations (not manual if/else)
- [ ] Package strings use `bundle: #bundle` (no fallback needed, iOS 26 minimum)
- [ ] Separate `.xcstrings` per feature in `Resources/`
- [ ] Both English and Spanish entries exist for every key
- [ ] Previews test multiple locales
- [ ] Accessibility labels use `A11Y_` prefixed keys

## Common Mistakes

- **Hardcoded strings** → Every user-facing string must go through `L10n`
- **Missing `table:` parameter** → Feature-specific keys without `table:` resolve against `Localizable.xcstrings`
- **Missing `bundle:` in packages** → Package strings fail to resolve without explicit bundle
- **Inconsistent key naming** → Stick to `SCREAMING_SNAKE_CASE` — no mixing conventions
- **Manual pluralization** → Use String Catalog plurals instead of `count == 1 ? "singular" : "plural"`

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full L10n enum, String Catalog examples, pluralization, package localization
