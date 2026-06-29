# iOS Localization — Full Code Examples

## L10n Enum Structure

```swift
// Core/Extensions/L10n.swift

enum L10n {

    // MARK: - Common (Localizable.xcstrings)

    enum Common {
        static let ok = String(localized: "COMMON_OK")
        static let cancel = String(localized: "COMMON_CANCEL")
        static let save = String(localized: "COMMON_SAVE")
        static let delete = String(localized: "COMMON_DELETE")
        static let edit = String(localized: "COMMON_EDIT")
        static let done = String(localized: "COMMON_DONE")
        static let retry = String(localized: "COMMON_RETRY")
        static let loading = String(localized: "COMMON_LOADING")
    }

    // MARK: - Errors (Localizable.xcstrings)

    enum Error {
        static let title = String(localized: "ERROR_TITLE")
        static let generic = String(localized: "ERROR_GENERIC")
        static let network = String(localized: "ERROR_NETWORK")
        static let notFound = String(localized: "ERROR_NOT_FOUND")
    }

    // MARK: - Movie List (MovieList.xcstrings)

    enum MovieList {
        private static let table = "MovieList"

        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }

        enum Section {
            static let featured = String(localized: "SECTION_FEATURED", table: table)
            static let recent = String(localized: "SECTION_RECENT", table: table)
        }

        enum Placeholder {
            static let search = String(localized: "PLACEHOLDER_SEARCH", table: table)
        }

        enum Empty {
            static let title = String(localized: "EMPTY_TITLE", table: table)
            static let subtitle = String(localized: "EMPTY_SUBTITLE", table: table)
        }

        static func movieCount(_ count: Int) -> String {
            String(localized: "MOVIE_COUNT \(count)", table: table)
        }
    }

    // MARK: - Movie Detail (MovieDetail.xcstrings)

    enum MovieDetail {
        private static let table = "MovieDetail"

        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }

        enum Label {
            static let director = String(localized: "LABEL_DIRECTOR", table: table)
            static let releaseDate = String(localized: "LABEL_RELEASE_DATE", table: table)
            static let rating = String(localized: "LABEL_RATING", table: table)
        }

        enum Button {
            static let addFavorite = String(localized: "BUTTON_ADD_FAVORITE", table: table)
            static let removeFavorite = String(localized: "BUTTON_REMOVE_FAVORITE", table: table)
        }

        enum Alert {
            static let deleteTitle = String(localized: "ALERT_DELETE_TITLE", table: table)
            static let deleteMessage = String(localized: "ALERT_DELETE_MESSAGE", table: table)
        }

        static func ratingValue(_ rating: Double) -> String {
            String(localized: "RATING_VALUE \(rating)", table: table)
        }
    }
}
```

## Usage in Views

```swift
struct MovieListView: View {
    @State private var viewModel: MovieListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10n.MovieList.Screen.title)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: L10n.MovieList.Placeholder.search
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading: ProgressView()
        case .empty:
            EmptyView(
                title: L10n.MovieList.Empty.title,
                subtitle: L10n.MovieList.Empty.subtitle
            )
        case .loaded: movieList
        }
    }

    private var countLabel: some View {
        Text(L10n.MovieList.movieCount(viewModel.movies.count))
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

## Alert Usage

```swift
.alert(
    L10n.MovieDetail.Alert.deleteTitle,
    isPresented: $showingDeleteAlert
) {
    Button(L10n.Common.cancel, role: .cancel) { }
    Button(L10n.Common.delete, role: .destructive) { viewModel.delete() }
} message: {
    Text(L10n.MovieDetail.Alert.deleteMessage)
}
```

## String Catalog Examples

### Localizable.xcstrings (Common)

```
COMMON_OK        → English: "OK"         | Spanish: "Aceptar"
COMMON_CANCEL    → English: "Cancel"     | Spanish: "Cancelar"
COMMON_SAVE      → English: "Save"       | Spanish: "Guardar"
COMMON_RETRY     → English: "Retry"      | Spanish: "Reintentar"
ERROR_TITLE      → English: "Error"      | Spanish: "Error"
ERROR_GENERIC    → English: "Something went wrong"  | Spanish: "Algo salió mal"
ERROR_NETWORK    → English: "No internet connection" | Spanish: "Sin conexión"
```

### MovieList.xcstrings

```
SCREEN_TITLE         → English: "Movies"     | Spanish: "Películas"
SECTION_FEATURED     → English: "Featured"   | Spanish: "Destacadas"
PLACEHOLDER_SEARCH   → English: "Search..."  | Spanish: "Buscar..."
EMPTY_TITLE          → English: "No movies"  | Spanish: "Sin películas"
MOVIE_COUNT %lld     → zero: "No movies" | one: "1 movie" | other: "%lld movies"
                       zero: "Sin películas" | one: "1 película" | other: "%lld películas"
```

## SPM Package Localization

```swift
public enum MyUIL10n {
    private static let table = "MyUI"

    public enum Loading {
        public static let message = String(
            localized: "LOADING_MESSAGE",
            table: table,
            bundle: #bundle
        )
    }
}
```

## Localized Previews

```swift
#Preview("English") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Spanish") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "es"))
}
```
