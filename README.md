# Kemet

Kemet is a Flutter mobile application with a modern Egyptian-themed identity. The project focuses on a clean Material UI experience and a smooth first impression through custom splash screen animations.

## Project Overview

Kemet is designed as a modern, visually polished mobile app built with Flutter. The codebase is structured to keep presentation, business logic, and data concerns organized for easier maintenance and future expansion.

## Features

- Egyptian-inspired visual direction with a modern UI approach
- Built with Flutter for fast, cross-platform mobile development
- Material Design-based interface components
- Custom animated splash screen flow for a smooth app launch experience
- Organized project layers (`model`, `view`, `viewmodel`) for scalable development

## Technologies Used

- Flutter
- Dart
- Material UI (Flutter Material components)
- Custom splash screen animations
- `flutter_native_splash` for native launch splash configuration

## Installation

### Prerequisites

- Flutter SDK (compatible with the project SDK constraints)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter/Dart extensions
- A connected device or emulator

### Setup Steps

```bash
git clone <your-repository-url>
cd kemet
flutter pub get
flutter run
```

### Run Tests

```bash
flutter test
```

## Project Structure

```text
kemet/
	lib/
		main.dart
		model/
		view/
		viewmodel/
	images/
	test/
	pubspec.yaml
```