# CatMatch

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2026%2B-lightgrey.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Observation-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

**Cat breed voting and browsing app powered by TheCatAPI**

---

## 📖 Description

**CatMatch** is a native iOS app that lets users browse cat breeds and vote on their favorites. Powered by TheCatAPI, it offers a Tinder-style voting experience where users can like or dislike breeds and review their voting history.

### ✨ Features (Planned)

- 🐱 **Breed Voting**: Swipe-style like/dislike on cat breed images
- 📋 **Breed List**: Browse all cat breeds with search
- 🔍 **Breed Detail**: View detailed breed information
- 💾 **Local History**: Voting history persisted with SwiftData
- 🌐 **Spanish/English**: Full localization with String Catalog

---

## 🏗️ Architecture

CatMatch implements **Clean Architecture** with 4 layers:

```
┌─────────────────────────────────────────┐
│  Views (SwiftUI)                        │  ← UI, no business logic
├─────────────────────────────────────────┤
│  ViewModels (@Observable)               │  ← Presentation logic, state
├─────────────────────────────────────────┤
│  Interactors (Protocol-first)           │  ← Business logic, data access
├─────────────────────────────────────────┤
│  Models (Structs)                       │  ← Pure data, Codable/Sendable
└─────────────────────────────────────────┘
```

---

## 💻 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Swift** 6.0 | Language |
| **SwiftUI** | Declarative UI |
| **Observation** | Reactive state with `@Observable` |
| **SwiftData** | Local persistence |
| **URLSession** | Networking with async/await |
| **Swift Testing** | Modern test framework |
| **TheCatAPI** | Cat breed data |

---

## 📦 Installation

### Prerequisites

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

### Steps

1. **Clone the repository**

```bash
git clone <repo-url>
cd CatMatch
```

2. **Configure API Key**

```bash
cp Secrets.xcconfig.example Secrets.xcconfig
```

Edit `Secrets.xcconfig` and add your TheCatAPI key:
```
CATAPI_KEY = your-actual-api-key
```

> Get a free API key at https://thecatapi.com

3. **Open and run**

```bash
open CatMatch.xcodeproj
```

Press **⌘+R** to build and run.

---

## 🧪 Testing

```bash
# Run all tests
xcodebuild test -project CatMatch.xcodeproj \
  -scheme CatMatch \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## 🔗 Related Repos

- **CatUI** — Design system: [github.com/Eduardo0224/CatUI](https://github.com/Eduardo0224/CatUI)

## 👨‍💻 Author

**Eduardo Andrade** — [@Eduardo0224](https://github.com/Eduardo0224)

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

