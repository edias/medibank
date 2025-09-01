# Newsline - SwiftUI News Reader App

A modern iOS news reader app built with **SwiftUI**, **modular architecture**, and comprehensive **state management**. This implementation showcases clean code practices, reactive programming patterns, and a scalable design system.

## ✨ Features

### 🏠 **Headlines Tab**
- Browse latest articles from selected news sources  
- **State-driven UI** with loading, error, and empty states
- Rich article cards with thumbnails, titles, descriptions, and source badges
- Tap articles to read in integrated **WebView**
- **Save articles** for later reading with favorite button

### 🌐 **Sources Tab** 
- Discover and select from **150+ English news sources**
- Multi-selection with **persistent storage** across app launches
- Search and filter sources by category and country
- Clean tag-based UI with selection indicators

### ❤️ **Favorites Tab**
- View all saved articles with **swipe-to-delete** functionality
- **State management** with loading and empty states  
- Differentiated card design from Headlines
- Persistent storage with reactive updates

### 🎨 **Design System**
- **CommonUI** package with centralized design tokens
- Consistent spacing, colors, typography, and components
- **EmptyStateView** components for graceful error handling
- **ProgressView** loading indicators with branded styling

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+**
- **Swift 5.9+**
- **iOS 15.0+** deployment target

### ⚠️ **API Key Setup (Required)**

**Before running the project**, you must configure a valid NewsAPI key:

