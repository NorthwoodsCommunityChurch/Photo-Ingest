# Photo Ingest

## Project Overview
Native macOS SwiftUI app (macOS 14+) for ingesting photos from a church photography team to centralized network storage. Non-sandboxed, ad-hoc signed, Hardened Runtime enabled.

## Build
```bash
xcodegen generate
xcodebuild -project PhotoIngest.xcodeproj -scheme PhotoIngest -configuration Release -derivedDataPath ./build build
codesign --force --deep --sign - "build/Build/Products/Release/Photo Ingest.app"
```

## Architecture
- **@Observable** state management (not ObservableObject) — `AppState.swift` is the central state
- **@AppStorage cannot be used inside @Observable** — use `@ObservationIgnored` + direct `UserDefaults` instead
- **XcodeGen** generates `.xcodeproj` from `project.yml` — never edit the xcodeproj directly
- **Theme.swift** holds all brand colors and design tokens — Northwoods brand blue `#02528A`
- **TransferService** handles file copying with path sanitization and collision detection
- **HistoryService** persists autocomplete data in UserDefaults

## Key Patterns
- Wizard flow controlled by `WizardStep` enum in `AppState.currentStep`
- File drop uses `.onDrop(of: [.fileURL])` with `NSItemProvider` loading
- Autocomplete uses a custom `AutocompleteTextField` with filtered overlay suggestions
- Filename collision creates `Upload N` subfolders (entire batch, not individual files)
- Path components are sanitized to strip `/`, `:`, null bytes before creating directories

## Brand
- Primary blue: `#02528A` (RGB 2, 82, 138)
- UI accent (brightened for dark mode): `#0D6EBA`
- Dark mode enforced via `.preferredColorScheme(.dark)`
- App icon: White Northwoods symbol on brand blue background
- Brand assets in `- BRAND/` folder (gitignored, not committed)
