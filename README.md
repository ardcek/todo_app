# Modern Todo App

A sleek and modern task management application built with Flutter, featuring a beautiful dark/light theme and smooth animations.

## Features

- 🎨 Modern UI with Material Design 3
- 🌓 Dark and Light theme support
- 🌍 Localization (English and Turkish)
- 📱 Responsive design for all platforms
- ✨ Smooth animations and transitions
- 🗃️ Local SQLite database storage
- 🔍 Task filtering and sorting
- 📅 Due date and reminder support
- 🚀 Priority levels with visual indicators

## Screenshots

[Coming soon]

## Tech Stack

- **Frontend:** Flutter
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Database:** SQLite (drift)
- **Architecture:** Clean Architecture
- **Design System:** Material Design 3

## Getting Started

### Prerequisites

- Flutter (Latest stable version)
- Dart SDK
- VS Code or Android Studio

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ardcek/todo_app.git
```

2. Navigate to the project directory:
```bash
cd todo_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core functionality
│   ├── config/     # App configuration
│   ├── database/   # Database setup
│   ├── router/     # Navigation setup
│   └── theme/      # Theme configuration
├── features/       # Feature modules
│   └── tasks/      # Task management feature
│       ├── models/     # Data models
│       └── presentation/ # UI components
└── l10n/          # Localization
```

## Version History

- **v0.2** - Modern UI Update
  - Complete UI overhaul with modern design system
  - New color system for light/dark themes
  - Improved animations and transitions
  - Enhanced visual hierarchy

- **v0.1** - Initial Release
  - Basic task management functionality
  - SQLite database integration
  - Dark/Light theme toggle
  - Localization support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
