# Kemet - Production-Grade Egyptian Tourism, Culture & Commerce Platform

Kemet is a portfolio-ready, graduation-level Flutter project built with a production mindset. The platform blends tourism discovery, cultural storytelling, AI assistance, map interaction, and a premium store experience into one cohesive mobile product.

---

## 1) Project Overview

Kemet is an **Egyptian tourism & culture application** designed to help users explore Egypt intelligently and interactively.

The app combines:
- 🏺 Egyptian tourism exploration and historical storytelling
- 🗺️ Interactive map-based landmark discovery
- 🛍️ Premium e-commerce store experience
- 🤖 AI-powered chatbot assistant (text + image context)
- 🔊 Audio narration for place descriptions
- 🌍 Arabic/English support with RTL/LTR rendering
- 🌑 Premium dark Egyptian user interface with gold accents

### Product Vision
Kemet is designed to be more than a static guide. It acts as a smart companion where users can:
- Discover places.
- Understand historical context.
- Ask intelligent tourism questions.
- Navigate on map.
- Purchase themed products within the same ecosystem.

---

## 2) Main Features

### Tourism Exploration
- Browse landmarks and points of interest across Egypt.
- Filter and discover by category and location context.

### Place Details
- Dedicated details screens with structured tourism information.
- Integrated galleries, contextual metadata, and review access.

### Story & Narration System
- Landmark descriptions can be narrated via TTS.
- Narration controls integrated into landmark details UX.

### Interactive Map
- Built using OpenStreetMap tiles (`flutter_map`).
- User location + landmark markers + quick details navigation.

### Smart AI Chatbot
- Tourism-focused assistant for Egypt.
- Supports text chat and image-assisted interactions.
- Intelligent prompt framing and contextual responses.

### Store System
- Full product listing with categories and dynamic localization.
- Premium product cards and detailed product view.

### Product Details
- Localized titles/descriptions (EN/AR).
- Category badges, stock status, and polished product UI.

### Cart Functionality
- Add/update/remove product quantities.
- Persistent cart workflow integrated with checkout pipeline.

### Localization
- Full English/Arabic support.
- Dynamic localized rendering across key screens.

### Dynamic Language Switching
- Runtime locale switching via settings state.
- No app rebuild strategy changes required by user.

### Responsive UI
- Adaptive sizing and typography with `flutter_screenutil`.
- Layout behavior tuned for multiple screen sizes.

---

## 3) Clean Architecture

The codebase follows a **feature-oriented clean architecture approach** with clear layer boundaries.

### Presentation Layer
- UI screens, widgets, Cubits/Blocs, and view states.
- Responsible for rendering, user interactions, and state reaction.

### Domain Layer
- Entities, repository contracts, and use cases.
- Encapsulates business rules independent of framework details.

### Data Layer
- Remote/local data sources, models, and repository implementations.
- Handles API requests, persistence, serialization, and mapping.

### Why This Matters
- **Separation of concerns:** each layer has a strict responsibility.
- **Scalability:** new features can be added without touching unrelated modules.
- **Maintainability:** easier refactoring and lower regression risk.
- **Reusability:** domain rules can be reused across presentation variants.
- **Clean feature isolation:** each feature remains modular and self-contained.

---

