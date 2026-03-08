# Meal Prep

An iOS app for importing recipes by URL from any cooking website, managing your weekly meal plan, and generating a smart shopping list.

## Features

- **Import recipes** from any cooking website by pasting a URL or sharing directly from Safari
- **Recipe library** with search, sort, and filter by cook time
- **Shopping list** automatically generated from selected recipes, with department grouping (Produce, Meat & Seafood, Dairy, etc.)
- **Custom ingredients** — add your own items to the shopping list
- **Manage recipes** — add or remove recipes from the shopping list without leaving the tab
- **Weekly planner** — assign recipes to days of the week and reorder them
- **Share Extension** — share any recipe URL directly into the app from Safari or other apps

## Requirements

- iOS 17+
- Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) 2.x

## Setup

1. Clone the repo
2. Install xcodegen if needed:
   ```bash
   brew install xcodegen
   ```
3. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
4. Open `MealPrep.xcodeproj` in Xcode
5. Set your development team in the project settings for both the `MealPrep` and `MealPrepShareExtension` targets
6. Register the App Group `group.com.miguelsolorio.mealprep` in your Apple Developer account and add it to both App IDs
7. Optionally add a browser cookie in **Settings** to access recipes on paywalled sites

## Project Structure

```
MealPrep/
├── App/                    # App entry point, ContentView
├── Models/                 # Recipe (SwiftData), GroceryDepartment, RecipeFilter
├── Networking/             # RecipeScraper, HTMLParser
├── Store/                  # RecipeStore (ObservableObject)
├── Utilities/              # ISO8601DurationParser, UserDefaultsKeys
└── Views/
    ├── Library/            # Recipe grid, list, detail
    ├── Import/             # URL import sheet
    ├── ShoppingList/       # Shopping list, manage recipes
    ├── Settings/           # Cookie configuration
    └── Components/         # Shared UI components
MealPrepShareExtension/     # iOS Share Extension
```

## Tech Stack

- **SwiftUI** — UI
- **SwiftData** — Recipe persistence
- **Swift 6** — Strict concurrency
- **xcodegen** — Project file generation
