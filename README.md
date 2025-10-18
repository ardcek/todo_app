# Flutter Todo App

A modern, feature-rich todo application built with Flutter. This app helps users manage their tasks efficiently with a clean and intuitive interface.

## Features

- ✨ Clean and modern UI design
- 🌓 Dark/Light theme support
- 🌍 Multilingual (English and Turkish)
- 🔔 Local notifications for task reminders
- 📱 Cross-platform support (Windows, iOS, Android)
- 🎯 Task prioritization
- 📂 Project-based task organization
- 🔄 Task status tracking
- 📅 Due date and reminder management

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Database**: Drift (SQLite)
- **Navigation**: Go Router
- **Localization**: Flutter Localizations
- **Notifications**: Flutter Local Notifications
- **Code Generation**: Build Runner, Freezed
- **Architecture**: Clean Architecture principles

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/todo_app.git
```

2. Navigate to the project directory:
```bash
cd todo_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/      # App configuration
│   ├── database/    # Database setup
│   ├── router/      # Navigation
│   └── theme/       # App theming
├── features/
│   └── tasks/
│       ├── data/    # Repositories
│       ├── models/  # Data models
│       └── presentation/  # UI components
└── l10n/           # Localization files
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
