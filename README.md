## Architecture
The project follows the **MVVM (Model-View-ViewModel)** architecture pattern.

## Features

### News Sources Screen
- Lists all English-language news sources from NewsAPI
- Displays source name and description
- Multi-category filtering (client-side)
- Categories are extracted from the sources list dynamically

### Articles Screen
- Displays articles from the selected news source
- Articles sorted by date (most recent first)
- Top 3 articles shown as an auto-sliding carousel (5-second interval)
- Reading list feature (add/remove articles stored in UserDefaults)
- Pull-to-refresh with error simulation (every 3rd request)
- Auto-refresh every 60 seconds

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+
- Portrait mode only
- Universal (iPhone + iPad)

## Setup

1. Clone the repository
2. Open `BoynerCaseApp.xcodeproj` in Xcode
3. Get a free API key from [NewsAPI](https://newsapi.org)
4. Open `Secrets.xcconfig` (in the project root) and replace `YOUR_API_KEY_HERE` with your actual API key:
   ```
   NEWS_API_KEY = abc123yourkey
   ```
5. Build and run

> **Note:** `Secrets.xcconfig` is included in `.gitignore` to prevent committing your API key to version control.

## Testing

Unit tests cover:
- **SourcesViewModel**: Source fetching, English language filtering, category extraction, multi-category filtering
- **ReadingListService**: Add, remove, duplicate prevention, persistence via UserDefaults
- **Article Model**: Date parsing, JSON decoding, equality checks

Run tests with `Cmd+U` in Xcode.

## Dependencies

No external dependencies. The project uses only Apple's native frameworks:
- SwiftUI
- Foundation
- Combine
