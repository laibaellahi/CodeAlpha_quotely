# Quotely — Random Quote Generator
Quotely is a premium, modern, and production-ready Random Quote Generator application built using Flutter, Dart, Riverpod, and Clean Architecture. Designed to inspire users daily, it features offline-first local storage, responsive typography scaling, adaptive light/dark/system themes, and custom-tailored micro-animations.
---
## 🚀 Key Features
*   **Inspire Me & Gestures**: Instantly loads a random quote. Supports smooth horizontal swiping (left/right) to navigate quotes.
*   **13 Curated Categories**: Browse quotes spanning Motivation, Success, Happiness, Life, Love, Friendship, Leadership, Education, Programming, Business, Health, Stoicism, and Islamic Quotes.
*   **Quote of the Day**: Dedicated page providing a deterministic daily quote.
*   **Day Streak Tracker**: Encourages daily reading by tracking consecutive days of usage with local state.
*   **Robust Offline Support**: Loaded with a static database of 500+ curated quotes, meaning the app functions 100% offline without network lag.
*   **Search**: Seamless, real-time search across quote texts, authors, and categories.
*   **Local Favorites**: Mark quotes as favorites and persist them securely across app restarts.
*   **History**: Retain a rolling log of the last 20 viewed quotes.
*   **Sharing & Copying**: Quick tap copying to the clipboard with visual confirmation and native OS sheet sharing.
*   **Accessibility & Personalization**:
    *   Large, ergonomic touch targets.
    *   User-adjustable typography scaling (Small, Medium, Large, Extra Large).
    *   Theme customisation (System Default, Light, Dark).
    *   Responsive layouts optimized for landscape, portrait, and tablet devices.
---
## 🎨 Color Palette & Typography
*   **Primary (Indigo)**: `#4F46E5`
*   **Secondary (Teal)**: `#14B8A6`
*   **Background (Light/Dark)**: `#F8FAFC` / `#0F172A`
*   **Success (Green)**: `#10B981`
*   **Error/Accent (Red/Amber)**: `#EF4444` / `#F59E0B`
*   **Typography**:
    *   *Headings*: Playfair Display
    *   *Body*: Poppins (with Inter fallbacks)
---
## 🏗️ Architecture Overview
The codebase is built on **Clean Architecture** principles separated by logical feature folders, enforcing decoupling and modular testing.
```text
lib/
├── app/                  # Application Shell, routing & configuration
├── core/                 # Shared utilities, constants & app design system
│   ├── constants/        # Global colors, strings, static quote data
│   ├── theme/            # Light & Dark ThemeData configurations
│   └── widgets/          # Highly reusable widgets (QuoteCard, ActionBar)
├── data/                 # Data Layer: concrete repositories & data sources
│   ├── datasources/      # Local Storage Service (SharedPreferences + Hive)
│   └── repositories/     # Repository implementations
├── domain/               # Domain Layer: core business logic (Pure Dart)
│   ├── entities/         # Data structures (Quote, Category, HistoryEntry)
│   └── repositories/     # Abstract repository interfaces
└── features/             # Feature Modules (Screens & logic per tab/module)
    ├── categories/       # Category grid views & detailed filters
    ├── daily_quote/      # Today's quote page & streak logic
    ├── favorites/        # Favorited quote manager
    ├── history/          # Recently viewed list
    ├── home/             # Main dashboard
    ├── search/           # Real-time search screen
    └── settings/         # Theme toggles & font scaling adjustments
```
---
## 📦 Tech Stack & Packages
*   **State Management**: `flutter_riverpod` (v2) for reactive, clean, and testable state separation.
*   **Local Databases**: `hive_flutter` for lightweight persistent objects and `shared_preferences` for quick key-value config keys.
*   **Typography**: `google_fonts` for loading Playfair Display and Poppins dynamically with local asset fallbacks.
*   **Animations**: `flutter_animate` for high-performance fade, slide, and scale transitions.
*   **Share Engine**: `share_plus` for native mobile share sheets.
*   **Local Notifications**: `flutter_local_notifications` for scheduled quote notifications.
---
## ⚙️ Getting Started
### Prerequisites
*   Flutter SDK (v3.0.0 or later) installed and configured on your system path.
*   An Android or iOS emulator/physical device connected.
### Build and Run
1.  **Clone the repository**:
    ```bash
    cd quote_app
    ```
2.  **Fetch Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run static checks**:
    ```bash
    flutter analyze
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```