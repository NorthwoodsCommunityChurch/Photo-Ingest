# Photo Ingest

A native macOS app for organizing photo transfers from a church photography team to centralized network storage.

<!-- ![Photo Ingest Screenshot](docs/images/screenshot.png) -->

## Features

- **3-step guided workflow** — enter event info, transfer files, review results
- **Drag-and-drop** — drop photos and folders directly into the app
- **Smart organization** — creates `Event / Date / Photographer` folder hierarchy automatically
- **Duplicate handling** — detects filename collisions and organizes into numbered upload folders
- **Autocomplete** — remembers past event names and photographer names
- **Date picker** — calendar dropdown pre-filled with today's date
- **Multiple photographers** — reuses existing event/date folders for the same event
- **Progress tracking** — real-time file count, byte totals, and current file display
- **Dark mode** — designed with a dark interface using Northwoods brand colors

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon (aarch64)

## Installation

1. Download the latest `.zip` from [Releases](../../releases)
2. Extract the zip file
3. Move **Photo Ingest.app** to your Applications folder (optional)
4. Right-click the app and select **Open** (required on first launch for ad-hoc signed apps)

## Usage

1. **Open Settings** (Cmd+,) and choose a destination folder — this is where all photos will be organized
2. **Fill in the event details:**
   - Event name (e.g., "Sunday Service", "Easter")
   - Photographer name
   - Date (defaults to today)
3. **Drop photos and folders** into the drop zone
4. Click **Start Transfer** — files are copied to: `[Destination]/[Event]/[YYYY-MM-DD]/[Photographer]/`
5. Review the summary and click **Ingest More Photos** for the next batch

Multiple photographers can ingest for the same event — the app reuses existing event and date folders.

## Building from Source

Requires [XcodeGen](https://github.com/yonaskolb/XcodeGen) and Xcode 16+.

```bash
# Generate Xcode project
xcodegen generate

# Build
xcodebuild -project PhotoIngest.xcodeproj -scheme PhotoIngest -configuration Release build

# Ad-hoc sign
codesign --force --deep --sign - "build/Build/Products/Release/Photo Ingest.app"
```

## Project Structure

```
Photo Ingest/
  project.yml                          # XcodeGen project specification
  PhotoIngest/
    App/
      PhotoIngestApp.swift             # App entry point and window configuration
      AppState.swift                   # Central observable state manager
    Models/
      TransferItem.swift               # File queued for transfer
      TransferResult.swift             # Transfer outcome and progress tracking
    Services/
      TransferService.swift            # File copy engine with collision detection
      HistoryService.swift             # UserDefaults persistence for autocomplete
    Views/
      ContentView.swift                # Wizard step router
      Step1EventInfoView.swift         # Event info form and drop zone
      Step2TransferProgressView.swift  # Transfer progress display
      Step3CompleteView.swift          # Completion summary
      SettingsView.swift               # Destination folder picker
      Theme.swift                      # Brand colors and design tokens
      Components/
        DropZoneView.swift             # Drag-and-drop file target
        AutocompleteTextField.swift    # Text field with suggestion dropdown
    Resources/
      Info.plist
      PhotoIngest.entitlements
      Assets.xcassets/
```

## License

[MIT License](LICENSE) — Copyright (c) 2026 Northwoods Community Church

## Credits

See [CREDITS.md](CREDITS.md) for third-party acknowledgments.