1. **Get a free API key** from [NewsAPI.org](https://newsapi.org/)
2. **Open `Debug.xcconfig`** in the project root
3. **Replace the placeholder** with your API key:
   ```
   API_KEY=your_actual_api_key_here
   ```

> **Note:** The app will not function without a valid API key. All network requests to NewsAPI require authentication.

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Medibank
   ```

2. **Configure API Key** (see above)

3. **Open in Xcode**
   ```bash
   open Newsline.xcodeproj
   ```

4. **Build and Run** (`⌘+R`)

---

## 🏗️ Architecture

### **Modular Design**
The app follows a **modular Swift Package Manager** architecture with clear separation of concerns:

```
Packages/
├── Core/                          # Core business logic
│   ├── Network/RestClient/        # HTTP networking layer  
│   └── Storage/                   # Data persistence & models
├── Features/                      # Feature modules
│   ├── Headlines/                 # Headlines tab functionality
│   ├── SourceSelection/          # Sources tab functionality  
│   └── Favorites/                # Favorites tab functionality
└── Share/                        # Shared utilities
    ├── CommonUI/                 # Design system & UI components
    └── CommonWeb/                # Shared WebView functionality
```

### **State Management Pattern**

Each feature implements a **state-driven architecture**:

```swift
enum ViewState {
    case loading
    case loaded([DataType])  
    case error(EmptyState)
    case empty(EmptyState)
}
```

**Benefits:**
- **Single source of truth** for UI state
- **Predictable state transitions**
- **Consistent loading and error handling**
- **Easy testing** with clear state boundaries

### **MVVM Architecture**
- **Views:** SwiftUI views with declarative UI
- **ViewModels:** `ObservableObject` classes managing business logic
- **Models:** Data structures and networking responses  
- **Services:** Network and storage layer abstractions

---

## 📦 Package Structure

### **Core Packages**

#### `RestClient`
- **Generic HTTP networking layer** with URLSession
- **Codable-based** request/response handling
- **Error handling** and network reliability

#### `Storage` 
- **ArticlesStorage:** Persistent favorites with Combine publishers
- **SelectionStorage:** Source selection persistence  
- **UserDefaults-based** with custom encoding

### **Feature Packages**

#### `Headlines`
- **HeadlinesView:** State-driven article list with loading/error/empty states
- **HeadlinesViewModel:** Network fetching, source filtering, state management
- **HeadlinesRowView:** Individual article cards with consistent styling

#### `SourceSelection` 
- **SourceSelectionView:** Multi-selection interface with search
- **SourceRowView:** Individual source cards with tags and selection state
- **ObservableSelectionStorage:** Reactive selection management

#### `Favorites`
- **FavoritesView:** Saved articles with swipe-to-delete
- **FavoritesViewModel:** Storage integration and state management  
- **FavoriteRowView:** Differentiated card design for favorites

### **Shared Packages**

#### `CommonUI`
**Centralized design system** for consistent UI:
- **DesignSystem:** Metrics, colors, typography scales
- **EmptyStateView:** Reusable empty/error state component
- **Constants:** Centralized spacing, corner radius, colors

#### `CommonWeb`
- **WebView integration** for article reading
- **FavoriteButton:** Save/unsave functionality
- **Navigation controls** and web state management

---

## 🎨 Design System

### **CommonUI Package**
Centralized design tokens ensure consistency across features:

```swift
// Usage throughout the app
DesignSystem.metrics.cardPadding        // 16pt
DesignSystem.colors.primary             // Brand blue  
DesignSystem.typography.headline        // Consistent font styles
```

### **Spacing Scale**
4-point grid system: `2, 4, 8, 12, 16, 24, 32pt`

### **Color Palette** 
- **Brand:** Primary blue, secondary purple
- **Semantic:** Success, warning, error states
- **System:** Background, text, placeholder colors

### **Typography**
- **Headlines:** `.title3`, `.headline` with consistent weights
- **Body:** `.body`, `.subheadline` for descriptions  
- **Metadata:** `.caption` for authors and sources

---

## 📱 User Experience

### **State Management**
- **Loading states** with branded progress indicators
- **Error handling** with actionable empty states  
- **Empty states** with helpful guidance messaging

### **Interaction Patterns**
- **Tap to read** articles in integrated WebView
- **Swipe to delete** saved articles
- **Multi-selection** for news sources
- **Pull to refresh** for updating content

### **Visual Design**
- **Card-based layouts** with consistent spacing
- **Subtle shadows** and rounded corners
- **Color-coded badges** for article sources
- **Responsive layouts** for different screen sizes

---

## 🛠️ Development

### **Code Style**
- **SwiftUI declarative patterns**
- **Combine reactive programming**
- **Protocol-oriented design**
- **Dependency injection** for testability

### **Key Patterns**
- **State-driven UI** with enum-based view states
- **Factory pattern** for EmptyState creation
- **Repository pattern** for data access
- **Observer pattern** with Combine publishers

### **Performance**
- **Async image loading** with placeholder states
- **Lazy loading** for large article lists
- **Memory management** with weak references
- **Network request cancellation** for view dismissal

---

## 📋 Requirements Fulfilled

✅ **TabView** with Headlines, Sources, and Favorites  
✅ **NewsAPI integration** with URLSession networking  
✅ **Article display** with title, description, author, thumbnail  
✅ **WebView integration** for article reading  
✅ **Save/delete functionality** for favorites  
✅ **Source selection** with multi-select and persistence  
✅ **Local storage** with UserDefaults-based persistence  
✅ **MVVM architecture** with ObservableObject ViewModels  
✅ **Empty state handling** for all scenarios  
✅ **Unit testing** for ViewModels and business logic  
✅ **Modular architecture** with Swift Package Manager  

---

## 🏆 Technical Highlights

- **100% SwiftUI** with no UIKit dependencies
- **Modular Swift Package Manager** architecture  
- **State-driven UI** with comprehensive error handling
- **Reactive programming** with Combine publishers
- **Centralized design system** for maintainable UI
- **Comprehensive unit testing** with mock implementations
- **Clean architecture** with clear separation of concerns

---

## 🤝 Contributing

This project demonstrates modern iOS development practices including:
- SwiftUI declarative UI patterns
- Combine reactive programming  
- Protocol-oriented design
- Modular architecture principles
- Comprehensive state management
- Design system implementation

---

## 📄 License

This project is part of a coding challenge and is for demonstration purposes.
