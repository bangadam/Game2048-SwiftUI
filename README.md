# 2048 Game for iOS

A modern, feature-rich implementation of the classic 2048 puzzle game built with SwiftUI.

## Features

### Game Modes
- **Classic** - Reach the target tile value to win
- **Timed** - Beat the clock with a 2-minute countdown
- **Limited Moves** - Complete the game within 50 moves
- **Zen** - Relaxed mode with no win/lose conditions

### Customization
- **Board Sizes** - Choose from 3x3, 4x4, 5x5, or 6x6 grids
- **Difficulty Levels** - Easy (95% 2s), Normal (90% 2s), Hard (80% 2s)
- **Target Values** - Set your goal: 512, 2048, 4096, or 8192

### Smooth Animations
- Fluid tile sliding with spring animations
- Satisfying "pop" effect on tile merges
- Visual urgency indicators for timer/move limits

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.1+

## Project Architecture

This project follows a **workspace + SPM package** architecture:

```
Game2048/
├── Game2048.xcworkspace/       # Workspace container
├── Game2048.xcodeproj/         # App shell (minimal wrapper)
├── Game2048/                   # App target - entry point only
│   └── Game2048App.swift
├── Game2048Package/            # All features and logic
│   ├── Package.swift
│   └── Sources/
│       └── Game2048Feature/
│           ├── Models/         # Game logic
│           │   ├── Board.swift
│           │   ├── Tile.swift
│           │   ├── GameModel.swift
│           │   ├── GameMode.swift
│           │   ├── GameConfiguration.swift
│           │   └── Difficulty.swift
│           ├── Views/          # SwiftUI views
│           │   ├── GameView.swift
│           │   ├── BoardView.swift
│           │   ├── TileView.swift
│           │   ├── ModeSelectionView.swift
│           │   └── RootView.swift
│           └── Extensions/     # Utilities
└── Config/                     # Build settings
```

### Key Components

- **GameModel** - Observable game state with undo support
- **Board** - Core game logic with tile movement and merging
- **GameConfiguration** - Flexible game setup options
- **ModeSelectionView** - Pre-game configuration screen
- **BoardView** - Animated game board with gesture handling

## Building

1. Open `Game2048.xcworkspace` in Xcode
2. Select the `Game2048` scheme
3. Build and run on simulator or device

## Controls

- **Swipe** - Move tiles in any direction
- **Arrow Keys** - Keyboard control (iPad/Simulator)

## License

MIT License

---

🎮 Enjoy the game!