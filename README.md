# Modern Todo App

A powerful and intuitive task management application built with Flutter, featuring projects organization, focus timer, and comprehensive task management capabilities.

## ✨ Features

### Task Management
- ✅ Create, edit, and delete tasks with ease
- 📅 Set due dates and manage deadlines
- 🎯 Three priority levels (Low, Medium, High)
- ⏰ Snooze tasks to different times
- 📋 Organize tasks in Today and Upcoming views
- 🔄 Automatic task numbering for unnamed tasks

### Projects
- 📁 Create and manage multiple projects
- � Custom colors and icons for each project
- 📊 Project statistics (total, pending, completed tasks)
- � Add tasks directly to projects
- 🏷️ Auto-naming for unnamed projects ("Adsız Proje X" / "Unnamed Project X")

### Focus Timer
- ⏱️ Pomodoro-style focus timer
- ⚡ Quick presets (15m, 25m, 45m, 1h)
- ⚙️ Custom duration support
- � System notifications with progress bar
- 🔊 Alarm sound when timer completes
- � Background timer with live updates

### UI/UX
- 🎨 Modern Material Design 3
- 🌓 Dark and Light theme support with instant transitions
- 🌍 Full localization (English and Turkish)
- 📱 Responsive design optimized for mobile
- ✨ Smooth animations and performance optimizations
- 🎯 Intuitive gesture controls

## Screenshots

[Coming soon]

## 🛠️ Tech Stack

- **Framework:** Flutter 3.32.1
- **State Management:** Riverpod 2.6.1
- **Navigation:** GoRouter 13.2.5
- **Database:** SQLite with Drift 2.28.2
- **Notifications:** flutter_local_notifications 17.2.4
- **Audio:** audioplayers 6.5.1
- **Architecture:** Feature-based Clean Architecture
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

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration and language controller
│   ├── database/        # SQLite database setup
│   ├── router/          # GoRouter navigation configuration
│   └── theme/           # Material Design 3 theme
├── features/
│   ├── shell/           # Main app shell and navigation
│   ├── tasks/           # Task management module
│   │   ├── models/      # Task and project models
│   │   ├── presentation/# UI components and pages
│   │   └── widgets/     # Reusable task widgets
│   └── timer/           # Focus timer module
│       └── presentation/# Timer widget and notifications
└── l10n/                # English and Turkish localization
```

## 📝 Version History

- **v2.0** - Major Feature Update (October 2025)
  - ✨ Projects system with task management
  - ⏱️ Focus timer with notifications and alarm
  - ✏️ Task editing functionality
  - 🏷️ Auto-naming for tasks and projects
  - 📊 Project statistics and detail pages
  - 🎨 UI refinements and performance optimizations
  - 🔔 Timer notifications with progress bar
  - ⚙️ Custom timer duration support

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

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/ardcek/todo_app/issues).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Arda**
- GitHub: [@ardcek](https://github.com/ardcek)
- Instagram: [@ardcek](https://instagram.com/ardcek)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- All open-source contributors
