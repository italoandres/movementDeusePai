# Jornada Deus é Pai - Flutter Web

Uma aplicação Flutter Web para jornada espiritual progressiva, guiando usuários desde o reconhecimento da orfandade espiritual até o diálogo íntimo com o Pai.

## 🎯 Visão Geral

Este projeto é uma migração/evolução do sistema Next.js existente para Flutter Web, mantendo compatibilidade total com os dados do Supabase e adicionando novas experiências emocionais.

### Filosofia: A Regra de Ouro

> "O usuário sempre tem liberdade técnica… mas a experiência faz ele desejar emocionalmente o caminho certo."

- ✅ Sem dark patterns ou bloqueios artificiais
- ✅ Condução emocional respeitosa
- ✅ Hierarquia visual e copy emocional
- ✅ Autonomia do usuário preservada

## 🌟 Principais Features

### LIVRO 1: Carta de um Órfão (Gratuito)
- Experiência imersiva híbrida
- Texto progressivo sincronizado com narração
- Interações: Tap → avança | Hold → pausa | Auto-advance
- Sensação de "alguém falando comigo"
- SEM controles tradicionais de mídia

### Transition Screen
- Minimalismo extremo
- Mensagem em 2 partes com pausa emocional
- Ponto de conversão do sistema
- Forward-only flow

### LIVRO 2: Journey System (Pago - Futuro)
- Capítulos sequenciais
- Sistema de reflexões
- Progress tracking
- Seal system (conquistas)

### Preparation Screen
- Reforço de identidade (filho/filha)
- Afirmações emocionais
- Breathing exercise opcional

## 🏗️ Arquitetura

### Feature-Based Modular Architecture

```
lib/
├── features/
│   ├── entry/          # Tela inicial
│   ├── carta/          # Carta de um Órfão (Livro 1)
│   ├── transition/     # Transition Screen
│   ├── journey/        # Journey System (Livro 2)
│   ├── preparation/    # Preparation Screen
│   └── auth/           # Autenticação
└── shared/
    ├── core/           # Utilities
    ├── theme/          # Design System
    ├── widgets/        # Reusable widgets
    ├── models/         # Domain models
    ├── providers/      # Riverpod providers
    └── services/       # Services (Supabase, etc)
```

### Clean Architecture

Cada feature segue:
- **Presentation**: UI (screens, widgets, providers)
- **Domain**: Business logic (models, repositories, use cases)
- **Data**: Data sources (Supabase, local storage)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x (Web)
- **State Management**: flutter_riverpod ^2.5.0
- **Backend**: Supabase (existing instance)
  - supabase_flutter ^2.8.3
- **Routing**: go_router ^13.0.0
- **Audio**: audioplayers ^6.0.0
- **Markdown**: flutter_markdown ^0.6.0
- **Local Storage**: shared_preferences ^2.2.0
- **Value Equality**: equatable ^2.0.7

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.9.2+
- Supabase account (existing credentials)

### Installation

```bash
# Clone the repository
cd jornada_deus_pai

# Install dependencies
flutter pub get

# Configure environment variables
# Edit .env with your Supabase credentials
```

### Running

```bash
# Development mode (Chrome)
flutter run -d chrome

# Development mode (Web Server)
flutter run -d web-server --web-port=8080

# Production build
flutter build web --release
```

### Environment Variables

Create a `.env` file in the root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🎨 Design System

### Color Palette
- **Primary**: Warm Gold/Amber (#FFA726)
- **Secondary**: Soft Blue (#64B5F6)
- **Background**: Dark Gray/Black (#121212)
- **Surface**: Dark Gray (#1E1E1E)
- **Error**: Soft Red (#EF5350)

### Typography
- **H1**: 32sp, Bold
- **H2**: 24sp, Bold
- **H3**: 20sp, Semi-bold
- **Body**: 16sp, Normal
- **Caption**: 14sp, Normal

### Spacing Scale
4, 8, 12, 16, 24, 32, 48, 64 logical pixels

## 📊 Database Schema

### Existing Tables (Preserved)
- `profiles` - User profiles
- `chapters` - Chapter content (Livro 2)
- `user_progress` - Progress tracking
- `seals` - Seal definitions
- `user_seals` - Unlocked seals

### New Tables (To be created)
- `user_reflections` - User reflections per chapter
- `user_journey_stage` - Current journey stage
- `user_purchased_content` - Paid content purchases (future)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/features/entry/entry_screen_test.dart
```

## 📦 Deployment

### Firebase Hosting (Recommended)

```bash
# Build for production
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

### Vercel

```bash
# Build for production
flutter build web --release

# Deploy to Vercel
vercel --prod
```

## 🔐 Security

- Environment variables for sensitive data
- Supabase Row Level Security (RLS) enabled
- HTTPS only
- Input validation and sanitization
- XSS protection in content parser

## ♿ Accessibility

- WCAG AA compliance (4.5:1 contrast minimum)
- Minimum touch target: 48x48 logical pixels
- Screen reader support
- Keyboard navigation
- Scalable text
- Focus indicators

## 📝 Documentation

- [Requirements Document](.kiro/specs/JornadaDeusePai/requirements.md)
- [Design Document](.kiro/specs/JornadaDeusePai/design.md)
- [Implementation Tasks](.kiro/specs/JornadaDeusePai/tasks.md)
- [Implementation Status](IMPLEMENTATION_STATUS.md)

## 🤝 Integration with No Secreto App

This module is designed to be integrated into the "No Secreto" mobile app:

```dart
// Example integration
import 'package:jornada_deus_pai/jornada_deus_pai_module.dart';

JornadaDeusePaiModule(
  navigationDelegate: customNavigationDelegate,
  themeData: appTheme,
  onMilestone: (milestone) {
    // Handle journey milestones
  },
)
```

## 📄 License

Private - All Rights Reserved

## 👥 Team

Developed for the "Deus é Pai" spiritual movement.

---

**Status**: Foundation Complete ✅  
**Last Updated**: 2026-04-29  
**Version**: 1.0.0+1