## 4) Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── localization/
│   ├── network/
│   ├── routing/
│   ├── services/
│   └── utils/
├── features/
│   ├── tourism/        # represented by landmarks + home discovery modules
│   ├── maps/
│   ├── chatbot/
│   ├── store/
│   ├── reviews/
│   ├── settings/
│   ├── narration/      # represented by text-to-speech service integration
│   ├── auth/
│   ├── notifications/
│   ├── payment/
│   ├── order/
│   └── ...
├── shared/             # shared concerns are distributed in core + reusable widgets/services
└── main.dart
```

### Folder Responsibility Breakdown
- `core/`
  - Shared app-wide concerns: routing, app constants, localization engine, networking abstractions, utility services.
- `features/`
  - Business modules split by capability (maps, chatbot, store, reviews, etc.).
- `main.dart`
  - Bootstrap entry point, env loading, Firebase init, DI setup, and app launch.
- `kemet_app.dart`
  - Root composition: repositories, blocs, theme mode, locale, and MaterialApp setup.

---

## 5) Feature Workflow

Core data path across features:

```text
UI -> Cubit/Bloc -> UseCases -> Repository -> API/Data Source
```

### Navigation Flow
- Central route keys in `core/routing/routes.dart`.
- Route generation and guards in `core/routing/app_router.dart`.
- Typed route arguments and fallback screens for invalid payloads.

### State Management Flow
- Cubit emits deterministic states (`Loading`, `Success`, `Error`, etc.).
- UI subscribes through `BlocBuilder` / `BlocConsumer` and rebuilds reactively.

### API Request Flow
1. Presentation triggers Cubit event.
2. Cubit executes use case.
3. Use case delegates to repository.
4. Repository pulls from remote/local sources.
5. Results mapped to domain entities and returned to UI state.

### Chatbot Request Lifecycle
1. User sends text/image from Flutter UI.
2. Flutter service posts JSON/multipart request to FastAPI endpoint.
3. Backend enriches prompt/context and calls AI model API.
4. Response returned as JSON and rendered in conversation UI.

---

## 6) State Management

Kemet uses **Bloc/Cubit** as the primary state management architecture.

### Why Bloc Was Chosen
- Predictable state transitions.
- Strong scalability for multi-feature apps.
- Clear separation between UI and business state.

### Benefits in This Project
- **Predictable states:** improves debugging and feature reliability.
- **Scalable architecture:** each feature can own its own cubit/state.
- **Reactive updates:** UI reflects state changes instantly and safely.

---

## 7) Backend & Python Integration

Kemet integrates a **Python backend** for AI chatbot orchestration.

### Backend Stack
- **Framework:** FastAPI
- **Language:** Python
- **API Style:** JSON REST + multipart uploads


### Technical Characteristics
- Asynchronous request handling for responsive chat operations.
- Lightweight routing and schema validation.
- Optimized communication layer between Flutter and AI providers.

### Frontend-Backend Communication
- Flutter app communicates with backend through HTTP services.
- JSON-based request/response for chat flows.
- Multipart communication for image endpoints.

---

## 8) AI Chatbot System

The chatbot subsystem is built as a dedicated AI interaction layer.

### Chatbot Architecture
- Flutter client sends request to backend service.
- Backend applies system prompt and contextual enrichment.
- Model response is returned and displayed in chat UI.

### Prompt Processing
- System prompt defines assistant identity, tone, and domain boundaries.
- Tourism scope and language behavior are constrained in prompt logic.

### Request/Response Lifecycle
1. User query input.
2. Backend context assembly.
3. AI model completion call.
4. Structured response returned.
5. UI updates chat timeline state.

### Conversational Handling
- Session continuity via user-scoped identifiers.
- Basic in-memory history management in backend layer.
- Supports multilingual conversation style handling.

### Smart Tourism Assistance
- Focuses on Egypt tourism knowledge and guidance.
- Can include nearby place context in responses.

---

## 9) Hugging Face Deployment

The FastAPI chatbot backend is deployed on **Hugging Face Spaces**.

### Why Hugging Face Spaces
- Free and practical hosting option for AI services.
- Easy deployment workflow for Python apps.
- Built-in compatibility with FastAPI and AI tooling.
- Lightweight hosting suitable for prototype-to-portfolio deployments.

### Deployment Workflow
1. Prepare FastAPI backend app.
2. Configure environment variables/secrets.
3. Deploy to Hugging Face Space.
4. Expose public API endpoint.
5. Connect Flutter client service to deployed URL.

### API Endpoint Usage
- Flutter chatbot service uses deployed Space URL for `/chat` and `/image`.

### Environment Configuration
- API keys should be configured via environment secrets.
- No hardcoded production secrets in client code.

### Backend Accessibility from Flutter
- HTTP client service in Flutter requests backend endpoint directly.
- Error-safe parsing and request timeout handling included.

---

## 10) API Integration

### OpenTripMap API
- Landmarks retrieval and details flow integrated through OpenTripMap endpoints.
- Language-sensitive endpoint behavior (`en` / `ar`) with fallback handling.

### AI API Communication
- Chatbot backend mediates model interaction and response formatting.
- Supports text and image-based assistant requests.

### Product Data Handling
- Store module reads product data via Firestore-backed data source/repository flow.
- Product entities support localized fields (`name`, `nameAr`, `description`, `descriptionAr`).

### External Service Integration
- Firebase (Auth, Firestore, Messaging)
- Paymob payment APIs
- OpenStreetMap tile ecosystem

---

## 11) Localization

Kemet provides robust localization support:
- **Arabic and English**
- **RTL/LTR rendering**
- **Dynamic language switching**
- **Localized UI rendering across key modules**

### Implementation Notes
- Localization keys loaded from `assets/l10n/en.json` and `assets/l10n/ar.json`.
- Runtime locale controlled by `SettingsCubit`.
- Flutter localization delegates are configured at app root (`kemet_app.dart`).

---

## 12) UI/UX Design

### Design Direction
- Premium dark Egyptian aesthetic.
- Gold accent hierarchy for premium visual identity.

### UX Principles
- Smooth transitions and micro-interactions.
- Clear content hierarchy and readable typography.
- Context-first tourism and commerce exploration.

### Layout & Motion
- Responsive sizing using `flutter_screenutil`.
- Smooth animations and polished navigation transitions.

---

## 13) Technologies Used

- Flutter
- Dart
- Bloc / Cubit
- Clean Architecture (feature-layered)
- REST APIs
- Python
- FastAPI
- Hugging Face Spaces
- OpenTripMap API
- Firebase (Core, Auth, Firestore, Messaging)
- Shared Preferences
- flutter_dotenv
- flutter_map + latlong2
- flutter_tts
- dio / http
- webview_flutter
- cached_network_image
- google_fonts

---

## 14) Setup Instructions

### 1) Clone Repository
```bash
git clone <your-repository-url>
cd kemet
```

### 2) Enter Flutter App Directory
```bash
cd kemet
```

### 3) Install Dependencies
```bash
flutter pub get
```

### 4) Configure `.env`
Create `.env` file in `kemet/` and define required keys.

### 5) API Configuration
- Ensure chatbot backend URL is reachable by your runtime environment.
- Ensure Firebase config files are correctly added for Android/iOS.

### 6) Run App
```bash
flutter run
```

---

### Security Notes
- Never commit real secrets.
- Use CI/CD secret stores for release pipelines.
- Rotate exposed keys immediately if leaked.

---

### FastAPI Deployment
- Backend service can be deployed as a standalone FastAPI app.
- Configure runtime secrets in deployment environment.

### Hugging Face Deployment Process
1. Push backend app to Space repository.
2. Add required environment secrets.
3. Verify health endpoint and API routes.
4. Connect Flutter client service to deployed endpoint.

---

## 17) Team / Credits

Built as a production-style graduation and portfolio project by the Kemet team.

### Credits
- Flutter & Dart ecosystem
- FastAPI and Python community
- Hugging Face Spaces platform
- OpenTripMap API
- Firebase platform services
- OpenStreetMap data and tile ecosystem

