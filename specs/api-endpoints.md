# API Endpoints - TheCatAPI

## Base URL

```
https://api.thecatapi.com/v1
```

## Interactive Documentation

**API Docs**: [https://developers.thecatapi.com](https://developers.thecatapi.com)

**Swagger/OpenAPI**: [https://api.thecatapi.com/v1](https://api.thecatapi.com/v1) (browse with API key)

## Authentication

All requests require an API key passed via the `x-api-key` HTTP header.

```swift
var request = URLRequest(url: url)
request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
```

The API key is stored securely using `Secrets.xcconfig` (gitignored) and loaded at runtime:

```swift
let apiKey = Bundle.main.infoDictionary?["CATAPI_KEY"] as? String
```

> **Free tier**: Rate-limited. Get a key at https://thecatapi.com

---

## Endpoint Organization

```swift
// In CatMatch project: Core/Services/API.swift
enum API {
    static let baseURL = "https://api.thecatapi.com/v1"

    enum Endpoints {
        // MARK: - Breeds

        static let breeds = "/breeds"

        static func breedSearch(_ query: String) -> String {
            "/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        }

        static func breedByID(_ id: String) -> String {
            "/breeds/\(id)"
        }

        // MARK: - Images

        static let imagesSearch = "/images/search"

        static func imageSearch(breedIDs: String, limit: Int = 1) -> String {
            "/images/search?breed_ids=\(breedIDs)&limit=\(limit)"
        }

        static func imageByID(_ id: String) -> String {
            "/images/\(id)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
}
```

---

## Endpoints

### 1. Breeds

#### GET /breeds — List All Breeds

Returns all cat breeds.

```
GET https://api.thecatapi.com/v1/breeds
```

**Response**: `[CatBreed]`

```swift
struct CatBreed: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let description: String
    let temperament: String
    let origin: String
    let lifeSpan: String
    let weight: Weight
    let referenceImageID: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, temperament, origin
        case lifeSpan = "life_span"
        case weight
        case referenceImageID = "reference_image_id"
    }
}

struct Weight: Codable, Sendable {
    let imperial: String
    let metric: String
}
```

#### GET /breeds/search — Search Breeds

Search breeds by name fragment.

```
GET https://api.thecatapi.com/v1/breeds/search?q=siberian
```

**Query Parameters**:
| Param | Type | Description |
|-------|------|-------------|
| `q` | String | Search query (name fragment) |

**Response**: `[CatBreed]`

#### GET /breeds/{breed_id} — Get Single Breed

```
GET https://api.thecatapi.com/v1/breeds/beng
```

**Response**: `CatBreed`

---

### 2. Images

#### GET /images/search — Search Images

Get cat images, optionally filtered by breed.

```
GET https://api.thecatapi.com/v1/images/search?breed_ids=beng,abys&limit=5
```

**Query Parameters**:
| Param | Type | Description |
|-------|------|-------------|
| `breed_ids` | String | Filter by breed ID(s), comma-separated (optional) |
| `limit` | Int | Number of images (1-100, default 1) |
| `page` | Int | Page number for pagination (default 0) |
| `order` | String | `RANDOM`, `ASC`, `DESC` |
| `mime_types` | String | `jpg`, `png`, `gif` |
| `size` | String | `thumb`, `small`, `med`, `full` |
| `has_breeds` | Int | `1` = only images with breed data |
| `format` | String | `json` (default) or `src` (raw image URL) |

**Response**: `[CatImage]`

```swift
struct CatImage: Identifiable, Codable, Sendable {
    let id: String
    let url: URL
    let width: Int
    let height: Int
    let breeds: [CatBreed]?
}
```

#### GET /images/{id} — Get Image by ID

```
GET https://api.thecatapi.com/v1/images/abc123
```

**Response**: `CatImage`

---

## Network Service Pattern

```swift
// Core/Services/NetworkService.swift

final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared) {
        self.session = session

        guard let key = Bundle.main.infoDictionary?["CATAPI_KEY"] as? String else {
            fatalError("CATAPI_KEY not found in Info.plist. Configure Secrets.xcconfig.")
        }
        self.apiKey = key
    }

    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(string: "\(API.baseURL)\(endpoint)")
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

## Error Handling

```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case unauthorized
    case rateLimited

    var userMessage: String {
        switch self {
        case .invalidURL, .invalidResponse:
            return L10n.Error.generic
        case .httpError(let code):
            return code == 401 ? L10n.Error.unauthorized : L10n.Error.generic
        case .decodingError:
            return L10n.Error.generic
        case .unauthorized:
            return L10n.Error.unauthorized
        case .rateLimited:
            return L10n.Error.rateLimited
        }
    }
}
```

---

## Rate Limits

The free tier of TheCatAPI has rate limits. The app should:

1. Cache breed data locally (breeds rarely change)
2. Load images asynchronously with `AsyncImage` (automatic caching)
3. Handle `429 Too Many Requests` gracefully with user-friendly error
4. Consider prefetching only visible images

---

## Usage by Feature

| Feature | Endpoint(s) | Cache? |
|---------|-------------|--------|
| **CatList** | `GET /breeds`, `GET /images/search?breed_id=` | ✅ Breeds cached |
| **CatDetail** | `GET /breeds/:id` (from cached list) | ✅ From cache |
| **Voting** | `GET /breeds`, `GET /images/search?breed_id=&limit=1` | Breeds cached |
| **VoteHistory** | No API calls — SwiftData local | — |
