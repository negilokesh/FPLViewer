# FPLViewer

A native iOS app to browse Premier League teams and their Fantasy Football squads.

## Screenshots

/Users/lokeshprofessional/Desktop/Simulator Screenshot - iPhone 17 Pro - 2026-10-03 at 19.29.18.png
/Users/lokeshprofessional/Desktop/Simulator Screenshot - iPhone 17 Pro - 2026-10-03 at 19.30.06.png
/Users/lokeshprofessional/Desktop/Simulator Screenshot - iPhone 17 Pro - 2026-10-03 at 19.30.16.png
/Users/lokeshprofessional/Desktop/Simulator Screenshot - iPhone 17 Pro - 2026-10-03 at 19.30.34.png


## How to Build & Run

1. Clone the repo
2. Open `FPLViewer.xcodeproj` in Xcode
3. Select iPhone simulator (iPhone 15 recommended)
4. Press `Cmd + R` to run

## Architecture

MVVM with UIKit. A 7-state `ViewState` enum drives all UI through Combine bindings.

## Tech Stack

- Swift + UIKit
- URLSession + Codable
- Swift Concurrency (async/await)
- Combine (ViewModel → View binding)
- FileManager (offline cache)

## States Handled

- Initial loading
- Success
- Error + retry
- Pull-to-refresh
- Refresh failure (existing data stays)
- Offline cache on relaunch

## Known Limitations

- No paid Apple Developer account — TestFlight not configured

## What I'd Improve With More Time

- Player detail screen
- Season stats charts
- Home screen widget