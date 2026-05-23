# Design Document: Jornada Deus é Pai - Flutter Web Migration

## Overview

### Purpose

This design document specifies the technical architecture for migrating the "Livro Interativo Espiritual" from Next.js to Flutter Web. The system will be rebuilt as a standalone Flutter Web application that can also be integrated as a feature module into the "No Secreto" mobile app. The core mission is to create a deeply emotional spiritual journey that guides users from recognizing spiritual orphanhood to intimate dialogue with the Father.

### Context and Migration Strategy

This is **not a greenfield project** - it's an evolution of an existing, functional Next.js application. The migration strategy prioritizes:

1. **Data Preservation**: All existing Supabase data must be preserved and reused
2. **Functionality Parity**: Maintain all existing features from the Next.js version
3. **Experience Enhancement**: Add new emotional touchpoints (Entry Screen, Carta de um Órfão with video, Transition Screen, Preparation Screen)
4. **Future Integration**: Prepare for integration into the "No Secreto" mobile app

### Design Philosophy: The Golden Rule

The system follows a fundamental principle: **"The user always has technical freedom… but the experience makes them emotionally desire the right path."**

This means:
- **No dark patterns**: Never block, force, or manipulate users technically
- **Emotional guidance**: Use visual hierarchy, emotional copy, and timing to create natural desire for the intended flow
- **Respect autonomy**: Users can always choose alternative paths
- **Measure effectiveness**: Track conversion rates to validate that emotional guidance works

Every design decision must balance **technical freedom** with **emotional guidance**.

### Key Features

1. **Entry Screen**: Emotional introduction with two paths (root journey vs. direct to chat)
2. **Carta de um Órfão (Livro 1)**: Immersive hybrid experience combining progressive text blocks with synchronized narration
3. **Transition Screen**: Minimalist emotional conversion point after Carta
4. **Journey System (Livro 2)**: Sequential chapter-based content with reflections (future paid content)
5. **Preparation Screen**: Identity reinforcement before chat
6. **Progress Tracking**: Automatic progress persistence across devices
7. **Seal System**: Symbolic achievements for journey milestones
8. **Monetization Ready**: Architecture prepared for paid content (Livro 2)

### Technology Stack

- **Framework**: Flutter 3.x with web support
- **State Management**: flutter_riverpod ^2.5.0
- **Backend**: Supabase (existing instance, reused)
  - supabase_flutter ^2.8.3
- **Value Equality**: equatable ^2.0.7
- **Audio Playback**: audioplayers or just_audio
- **Routing**: go_router ^13.0.0
- **Markdown Rendering**: flutter_markdown ^0.6.0
- **Analytics**: firebase_analytics or posthog_flutter

### Success Criteria

1. **Functional Parity**: All Next.js features work in Flutter Web
2. **Data Compatibility**: Seamless access to existing Supabase data
3. **Emotional Impact**: High conversion rate from Carta → Transition → Preparation
4. **Performance**: Initial load < 3s on 3G, smooth 60fps animations
5. **Integration Ready**: Module can be integrated into No Secreto app
6. **Monetization Ready**: Architecture supports paid content without refactoring



## Architecture

### High-Level Architecture

The system follows a **feature-based modular architecture** with clear separation of concerns:

```
jornada_deus_pai/
├── lib/
│   ├── features/
│   │   ├── entry/              # Entry Screen feature
│   │   ├── carta/              # Carta de um Órfão (Livro 1)
│   │   ├── transition/         # Transition Screen
│   │   ├── journey/            # Journey System (Livro 2)
│   │   ├── preparation/        # Preparation Screen
│   │   └── auth/               # Authentication
│   ├── shared/
│   │   ├── core/               # Core utilities, constants
│   │   ├── theme/              # Design system
│   │   ├── widgets/            # Reusable widgets
│   │   ├── models/             # Domain models
│   │   ├── providers/          # Shared Riverpod providers
│   │   └── services/           # Shared services
│   ├── app.dart                # App entry point
│   └── main.dart               # Main entry point
└── test/
```

### Feature Module Structure

Each feature follows **Clean Architecture** principles with three layers:

```
feature_name/
├── presentation/
│   ├── screens/                # Full-screen pages
│   ├── widgets/                # Feature-specific widgets
│   └── providers/              # Feature-specific Riverpod providers
├── domain/
│   ├── models/                 # Domain entities
│   ├── repositories/           # Repository interfaces
│   └── use_cases/              # Business logic
└── data/
    ├── repositories/           # Repository implementations
    ├── data_sources/           # Remote/local data sources
    └── dtos/                   # Data transfer objects
```

### Layer Responsibilities

**Presentation Layer**:
- UI components (screens, widgets)
- State management (Riverpod providers)
- User interaction handling
- Navigation

**Domain Layer**:
- Business logic (use cases)
- Domain models (entities)
- Repository contracts (interfaces)
- Business rules validation

**Data Layer**:
- Repository implementations
- Data sources (Supabase, local storage)
- Data transformation (DTOs ↔ Models)
- Caching and offline support

### Dependency Flow

```
Presentation → Domain → Data
     ↓           ↓        ↓
  Riverpod   Use Cases  Supabase
```

- Presentation depends on Domain (not Data)
- Domain is independent (no external dependencies)
- Data implements Domain contracts
- Dependency injection via Riverpod

### Module Independence and Integration

**Standalone Mode**:
- App runs independently with its own navigation
- Uses go_router for declarative routing
- Self-contained feature modules

**Integrated Mode** (No Secreto App):
- Exposes `JornadaDeusePaiModule` as public API
- Accepts `NavigationDelegate` for custom navigation
- Accepts `ThemeData` for visual consistency
- Emits events for journey milestones
- No hard dependencies on navigation library

### Cross-Cutting Concerns

**State Management**:
- Riverpod for all state management
- Provider-based dependency injection
- Immutable state with Equatable

**Navigation**:
- go_router for declarative routing
- Deep linking support
- Navigation guards for authentication
- Custom navigation delegate for integration

**Error Handling**:
- Centralized error handling service
- User-friendly error messages in Portuguese
- Detailed logging for debugging
- Retry mechanisms for failed operations

**Offline Support**:
- Local caching with Hive or SharedPreferences
- Queue for offline operations
- Sync when connection restored
- Offline indicators



## Components and Interfaces

### Feature: Entry Screen

**Purpose**: Emotional introduction that presents two paths to users.

#### Components

**EntryScreen** (Presentation)
```dart
class EntryScreen extends ConsumerWidget {
  // Displays emotional text about spiritual orphanhood
  // Two buttons: "Começar pela raiz" (primary) and "Ir direto falar com o Pai" (secondary)
  // Implements Golden Rule: primary button is visually prominent, secondary is accessible
}
```

**EntryContent** (Widget)
```dart
class EntryContent extends StatelessWidget {
  final String emotionalText;
  final VoidCallback onStartFromRoot;
  final VoidCallback onGoDirectToChat;
  
  // Displays emotional copy with visual hierarchy
  // Primary button uses warm accent color, larger size
  // Secondary button uses subtle styling, smaller size
}
```

#### Navigation Flow

```
EntryScreen
  ├─→ "Começar pela raiz" → CartaScreen (Livro 1)
  └─→ "Ir direto falar com o Pai" → PreparationScreen (skip Livro 1)
```

#### State Management

```dart
@riverpod
class JourneyStageNotifier extends _$JourneyStageNotifier {
  @override
  Future<JourneyStage> build() async {
    // Load current stage from Supabase
    // Return last stage or 'entry' for new users
  }
  
  Future<void> updateStage(JourneyStage stage) async {
    // Update stage in Supabase
    // Emit analytics event
  }
}
```

---

### Feature: Carta de um Órfão (Livro 1)

**Purpose**: Immersive hybrid experience combining progressive text with synchronized narration.

#### Components

**CartaScreen** (Presentation)
```dart
class CartaScreen extends ConsumerStatefulWidget {
  // Full-screen immersive experience
  // Manages audio playback and text synchronization
  // Handles tap (advance), hold (pause), release (resume)
  // No traditional media controls visible
}
```

**ProgressiveTextDisplay** (Widget)
```dart
class ProgressiveTextDisplay extends StatefulWidget {
  final List<TextBlock> blocks;
  final int currentBlockIndex;
  final AnimationController fadeController;
  
  // Displays text blocks with fade-in animation
  // Synchronized with audio timestamps
  // Conversational rhythm matching narration
}
```

**AudioNarrationController** (Service)
```dart
class AudioNarrationController {
  final AudioPlayer _player;
  final List<TextBlock> _textBlocks;
  
  Stream<int> get currentBlockIndex;
  Stream<Duration> get position;
  Stream<PlayerState> get playerState;
  
  Future<void> initialize(String audioUrl);
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  void dispose();
  
  // Emits currentBlockIndex based on audio position
  // Handles audio loading, buffering, errors
}
```

**TextBlock** (Model)
```dart
class TextBlock extends Equatable {
  final String text;
  final Duration startTime;
  final Duration endTime;
  
  // Represents a single block of text with timing
}
```

#### Interaction Model

```
User Interaction:
  - Tap screen → advance to next block (if not auto-advancing)
  - Hold screen → pause narration and text
  - Release hold → resume from pause point
  - Auto-advance → text appears as narration reaches it

Visual Feedback:
  - No visible pause button
  - Subtle progress indicator (not timeline)
  - Fade-in animation for text blocks
  - Clean background (dark or paper texture)
```

#### Audio-Text Synchronization

```dart
@riverpod
class CartaSyncNotifier extends _$CartaSyncNotifier {
  AudioNarrationController? _audioController;
  
  @override
  CartaSyncState build() {
    return CartaSyncState.initial();
  }
  
  Future<void> initialize() async {
    // Load audio URL from Supabase
    // Load text blocks with timestamps
    // Initialize audio controller
    // Start auto-play
  }
  
  void onTap() {
    // Advance to next block if not auto-advancing
  }
  
  void onHoldStart() {
    // Pause audio and text progression
  }
  
  void onHoldEnd() {
    // Resume from pause point
  }
  
  void _syncTextWithAudio(Duration position) {
    // Calculate current block index based on position
    // Update state to display current block
  }
}
```

#### State Model

```dart
class CartaSyncState extends Equatable {
  final List<TextBlock> textBlocks;
  final int currentBlockIndex;
  final bool isPlaying;
  final bool isBuffering;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? errorMessage;
  
  // Immutable state for Carta experience
}
```

#### Navigation Flow

```
CartaScreen → (on completion) → TransitionScreen (mandatory)
```

---

### Feature: Transition Screen

**Purpose**: Minimalist emotional conversion point that transforms emotion into decision.

#### Components

**TransitionScreen** (Presentation)
```dart
class TransitionScreen extends ConsumerWidget {
  // Extreme minimalist design
  // Two-part message with visual pause
  // Single button: "Falar com o Pai pela primeira vez"
  // No back navigation, no secondary actions
}
```

**TwoPartMessage** (Widget)
```dart
class TwoPartMessage extends StatefulWidget {
  final String firstPart;
  final String secondPart;
  final Duration pauseDuration;
  
  // Displays first part
  // Visual pause (breathing space)
  // Displays second part
  // Soft fade-in animations
}
```

#### Message Content

```
Part 1: "Talvez você nunca tenha sido apresentado ao seu verdadeiro Pai."
[Visual pause - 2-3 seconds]
Part 2: "Mas isso pode começar agora."
[Button appears]
```

#### Design Principles

- **Zero distractions**: No decorative elements, no breadcrumbs, no back button
- **Maximum contrast**: Message is highly readable
- **Emotional directness**: Personal, intimate tone
- **Single action**: Only one button, no alternatives
- **Forward-only flow**: Cannot navigate back to Carta
- **Conversion focus**: This is THE decision point

#### Navigation Flow

```
TransitionScreen → (button click) → PreparationScreen (mandatory)
```

---

### Feature: Journey System (Livro 2)

**Purpose**: Sequential chapter-based content with reflections (future paid content).

#### Components

**JourneyScreen** (Presentation)
```dart
class JourneyScreen extends ConsumerWidget {
  // Displays chapter list or current chapter
  // Shows progress indicator
  // Handles chapter navigation
}
```

**ChapterView** (Widget)
```dart
class ChapterView extends StatelessWidget {
  final Chapter chapter;
  final UserProgress? progress;
  
  // Displays chapter title, subtitle
  // Renders formatted content (markdown)
  // Shows reflection input
  // "Próximo Capítulo" button at end
}
```

**ChapterList** (Widget)
```dart
class ChapterList extends StatelessWidget {
  final List<Chapter> chapters;
  final List<UserProgress> userProgress;
  
  // Displays chapters in sequential order
  // Shows completed/in-progress/locked status
  // Visual progress indicator
  // Allows navigation to unlocked chapters
}
```

**ReflectionInput** (Widget)
```dart
class ReflectionInput extends ConsumerStatefulWidget {
  final String chapterId;
  final String? existingReflection;
  
  // Multi-line text area
  // Auto-save draft locally
  // "Salvar Reflexão" button
  // Save confirmation message
}
```

#### Domain Models

```dart
class Chapter extends Equatable {
  final String id;
  final int chapterNumber;
  final String title;
  final String subtitle;
  final String content;
  final String summary;
  final int requiredSeals;
  final int estimatedTime;
  final String difficulty;
  final bool isPaidContent;
  
  // Represents a chapter in Livro 2
}

class UserProgress extends Equatable {
  final String id;
  final String userId;
  final String chapterId;
  final ProgressStatus status; // not_started, in_progress, completed
  final double progressPercentage;
  final int timeSpent; // seconds
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  
  // Tracks user progress for a chapter
}

enum ProgressStatus { notStarted, inProgress, completed }

class UserReflection extends Equatable {
  final String id;
  final String userId;
  final String chapterId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User's personal reflection for a chapter
}
```

#### State Management

```dart
@riverpod
class ChaptersNotifier extends _$ChaptersNotifier {
  @override
  Future<List<Chapter>> build() async {
    // Load chapters from Supabase
    // Order by chapter_number
  }
}

@riverpod
class UserProgressNotifier extends _$UserProgressNotifier {
  @override
  Future<List<UserProgress>> build() async {
    // Load user progress from Supabase
  }
  
  Future<void> markChapterCompleted(String chapterId) async {
    // Update status to 'completed'
    // Set completed_at timestamp
    // Check seal unlock conditions
    // Unlock next chapter
  }
  
  Future<void> updateProgress(String chapterId, double percentage) async {
    // Update progress_percentage
    // Update last_accessed_at
  }
}

@riverpod
class ReflectionNotifier extends _$ReflectionNotifier {
  @override
  Future<UserReflection?> build(String chapterId) async {
    // Load reflection for chapter
  }
  
  Future<void> saveReflection(String chapterId, String content) async {
    // Save or update reflection in Supabase
    // Show success message
  }
}
```

#### Navigation Flow

```
JourneyScreen (chapter list)
  └─→ ChapterView (specific chapter)
        └─→ "Próximo Capítulo" → Next ChapterView
```

---

### Feature: Preparation Screen

**Purpose**: Identity reinforcement before chat.

#### Components

**PreparationScreen** (Presentation)
```dart
class PreparationScreen extends ConsumerWidget {
  // Displays emotional text reinforcing identity as filho/filha
  // Affirmations about being loved and accepted
  // Optional breathing exercise
  // "Estou pronto para conversar" button
  // Skippable (can proceed immediately)
}
```

**IdentityAffirmation** (Widget)
```dart
class IdentityAffirmation extends StatelessWidget {
  final List<String> affirmations;
  
  // Displays affirmations with soft animations
  // Calming visual design with soft colors
}
```

**BreathingExercise** (Widget)
```dart
class BreathingExercise extends StatefulWidget {
  // Optional animated breathing guide
  // Inhale/exhale visual cue
  // Helps user pause and center
}
```

#### Navigation Flow

```
PreparationScreen → (button click) → ChatInterface (out of scope)

Entry points:
  1. From TransitionScreen (after Carta)
  2. From EntryScreen "Ir direto falar com o Pai" (skip Carta)
```

---

### Feature: Authentication

**Purpose**: Integrate with existing Supabase authentication.

#### Components

**LoginScreen** (Presentation)
```dart
class LoginScreen extends ConsumerWidget {
  // Email/password login form
  // OAuth providers (Google, Apple) if configured
  // Link to SignupScreen
  // Error handling
}
```

**SignupScreen** (Presentation)
```dart
class SignupScreen extends ConsumerWidget {
  // Email/password signup form
  // Name input
  // Terms acceptance
  // Link to LoginScreen
  // Error handling
}
```

#### State Management

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    // Listen to Supabase auth state changes
    // Return current user or null
  }
  
  Future<void> signIn(String email, String password) async {
    // Sign in with Supabase
    // Handle errors
  }
  
  Future<void> signUp(String email, String password, String name) async {
    // Sign up with Supabase
    // Profile created automatically via trigger
    // Handle errors
  }
  
  Future<void> signOut() async {
    // Sign out from Supabase
    // Clear local state
    // Navigate to EntryScreen
  }
  
  Future<void> refreshSession() async {
    // Refresh expired session
  }
}

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final user = ref.watch(authNotifierProvider).value;
    if (user == null) return null;
    
    // Load profile from Supabase
  }
  
  Future<void> updateProfile(UserProfile profile) async {
    // Update profile in Supabase
  }
}
```

#### Domain Models

```dart
class UserProfile extends Equatable {
  final String id;
  final String nome;
  final String email;
  final bool perfilIsComplete;
  final bool senhaIsSeted;
  final int totalSeals;
  final String? currentChapter;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User profile from Supabase
}
```

---

### Feature: Seal System

**Purpose**: Symbolic achievements for journey milestones.

#### Components

**SealAwardDialog** (Widget)
```dart
class SealAwardDialog extends StatelessWidget {
  final Seal seal;
  
  // Displays seal award animation
  // Shows seal name, description, icon
  // Celebration animation
  // "Faço parte do movimento Deus é Pai" for completion seal
}
```

**SealList** (Widget)
```dart
class SealList extends StatelessWidget {
  final List<Seal> allSeals;
  final List<UserSeal> unlockedSeals;
  
  // Displays all seals (locked and unlocked)
  // Shows unlock hints for locked seals
  // Visual distinction for unlocked seals
}
```

#### Domain Models

```dart
class Seal extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final String category;
  final String rarity;
  final int points;
  
  // Seal definition
}

class UserSeal extends Equatable {
  final String id;
  final String userId;
  final String sealId;
  final DateTime unlockedAt;
  final String source;
  
  // User's unlocked seal
}
```

#### State Management

```dart
@riverpod
class SealsNotifier extends _$SealsNotifier {
  @override
  Future<List<Seal>> build() async {
    // Load seal definitions from Supabase
  }
}

@riverpod
class UserSealsNotifier extends _$UserSealsNotifier {
  @override
  Future<List<UserSeal>> build() async {
    // Load user's unlocked seals
  }
  
  Future<void> checkAndAwardSeals(String chapterId) async {
    // Check seal unlock conditions after chapter completion
    // Award seal if condition met
    // Show seal award dialog
    // Update total_seals in profile
  }
}
```

---

### Shared Services

#### SupabaseService

```dart
class SupabaseService {
  final SupabaseClient _client;
  
  // Authentication
  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(String email, String password);
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
  
  // Profiles
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  
  // Chapters
  Future<List<Chapter>> getChapters();
  Future<Chapter?> getChapter(String chapterId);
  
  // Progress
  Future<List<UserProgress>> getUserProgress(String userId);
  Future<void> updateProgress(UserProgress progress);
  
  // Reflections
  Future<UserReflection?> getReflection(String userId, String chapterId);
  Future<void> saveReflection(UserReflection reflection);
  
  // Seals
  Future<List<Seal>> getSeals();
  Future<List<UserSeal>> getUserSeals(String userId);
  Future<void> awardSeal(String userId, String sealId, String source);
  
  // Journey Stage
  Future<JourneyStage?> getJourneyStage(String userId);
  Future<void> updateJourneyStage(String userId, JourneyStage stage);
}
```

#### CacheService

```dart
class CacheService {
  // Local caching with Hive or SharedPreferences
  Future<void> cacheChapters(List<Chapter> chapters);
  Future<List<Chapter>?> getCachedChapters();
  
  Future<void> cacheProgress(List<UserProgress> progress);
  Future<List<UserProgress>?> getCachedProgress();
  
  Future<void> clearCache();
}
```

#### AnalyticsService

```dart
class AnalyticsService {
  // Track screen views
  void trackScreenView(String screenName);
  
  // Track events
  void trackChapterCompleted(String chapterId);
  void trackReflectionSaved(String chapterId);
  void trackSealUnlocked(String sealId);
  void trackNavigationChoice(String choice); // 'raiz' or 'direto'
  void trackTransitionButtonClick();
  void trackAudioEvent(String event); // 'play', 'pause', 'complete'
  
  // Track errors
  void trackError(String error, StackTrace? stackTrace);
}
```

#### ErrorHandlingService

```dart
class ErrorHandlingService {
  String getUserFriendlyMessage(Exception error) {
    // Convert technical errors to Portuguese user-friendly messages
    if (error is NetworkException) {
      return "Problema de conexão. Verifique sua internet.";
    }
    if (error is AuthException) {
      return "Erro de autenticação. Tente novamente.";
    }
    // ... more error types
    return "Algo deu errado. Tente novamente.";
  }
  
  void logError(Exception error, StackTrace? stackTrace) {
    // Log detailed error for debugging
  }
}
```



## Data Models

### Database Schema (Supabase)

The system reuses the existing Supabase schema with extensions for new features.

#### Existing Tables (Preserved)

**profiles**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  nome TEXT,
  email TEXT,
  perfil_is_complete BOOLEAN DEFAULT FALSE,
  senha_is_seted BOOLEAN DEFAULT TRUE,
  total_seals INTEGER DEFAULT 0,
  current_chapter TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**chapters**
```sql
CREATE TABLE chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_number INTEGER NOT NULL UNIQUE,
  title TEXT NOT NULL,
  subtitle TEXT,
  content TEXT NOT NULL,
  summary TEXT,
  required_seals INTEGER DEFAULT 0,
  estimated_time INTEGER, -- minutes
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  is_paid_content BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_progress**
```sql
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('not_started', 'in_progress', 'completed')),
  progress_percentage DECIMAL(5,2) DEFAULT 0.00,
  time_spent INTEGER DEFAULT 0, -- seconds
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);
```

**seals**
```sql
CREATE TABLE seals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  category TEXT,
  rarity TEXT CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
  points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_seals**
```sql
CREATE TABLE user_seals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  seal_id UUID REFERENCES seals(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT, -- 'journey_complete', 'first_message', 'chapter_1', etc.
  UNIQUE(user_id, seal_id)
);
```

#### New Tables (Migration Required)

**user_reflections**
```sql
CREATE TABLE user_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);
```

**user_journey_stage**
```sql
CREATE TABLE user_journey_stage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  current_stage TEXT CHECK (current_stage IN ('entry', 'carta', 'transition', 'journey', 'preparation', 'chat')),
  last_stage_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_purchased_content** (Monetization Preparation)
```sql
CREATE TABLE user_purchased_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content_type TEXT CHECK (content_type IN ('chapter', 'book', 'bundle')),
  content_id TEXT NOT NULL, -- chapter_id or book identifier
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  payment_method TEXT,
  amount DECIMAL(10,2),
  currency TEXT DEFAULT 'BRL',
  UNIQUE(user_id, content_type, content_id)
);
```

### Domain Models (Flutter)

#### Core Models

```dart
// User Profile
class UserProfile extends Equatable {
  final String id;
  final String nome;
  final String email;
  final bool perfilIsComplete;
  final bool senhaIsSeted;
  final int totalSeals;
  final String? currentChapter;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfilIsComplete,
    required this.senhaIsSeted,
    required this.totalSeals,
    this.currentChapter,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        perfilIsComplete,
        senhaIsSeted,
        totalSeals,
        currentChapter,
        createdAt,
        updatedAt,
      ];

  UserProfile copyWith({
    String? nome,
    String? email,
    bool? perfilIsComplete,
    bool? senhaIsSeted,
    int? totalSeals,
    String? currentChapter,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      perfilIsComplete: perfilIsComplete ?? this.perfilIsComplete,
      senhaIsSeted: senhaIsSeted ?? this.senhaIsSeted,
      totalSeals: totalSeals ?? this.totalSeals,
      currentChapter: currentChapter ?? this.currentChapter,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Chapter
class Chapter extends Equatable {
  final String id;
  final int chapterNumber;
  final String title;
  final String subtitle;
  final String content;
  final String summary;
  final int requiredSeals;
  final int estimatedTime;
  final ChapterDifficulty difficulty;
  final bool isPaidContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.summary,
    required this.requiredSeals,
    required this.estimatedTime,
    required this.difficulty,
    required this.isPaidContent,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        chapterNumber,
        title,
        subtitle,
        content,
        summary,
        requiredSeals,
        estimatedTime,
        difficulty,
        isPaidContent,
        createdAt,
        updatedAt,
      ];

  bool get isLocked => isPaidContent; // Simplified for now
}

enum ChapterDifficulty { easy, medium, hard }

// User Progress
class UserProgress extends Equatable {
  final String id;
  final String userId;
  final String chapterId;
  final ProgressStatus status;
  final double progressPercentage;
  final int timeSpent; // seconds
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.status,
    required this.progressPercentage,
    required this.timeSpent,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        chapterId,
        status,
        progressPercentage,
        timeSpent,
        startedAt,
        completedAt,
        lastAccessedAt,
        createdAt,
        updatedAt,
      ];

  UserProgress copyWith({
    ProgressStatus? status,
    double? progressPercentage,
    int? timeSpent,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      id: id,
      userId: userId,
      chapterId: chapterId,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      timeSpent: timeSpent ?? this.timeSpent,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ProgressStatus { notStarted, inProgress, completed }

// Seal
class Seal extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final String category;
  final SealRarity rarity;
  final int points;
  final DateTime createdAt;

  const Seal({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.category,
    required this.rarity,
    required this.points,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        iconUrl,
        category,
        rarity,
        points,
        createdAt,
      ];
}

enum SealRarity { common, rare, epic, legendary }

// User Seal
class UserSeal extends Equatable {
  final String id;
  final String userId;
  final String sealId;
  final DateTime unlockedAt;
  final String source;

  const UserSeal({
    required this.id,
    required this.userId,
    required this.sealId,
    required this.unlockedAt,
    required this.source,
  });

  @override
  List<Object?> get props => [id, userId, sealId, unlockedAt, source];
}

// User Reflection
class UserReflection extends Equatable {
  final String id;
  final String userId;
  final String chapterId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserReflection({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        chapterId,
        content,
        createdAt,
        updatedAt,
      ];

  UserReflection copyWith({
    String? content,
    DateTime? updatedAt,
  }) {
    return UserReflection(
      id: id,
      userId: userId,
      chapterId: chapterId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Journey Stage
class JourneyStage extends Equatable {
  final String id;
  final String userId;
  final StageType currentStage;
  final DateTime lastStageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JourneyStage({
    required this.id,
    required this.userId,
    required this.currentStage,
    required this.lastStageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        currentStage,
        lastStageAt,
        createdAt,
        updatedAt,
      ];

  JourneyStage copyWith({
    StageType? currentStage,
    DateTime? lastStageAt,
    DateTime? updatedAt,
  }) {
    return JourneyStage(
      id: id,
      userId: userId,
      currentStage: currentStage ?? this.currentStage,
      lastStageAt: lastStageAt ?? this.lastStageAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum StageType { entry, carta, transition, journey, preparation, chat }
```

#### Carta-Specific Models

```dart
// Text Block for Carta de um Órfão
class TextBlock extends Equatable {
  final String text;
  final Duration startTime;
  final Duration endTime;

  const TextBlock({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [text, startTime, endTime];

  bool isActiveAt(Duration position) {
    return position >= startTime && position < endTime;
  }
}

// Carta Sync State
class CartaSyncState extends Equatable {
  final List<TextBlock> textBlocks;
  final int currentBlockIndex;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? errorMessage;

  const CartaSyncState({
    required this.textBlocks,
    required this.currentBlockIndex,
    required this.isPlaying,
    required this.isBuffering,
    required this.isCompleted,
    required this.currentPosition,
    required this.totalDuration,
    this.errorMessage,
  });

  factory CartaSyncState.initial() {
    return CartaSyncState(
      textBlocks: const [],
      currentBlockIndex: 0,
      isPlaying: false,
      isBuffering: false,
      isCompleted: false,
      currentPosition: Duration.zero,
      totalDuration: Duration.zero,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        textBlocks,
        currentBlockIndex,
        isPlaying,
        isBuffering,
        isCompleted,
        currentPosition,
        totalDuration,
        errorMessage,
      ];

  CartaSyncState copyWith({
    List<TextBlock>? textBlocks,
    int? currentBlockIndex,
    bool? isPlaying,
    bool? isBuffering,
    bool? isCompleted,
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
  }) {
    return CartaSyncState(
      textBlocks: textBlocks ?? this.textBlocks,
      currentBlockIndex: currentBlockIndex ?? this.currentBlockIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isCompleted: isCompleted ?? this.isCompleted,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  TextBlock? get currentBlock {
    if (currentBlockIndex >= 0 && currentBlockIndex < textBlocks.length) {
      return textBlocks[currentBlockIndex];
    }
    return null;
  }

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }
}
```

### Data Transfer Objects (DTOs)

DTOs handle conversion between Supabase JSON and domain models.

```dart
// Profile DTO
class ProfileDto {
  final String id;
  final String? nome;
  final String? email;
  final bool? perfilIsComplete;
  final bool? senhaIsSeted;
  final int? totalSeals;
  final String? currentChapter;
  final String? createdAt;
  final String? updatedAt;

  ProfileDto({
    required this.id,
    this.nome,
    this.email,
    this.perfilIsComplete,
    this.senhaIsSeted,
    this.totalSeals,
    this.currentChapter,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      nome: json['nome'] as String?,
      email: json['email'] as String?,
      perfilIsComplete: json['perfil_is_complete'] as bool?,
      senhaIsSeted: json['senha_is_seted'] as bool?,
      totalSeals: json['total_seals'] as int?,
      currentChapter: json['current_chapter'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil_is_complete': perfilIsComplete,
      'senha_is_seted': senhaIsSeted,
      'total_seals': totalSeals,
      'current_chapter': currentChapter,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      nome: nome ?? '',
      email: email ?? '',
      perfilIsComplete: perfilIsComplete ?? false,
      senhaIsSeted: senhaIsSeted ?? true,
      totalSeals: totalSeals ?? 0,
      currentChapter: currentChapter,
      createdAt: DateTime.parse(createdAt ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(updatedAt ?? DateTime.now().toIso8601String()),
    );
  }
}

// Similar DTOs for Chapter, UserProgress, Seal, UserSeal, UserReflection, JourneyStage
```

### Repository Interfaces (Domain Layer)

```dart
abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
}

abstract class ChapterRepository {
  Future<List<Chapter>> getChapters();
  Future<Chapter?> getChapter(String chapterId);
}

abstract class ProgressRepository {
  Future<List<UserProgress>> getUserProgress(String userId);
  Future<void> updateProgress(UserProgress progress);
  Future<void> markChapterCompleted(String userId, String chapterId);
}

abstract class ReflectionRepository {
  Future<UserReflection?> getReflection(String userId, String chapterId);
  Future<void> saveReflection(UserReflection reflection);
}

abstract class SealRepository {
  Future<List<Seal>> getSeals();
  Future<List<UserSeal>> getUserSeals(String userId);
  Future<void> awardSeal(String userId, String sealId, String source);
}

abstract class JourneyStageRepository {
  Future<JourneyStage?> getJourneyStage(String userId);
  Future<void> updateJourneyStage(String userId, StageType stage);
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property-Based Testing Applicability

This system has **limited applicability** for property-based testing because:

1. **UI-Heavy**: Most requirements are about UI rendering, layout, and visual design
2. **Integration-Heavy**: Many features depend on external services (Supabase, audio playback)
3. **Experience-Focused**: Core value is emotional experience, not algorithmic correctness

However, there are specific areas where property-based testing adds value:

- **Audio-text synchronization logic** (pure function mapping position → block)
- **Chapter ordering** (sorting algorithm)
- **State transitions** (state machine logic)
- **Content parsing** (round-trip properties)
- **Error message transformation** (mapping function)

### Property 1: Audio Position to Text Block Mapping

*For any* audio position within the total duration and any list of text blocks with non-overlapping time ranges, the system SHALL return exactly one active text block or none if position is outside all ranges.

**Validates: Requirements 3.3, 3.4**

**Rationale**: The core of the Carta experience is synchronization. This property ensures that at any moment in the audio, we can deterministically find which text block should be displayed. The property tests the pure function logic without requiring actual audio playback.

**Test Strategy**:
- Generate random lists of TextBlock with valid time ranges
- Generate random audio positions
- Verify exactly 0 or 1 block is active at each position
- Verify no overlapping blocks are both active

### Property 2: Chapter Sequential Ordering

*For any* list of chapters with distinct chapter_numbers, sorting by chapter_number SHALL produce a list where each chapter's chapter_number is less than the next chapter's chapter_number.

**Validates: Requirements 4.3**

**Rationale**: Users must experience chapters in the correct order. This property ensures the ordering logic is correct regardless of how chapters are stored or retrieved from the database.

**Test Strategy**:
- Generate random lists of chapters with random chapter_numbers
- Sort by chapter_number
- Verify sorted list is in ascending order
- Verify all original chapters are present (no loss)

### Property 3: Progress Status Transition Validity

*For any* user progress record, transitioning from one status to another SHALL only allow valid state transitions: not_started → in_progress, in_progress → completed, and SHALL reject invalid transitions like completed → not_started.

**Validates: Requirements 7.2, 7.3**

**Rationale**: Progress tracking is a state machine. Invalid transitions could corrupt user data. This property ensures state machine rules are enforced.

**Test Strategy**:
- Generate random UserProgress records with different statuses
- Attempt all possible status transitions
- Verify only valid transitions succeed
- Verify invalid transitions are rejected with appropriate errors

### Property 4: Journey Stage Transition Validity

*For any* current journey stage and navigation action, the system SHALL only allow valid stage transitions according to the journey flow: entry → (carta OR preparation), carta → transition, transition → preparation, preparation → chat.

**Validates: Requirements 23.2, 23.3, 23.4, 23.5, 23.6**

**Rationale**: The journey has a specific flow. Users can skip Carta (entry → preparation) but cannot go backwards from Transition to Carta. This property ensures the state machine respects these rules.

**Test Strategy**:
- Generate random current stages
- Attempt all possible stage transitions
- Verify valid transitions succeed (entry → carta, entry → preparation, carta → transition, transition → preparation, preparation → chat)
- Verify invalid transitions are rejected (transition → carta, preparation → entry, etc.)

### Property 5: Error Message Localization

*For any* exception type in the system, the error handling service SHALL return a non-empty Portuguese error message.

**Validates: Requirements 17.1, 17.2, 17.3, 17.4**

**Rationale**: All users see errors in Portuguese. This property ensures no error type falls through to English or technical messages.

**Test Strategy**:
- Generate random exception types (NetworkException, AuthException, etc.)
- Call getUserFriendlyMessage for each
- Verify returned message is non-empty
- Verify returned message contains Portuguese characters/words
- Verify no English technical terms appear

### Property 6: Content Parser Round-Trip

*For any* valid markdown content string, parsing the content and then rendering it back to string SHALL preserve the semantic structure (headings, paragraphs, lists, emphasis).

**Validates: Requirements 18.1, 18.2, 18.3, 18.10**

**Rationale**: Chapter content must be displayed correctly. Round-trip testing ensures the parser and renderer are inverses of each other, catching bugs in either direction.

**Test Strategy**:
- Generate random valid markdown strings (headings, paragraphs, lists, bold, italic)
- Parse to AST
- Render back to string
- Verify semantic equivalence (structure preserved, whitespace normalized)

### Property 7: Seal Unlock Condition Evaluation

*For any* user progress state and seal unlock condition, evaluating the condition SHALL return a deterministic boolean result that does not change unless the progress state changes.

**Validates: Requirements 8.1, 8.2**

**Rationale**: Seal unlocking must be consistent and deterministic. The same progress state should always produce the same unlock decision.

**Test Strategy**:
- Generate random user progress states (chapters completed, time spent, etc.)
- Generate random seal unlock conditions (e.g., "complete 5 chapters", "spend 30 minutes")
- Evaluate condition multiple times with same state
- Verify result is always the same (deterministic)
- Verify result changes appropriately when state changes

### Property 8: Text Block Advance on Tap

*For any* current block index less than the total number of blocks minus one, tapping to advance SHALL increment the block index by exactly one.

**Validates: Requirements 3.6**

**Rationale**: Tap interaction must reliably advance through text blocks. This property ensures the advance logic is correct at all positions.

**Test Strategy**:
- Generate random current block indices
- Generate random total block counts
- Call advance function
- Verify index increments by 1 when not at end
- Verify index stays at end when already at last block

### Property Reflection

After reviewing all identified properties, I note:

- **Property 1 and Property 8** both relate to text block navigation but test different aspects (position-based lookup vs. tap-based advance). Both provide unique value.
- **Property 3 and Property 4** both test state transitions but for different state machines (progress status vs. journey stage). Both are necessary.
- **Property 2** (chapter ordering) could be considered redundant if we trust the sorting algorithm, but it validates our usage of the algorithm is correct.
- **Property 6** (round-trip) is essential for any parser/renderer pair.

All properties provide unique validation value and should be retained.

### Testing Strategy Note

The properties above focus on **pure business logic** that can be tested without UI or external dependencies. The majority of this system's testing will be:

- **Widget tests** for UI components (60% of tests)
- **Integration tests** for Supabase and audio (30% of tests)
- **Property-based tests** for business logic (10% of tests)

This distribution reflects the UI-heavy nature of the application while ensuring critical business logic is thoroughly validated.



## Error Handling

### Error Handling Strategy

The system implements a **layered error handling approach**:

1. **Domain Layer**: Throws typed exceptions for business rule violations
2. **Data Layer**: Catches and wraps external service errors
3. **Presentation Layer**: Displays user-friendly messages and provides recovery options

### Error Types

```dart
// Base error class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
}

// Network errors
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Authentication errors
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Data errors
class DataException extends AppException {
  DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Audio playback errors
class AudioException extends AppException {
  AudioException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Content parsing errors
class ContentParseException extends AppException {
  ContentParseException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Business logic errors
class BusinessLogicException extends AppException {
  BusinessLogicException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
```

### Error Handling Service

```dart
class ErrorHandlingService {
  final AnalyticsService _analytics;
  final Logger _logger;

  ErrorHandlingService({
    required AnalyticsService analytics,
    required Logger logger,
  })  : _analytics = analytics,
        _logger = logger;

  /// Convert exception to user-friendly Portuguese message
  String getUserFriendlyMessage(Exception error) {
    if (error is NetworkException) {
      return "Problema de conexão. Verifique sua internet e tente novamente.";
    }
    
    if (error is AuthException) {
      if (error.code == 'invalid_credentials') {
        return "Email ou senha incorretos. Tente novamente.";
      }
      if (error.code == 'email_already_exists') {
        return "Este email já está cadastrado. Faça login ou use outro email.";
      }
      if (error.code == 'weak_password') {
        return "Senha muito fraca. Use pelo menos 8 caracteres.";
      }
      return "Erro de autenticação. Tente novamente.";
    }
    
    if (error is DataException) {
      return "Não foi possível salvar seus dados. Tente novamente.";
    }
    
    if (error is AudioException) {
      return "Erro ao carregar o áudio. Verifique sua conexão.";
    }
    
    if (error is ContentParseException) {
      return "Erro ao carregar o conteúdo. Tente novamente mais tarde.";
    }
    
    if (error is BusinessLogicException) {
      return error.message; // Business logic errors are already user-friendly
    }
    
    // Fallback for unknown errors
    return "Algo deu errado. Tente novamente.";
  }

  /// Log error for debugging
  void logError(
    Exception error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    _logger.error(
      error.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    
    _analytics.trackError(
      error.toString(),
      stackTrace,
      context: context,
    );
  }

  /// Handle error with user feedback
  Future<void> handleError(
    Exception error,
    StackTrace? stackTrace, {
    required BuildContext context,
    VoidCallback? onRetry,
  }) async {
    // Log error
    logError(error, stackTrace);
    
    // Get user-friendly message
    final message = getUserFriendlyMessage(error);
    
    // Show error to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Tentar novamente',
                  onPressed: onRetry,
                  textColor: Colors.white,
                )
              : null,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
```

### Error Handling in Repositories

```dart
class ChapterRepositoryImpl implements ChapterRepository {
  final SupabaseClient _supabase;
  final ErrorHandlingService _errorHandler;

  @override
  Future<List<Chapter>> getChapters() async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .order('chapter_number');
      
      return response
          .map((json) => ChapterDto.fromJson(json).toDomain())
          .toList();
    } on PostgrestException catch (e, stackTrace) {
      _errorHandler.logError(
        DataException(
          message: 'Failed to load chapters',
          code: e.code,
          originalError: e,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
      rethrow;
    } on SocketException catch (e, stackTrace) {
      throw NetworkException(
        message: 'Network error while loading chapters',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DataException(
        message: 'Unexpected error loading chapters',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
```

### Error Handling in Providers

```dart
@riverpod
class ChaptersNotifier extends _$ChaptersNotifier {
  @override
  Future<List<Chapter>> build() async {
    final repository = ref.read(chapterRepositoryProvider);
    
    try {
      return await repository.getChapters();
    } catch (e, stackTrace) {
      ref.read(errorHandlingServiceProvider).logError(
        e as Exception,
        stackTrace,
      );
      rethrow; // Let AsyncValue handle the error state
    }
  }
}
```

### Error Handling in UI

```dart
class ChapterListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersNotifierProvider);
    
    return chaptersAsync.when(
      data: (chapters) => ChapterList(chapters: chapters),
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) {
        final errorService = ref.read(errorHandlingServiceProvider);
        final message = errorService.getUserFriendlyMessage(error as Exception);
        
        return ErrorView(
          message: message,
          onRetry: () => ref.invalidate(chaptersNotifierProvider),
        );
      },
    );
  }
}
```

### Offline Error Handling

```dart
class OfflineQueueService {
  final List<PendingOperation> _queue = [];
  
  /// Queue operation for later execution
  void queueOperation(PendingOperation operation) {
    _queue.add(operation);
  }
  
  /// Retry queued operations when online
  Future<void> retryQueuedOperations() async {
    final operations = List<PendingOperation>.from(_queue);
    _queue.clear();
    
    for (final operation in operations) {
      try {
        await operation.execute();
      } catch (e, stackTrace) {
        // Re-queue if still failing
        _queue.add(operation);
        
        // Log error
        ref.read(errorHandlingServiceProvider).logError(
          e as Exception,
          stackTrace,
          context: {'operation': operation.type},
        );
      }
    }
  }
}

class PendingOperation {
  final String type;
  final Future<void> Function() execute;
  
  PendingOperation({
    required this.type,
    required this.execute,
  });
}
```

### Critical Error Scenarios

**Scenario 1: Audio Fails to Load**
- **Error**: AudioException
- **User Message**: "Erro ao carregar o áudio. Verifique sua conexão."
- **Recovery**: Offer text-only mode, retry button
- **Fallback**: Display text blocks without audio synchronization

**Scenario 2: Network Disconnection During Chapter**
- **Error**: NetworkException
- **User Message**: "Conexão perdida. Seu progresso será salvo quando voltar online."
- **Recovery**: Queue progress updates, continue with cached content
- **Fallback**: Offline mode with local cache

**Scenario 3: Authentication Session Expired**
- **Error**: AuthException
- **User Message**: "Sua sessão expirou. Faça login novamente."
- **Recovery**: Automatic session refresh, redirect to login if refresh fails
- **Fallback**: Save current state, restore after re-authentication

**Scenario 4: Content Parse Error**
- **Error**: ContentParseException
- **User Message**: "Erro ao carregar o conteúdo. Tente novamente mais tarde."
- **Recovery**: Retry with exponential backoff, contact support if persistent
- **Fallback**: Display raw content or placeholder

**Scenario 5: Seal Unlock Fails**
- **Error**: DataException
- **User Message**: "Não foi possível desbloquear o selo. Tente novamente."
- **Recovery**: Retry seal unlock, queue for later if offline
- **Fallback**: User can continue journey, seal will unlock when operation succeeds



## Testing Strategy

### Overview

The testing strategy reflects the nature of this application: **UI-heavy, integration-heavy, with critical business logic**. The distribution is:

- **60% Widget Tests**: UI components, interactions, visual behavior
- **30% Integration Tests**: Supabase, audio, navigation, offline behavior
- **10% Unit Tests**: Business logic, state management, utilities

Property-based testing is used selectively for pure business logic (audio-text sync, state transitions, content parsing).

### Testing Pyramid

```
                    /\
                   /  \
                  / E2E \
                 /  (5%) \
                /----------\
               /            \
              /  Integration \
             /     (30%)      \
            /------------------\
           /                    \
          /   Widget + Unit      \
         /        (65%)           \
        /--------------------------\
```

### Unit Tests

**Scope**: Pure business logic, utilities, state management

**Tools**:
- `flutter_test` for standard unit tests
- `mockito` or `mocktail` for mocking
- `fast_check` (Dart port) or custom generators for property-based tests

**Coverage**:
- Domain models (equality, copyWith, serialization)
- Use cases (business logic)
- Utilities (error handling, content parsing)
- State notifiers (state transitions)
- Repository interfaces (mocked)

**Property-Based Tests** (minimum 100 iterations each):

```dart
// Property 1: Audio Position to Text Block Mapping
test('Property 1: Audio position maps to correct text block', () {
  fc.assert(
    fc.property(
      fc.list(textBlockArbitrary, minLength: 1, maxLength: 20),
      fc.duration(max: Duration(minutes: 10)),
      (blocks, position) {
        // Feature: JornadaDeusePai, Property 1: Audio position to text block mapping
        final activeBlocks = blocks.where((b) => b.isActiveAt(position)).toList();
        expect(activeBlocks.length, lessThanOrEqualTo(1));
      },
    ),
    numRuns: 100,
  );
});

// Property 2: Chapter Sequential Ordering
test('Property 2: Chapters are ordered by chapter_number', () {
  fc.assert(
    fc.property(
      fc.list(chapterArbitrary, minLength: 2, maxLength: 50),
      (chapters) {
        // Feature: JornadaDeusePai, Property 2: Chapter sequential ordering
        final sorted = List<Chapter>.from(chapters)
          ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
        
        for (int i = 0; i < sorted.length - 1; i++) {
          expect(sorted[i].chapterNumber, lessThan(sorted[i + 1].chapterNumber));
        }
      },
    ),
    numRuns: 100,
  );
});

// Property 3: Progress Status Transition Validity
test('Property 3: Only valid progress status transitions are allowed', () {
  fc.assert(
    fc.property(
      fc.progressStatusArbitrary,
      fc.progressStatusArbitrary,
      (fromStatus, toStatus) {
        // Feature: JornadaDeusePai, Property 3: Progress status transition validity
        final isValid = _isValidTransition(fromStatus, toStatus);
        
        if (isValid) {
          expect(() => transitionStatus(fromStatus, toStatus), returnsNormally);
        } else {
          expect(() => transitionStatus(fromStatus, toStatus), throwsA(isA<BusinessLogicException>()));
        }
      },
    ),
    numRuns: 100,
  );
});

// Property 4: Journey Stage Transition Validity
test('Property 4: Only valid journey stage transitions are allowed', () {
  fc.assert(
    fc.property(
      fc.stageTypeArbitrary,
      fc.stageTypeArbitrary,
      (fromStage, toStage) {
        // Feature: JornadaDeusePai, Property 4: Journey stage transition validity
        final isValid = _isValidStageTransition(fromStage, toStage);
        
        if (isValid) {
          expect(() => transitionStage(fromStage, toStage), returnsNormally);
        } else {
          expect(() => transitionStage(fromStage, toStage), throwsA(isA<BusinessLogicException>()));
        }
      },
    ),
    numRuns: 100,
  );
});

// Property 5: Error Message Localization
test('Property 5: All errors return Portuguese messages', () {
  fc.assert(
    fc.property(
      fc.exceptionArbitrary,
      (exception) {
        // Feature: JornadaDeusePai, Property 5: Error message localization
        final service = ErrorHandlingService();
        final message = service.getUserFriendlyMessage(exception);
        
        expect(message, isNotEmpty);
        expect(message, isNot(contains(RegExp(r'[A-Z]{2,}')))); // No ALL_CAPS error codes
        // Could add more sophisticated Portuguese detection
      },
    ),
    numRuns: 100,
  );
});

// Property 6: Content Parser Round-Trip
test('Property 6: Parse then render preserves structure', () {
  fc.assert(
    fc.property(
      fc.markdownArbitrary,
      (markdown) {
        // Feature: JornadaDeusePai, Property 6: Content parser round-trip
        final parser = ContentParser();
        final ast = parser.parse(markdown);
        final rendered = parser.render(ast);
        
        // Semantic equivalence (structure preserved, whitespace normalized)
        expect(normalizeWhitespace(rendered), equals(normalizeWhitespace(markdown)));
      },
    ),
    numRuns: 100,
  );
});

// Property 7: Seal Unlock Condition Evaluation
test('Property 7: Seal unlock is deterministic', () {
  fc.assert(
    fc.property(
      fc.userProgressStateArbitrary,
      fc.sealConditionArbitrary,
      (progressState, condition) {
        // Feature: JornadaDeusePai, Property 7: Seal unlock condition evaluation
        final result1 = evaluateSealCondition(progressState, condition);
        final result2 = evaluateSealCondition(progressState, condition);
        
        expect(result1, equals(result2)); // Deterministic
      },
    ),
    numRuns: 100,
  );
});

// Property 8: Text Block Advance on Tap
test('Property 8: Tap advances block index correctly', () {
  fc.assert(
    fc.property(
      fc.integer(min: 0, max: 100),
      fc.integer(min: 1, max: 100),
      (currentIndex, totalBlocks) {
        // Feature: JornadaDeusePai, Property 8: Text block advance on tap
        final newIndex = advanceBlock(currentIndex, totalBlocks);
        
        if (currentIndex < totalBlocks - 1) {
          expect(newIndex, equals(currentIndex + 1));
        } else {
          expect(newIndex, equals(currentIndex)); // Stay at end
        }
      },
    ),
    numRuns: 100,
  );
});
```

### Widget Tests

**Scope**: UI components, user interactions, visual behavior

**Tools**:
- `flutter_test` for widget testing
- `golden_toolkit` for visual regression tests
- `mockito` for mocking dependencies

**Coverage**:
- All screens (Entry, Carta, Transition, Journey, Preparation)
- All reusable widgets
- User interactions (tap, hold, scroll)
- Visual states (loading, error, success)
- Responsive layouts (mobile, tablet, desktop)
- Accessibility (semantic labels, contrast, touch targets)

**Example Widget Tests**:

```dart
// Entry Screen
testWidgets('Entry screen displays two navigation buttons', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: EntryScreen()),
    ),
  );
  
  expect(find.text('Começar pela raiz'), findsOneWidget);
  expect(find.text('Ir direto falar com o Pai'), findsOneWidget);
});

testWidgets('Primary button is visually prominent', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: EntryScreen()),
    ),
  );
  
  final primaryButton = find.text('Começar pela raiz');
  final secondaryButton = find.text('Ir direto falar com o Pai');
  
  final primarySize = tester.getSize(primaryButton);
  final secondarySize = tester.getSize(secondaryButton);
  
  expect(primarySize.height, greaterThan(secondarySize.height));
});

// Carta Screen
testWidgets('Carta screen displays text blocks progressively', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cartaSyncNotifierProvider.overrideWith((ref) => MockCartaSyncNotifier()),
      ],
      child: MaterialApp(home: CartaScreen()),
    ),
  );
  
  // Initially shows first block
  expect(find.text('First block text'), findsOneWidget);
  expect(find.text('Second block text'), findsNothing);
  
  // Advance to next block
  await tester.tap(find.byType(CartaScreen));
  await tester.pumpAndSettle();
  
  expect(find.text('Second block text'), findsOneWidget);
});

testWidgets('Carta screen does not show media controls', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: CartaScreen()),
    ),
  );
  
  expect(find.byIcon(Icons.play_arrow), findsNothing);
  expect(find.byIcon(Icons.pause), findsNothing);
  expect(find.byType(Slider), findsNothing); // No timeline slider
});

// Transition Screen
testWidgets('Transition screen displays two-part message', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: TransitionScreen()),
    ),
  );
  
  // First part appears immediately
  expect(find.textContaining('nunca tenha sido apresentado'), findsOneWidget);
  
  // Wait for pause
  await tester.pump(Duration(seconds: 2));
  
  // Second part appears
  expect(find.textContaining('pode começar agora'), findsOneWidget);
});

testWidgets('Transition screen has only one button', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: TransitionScreen()),
    ),
  );
  
  final buttons = find.byType(ElevatedButton);
  expect(buttons, findsOneWidget);
  expect(find.text('Falar com o Pai pela primeira vez'), findsOneWidget);
});

// Journey Screen
testWidgets('Journey screen displays chapters in order', (tester) async {
  final mockChapters = [
    Chapter(id: '1', chapterNumber: 1, title: 'Chapter 1', ...),
    Chapter(id: '2', chapterNumber: 2, title: 'Chapter 2', ...),
    Chapter(id: '3', chapterNumber: 3, title: 'Chapter 3', ...),
  ];
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        chaptersNotifierProvider.overrideWith((ref) => mockChapters),
      ],
      child: MaterialApp(home: JourneyScreen()),
    ),
  );
  
  expect(find.text('Chapter 1'), findsOneWidget);
  expect(find.text('Chapter 2'), findsOneWidget);
  expect(find.text('Chapter 3'), findsOneWidget);
});

// Accessibility Tests
testWidgets('All interactive elements have minimum touch target size', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: EntryScreen()),
    ),
  );
  
  final buttons = find.byType(ElevatedButton);
  for (final button in buttons.evaluate()) {
    final size = tester.getSize(find.byWidget(button.widget));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  }
});

testWidgets('Screen reader labels are present', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: EntryScreen()),
    ),
  );
  
  final semantics = tester.getSemantics(find.text('Começar pela raiz'));
  expect(semantics.label, isNotEmpty);
});
```

### Integration Tests

**Scope**: External services, navigation, offline behavior, end-to-end flows

**Tools**:
- `integration_test` package
- `flutter_driver` for E2E tests
- Supabase test instance
- Mocked audio files

**Coverage**:
- Authentication flow (signup, login, logout)
- Chapter loading from Supabase
- Progress tracking and persistence
- Reflection save and retrieval
- Seal unlock and award
- Audio playback and synchronization
- Offline mode and sync
- Navigation flows

**Example Integration Tests**:

```dart
// Authentication Flow
testWidgets('User can sign up and profile is created', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to signup
  await tester.tap(find.text('Criar conta'));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  await tester.enterText(find.byKey(Key('name')), 'Test User');
  
  // Submit
  await tester.tap(find.text('Cadastrar'));
  await tester.pumpAndSettle();
  
  // Verify profile created in Supabase
  final profile = await supabase.from('profiles').select().eq('email', 'test@example.com').single();
  expect(profile['nome'], equals('Test User'));
});

// Chapter Loading
testWidgets('Chapters load from Supabase in correct order', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Login
  await loginUser(tester, 'test@example.com', 'password123');
  
  // Navigate to journey
  await tester.tap(find.text('Jornada'));
  await tester.pumpAndSettle();
  
  // Verify chapters displayed in order
  final chapterTitles = find.byType(Text).evaluate()
    .map((e) => (e.widget as Text).data)
    .where((text) => text?.startsWith('Capítulo') ?? false)
    .toList();
  
  expect(chapterTitles, equals(['Capítulo 1', 'Capítulo 2', 'Capítulo 3']));
});

// Progress Tracking
testWidgets('Chapter completion updates progress in Supabase', (tester) async {
  await tester.pumpWidget(MyApp());
  await loginUser(tester, 'test@example.com', 'password123');
  
  // Open chapter
  await tester.tap(find.text('Capítulo 1'));
  await tester.pumpAndSettle();
  
  // Complete chapter
  await tester.tap(find.text('Próximo Capítulo'));
  await tester.pumpAndSettle();
  
  // Verify progress in Supabase
  final progress = await supabase
    .from('user_progress')
    .select()
    .eq('chapter_id', 'chapter-1-id')
    .single();
  
  expect(progress['status'], equals('completed'));
  expect(progress['completed_at'], isNotNull);
});

// Offline Mode
testWidgets('App works offline with cached content', (tester) async {
  await tester.pumpWidget(MyApp());
  await loginUser(tester, 'test@example.com', 'password123');
  
  // Load chapter while online
  await tester.tap(find.text('Capítulo 1'));
  await tester.pumpAndSettle();
  
  // Go offline
  await setNetworkConnectivity(false);
  
  // Navigate back and forth
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('Capítulo 1'));
  await tester.pumpAndSettle();
  
  // Verify content still displays
  expect(find.text('Capítulo 1'), findsOneWidget);
  expect(find.byType(LoadingIndicator), findsNothing);
});

// Audio Synchronization
testWidgets('Audio and text stay synchronized', (tester) async {
  await tester.pumpWidget(MyApp());
  await loginUser(tester, 'test@example.com', 'password123');
  
  // Navigate to Carta
  await tester.tap(find.text('Começar pela raiz'));
  await tester.pumpAndSettle();
  
  // Wait for audio to start
  await tester.pump(Duration(seconds: 1));
  
  // Verify first block is displayed
  expect(find.text('First block text'), findsOneWidget);
  
  // Wait for second block timing
  await tester.pump(Duration(seconds: 5));
  
  // Verify second block is displayed
  expect(find.text('Second block text'), findsOneWidget);
  expect(find.text('First block text'), findsNothing);
});
```

### Test Coverage Goals

- **Overall**: Minimum 80% code coverage
- **Business Logic**: Minimum 90% coverage
- **UI Components**: Minimum 70% coverage
- **Integration Points**: Minimum 80% coverage

### Continuous Integration

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Run widget tests
        run: flutter test test/widget_test
      
      - name: Run integration tests
        run: flutter test integration_test
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Manual Testing Checklist

**Emotional Experience**:
- [ ] Entry screen creates emotional connection
- [ ] Carta feels like "someone speaking to me"
- [ ] Transition screen creates moment of decision
- [ ] Preparation screen reinforces identity
- [ ] Overall flow feels natural and guided

**Golden Rule Validation**:
- [ ] Users have technical freedom at all points
- [ ] Primary paths are emotionally desirable
- [ ] No dark patterns or forced behaviors
- [ ] Visual hierarchy guides without blocking
- [ ] Conversion rates validate emotional guidance

**Cross-Browser Testing**:
- [ ] Chrome (desktop and mobile)
- [ ] Safari (desktop and mobile)
- [ ] Firefox
- [ ] Edge

**Accessibility Testing**:
- [ ] Screen reader navigation (NVDA, JAWS, VoiceOver)
- [ ] Keyboard-only navigation
- [ ] Color contrast validation
- [ ] Touch target sizes
- [ ] Font scaling

**Performance Testing**:
- [ ] Initial load time < 3s on 3G
- [ ] Smooth 60fps animations
- [ ] Audio loads without blocking UI
- [ ] Offline mode works correctly
- [ ] Memory usage stays reasonable



## Design System

### Color Palette

```dart
class AppColors {
  // Primary - Warm Gold/Amber (emotional warmth, divine light)
  static const primary = Color(0xFFD4AF37); // Gold
  static const primaryLight = Color(0xFFE5C158);
  static const primaryDark = Color(0xFFB8941F);
  
  // Secondary - Soft Blue (peace, trust, spiritual depth)
  static const secondary = Color(0xFF5B9BD5);
  static const secondaryLight = Color(0xFF7FB3E3);
  static const secondaryDark = Color(0xFF3D7AB8);
  
  // Background - Dark (immersive, focused)
  static const background = Color(0xFF0A0A0A); // Near black
  static const backgroundElevated = Color(0xFF1A1A1A);
  
  // Surface - Dark Gray (cards, elevated content)
  static const surface = Color(0xFF1E1E1E);
  static const surfaceElevated = Color(0xFF2A2A2A);
  
  // Text
  static const textPrimary = Color(0xFFFFFFFF); // White
  static const textSecondary = Color(0xFFB0B0B0); // Light gray
  static const textTertiary = Color(0xFF707070); // Medium gray
  
  // Error - Soft Red (gentle, not alarming)
  static const error = Color(0xFFE57373);
  static const errorDark = Color(0xFFD32F2F);
  
  // Success - Soft Green
  static const success = Color(0xFF81C784);
  
  // Accent - Warm tones for highlights
  static const accentWarm = Color(0xFFFFB74D); // Warm orange
  static const accentCool = Color(0xFF64B5F6); // Cool blue
}
```

### Typography

```dart
class AppTypography {
  static const fontFamily = 'Inter'; // Or 'Lora' for more emotional feel
  
  // Display - Large emotional statements
  static const display = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  // H1 - Main headings
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  // H2 - Section headings
  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // H3 - Subsection headings
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body - Main content
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  );
  
  // Body Large - Emphasized content
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  );
  
  // Caption - Small text, metadata
  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  // Button - Button text
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // Quote - Spiritual quotes, emphasis
  static const quote = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.7,
    letterSpacing: 0.15,
  );
}
```

### Spacing Scale

```dart
class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
}
```

### Border Radius

```dart
class AppRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const full = 9999.0; // Fully rounded
}
```

### Shadows and Elevation

```dart
class AppShadows {
  static const sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const md = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const lg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

### Animations

```dart
class AppAnimations {
  // Duration
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  
  // Curves
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const emotional = Curves.easeInOutCubic; // Smooth, emotional feel
  
  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = emotional,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Slide up animation
  static Widget slideUp({
    required Widget child,
    Duration duration = normal,
    Curve curve = emotional,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 20.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: child,
    );
  }
}
```

### Theme Configuration

```dart
ThemeData createAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // Typography
    textTheme: TextTheme(
      displayLarge: AppTypography.display.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTypography.h1.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTypography.h2.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTypography.h3.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTypography.body.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimary),
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 0,
        textStyle: AppTypography.button,
      ),
    ),
    
    // Card theme
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.all(AppSpacing.md),
    ),
  );
}
```

### Responsive Breakpoints

```dart
class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const desktop = 1440.0;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}
```

## Navigation and Routing

### Route Structure

```dart
// Route paths
class AppRoutes {
  static const entry = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const carta = '/carta';
  static const transition = '/transition';
  static const journey = '/journey';
  static const chapter = '/journey/:chapterId';
  static const preparation = '/preparation';
  static const chat = '/chat';
  static const profile = '/profile';
}

// Router configuration
final router = GoRouter(
  initialLocation: AppRoutes.entry,
  redirect: (context, state) {
    final authState = ref.read(authNotifierProvider);
    final isAuthenticated = authState.value != null;
    
    // Redirect to login if not authenticated
    if (!isAuthenticated && state.location != AppRoutes.login && state.location != AppRoutes.signup) {
      return AppRoutes.login;
    }
    
    return null; // No redirect
  },
  routes: [
    GoRoute(
      path: AppRoutes.entry,
      builder: (context, state) => const EntryScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.carta,
      builder: (context, state) => const CartaScreen(),
    ),
    GoRoute(
      path: AppRoutes.transition,
      builder: (context, state) => const TransitionScreen(),
    ),
    GoRoute(
      path: AppRoutes.journey,
      builder: (context, state) => const JourneyScreen(),
      routes: [
        GoRoute(
          path: ':chapterId',
          builder: (context, state) {
            final chapterId = state.pathParameters['chapterId']!;
            return ChapterScreen(chapterId: chapterId);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.preparation,
      builder: (context, state) => const PreparationScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatScreen(), // Out of scope
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
```

### Navigation Flows

**Flow 1: Root Journey Path**
```
Entry → Carta → Transition → Preparation → Chat
```

**Flow 2: Direct Path**
```
Entry → Preparation → Chat
```

**Flow 3: Journey System Path (Future)**
```
Entry → Journey (chapter list) → Chapter → Next Chapter → ...
```

### Navigation Guards

```dart
// Prevent back navigation from Transition to Carta
class TransitionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        body: TransitionContent(),
      ),
    );
  }
}

// Prevent access to locked chapters
GoRoute(
  path: ':chapterId',
  redirect: (context, state) {
    final chapterId = state.pathParameters['chapterId']!;
    final chapter = ref.read(chapterProvider(chapterId)).value;
    final hasAccess = ref.read(chapterAccessProvider(chapterId)).value ?? false;
    
    if (chapter?.isPaidContent == true && !hasAccess) {
      return AppRoutes.journey; // Redirect to chapter list
    }
    
    return null;
  },
  builder: (context, state) {
    final chapterId = state.pathParameters['chapterId']!;
    return ChapterScreen(chapterId: chapterId);
  },
),
```

### Deep Linking

```dart
// Support deep links for specific chapters
// Example: jornada://chapter/chapter-1-id

// Configure in AndroidManifest.xml and Info.plist
// Handle in router configuration
```

## Implementation Notes

### Migration from Next.js

**Phase 1: Setup and Infrastructure**
1. Create Flutter project with web support
2. Configure Supabase client
3. Set up Riverpod providers
4. Implement authentication
5. Create design system (theme, colors, typography)

**Phase 2: Core Features**
1. Entry Screen
2. Authentication screens (login, signup)
3. Carta de um Órfão (audio-text sync)
4. Transition Screen
5. Preparation Screen

**Phase 3: Journey System**
1. Chapter loading and display
2. Progress tracking
3. Reflection input
4. Chapter navigation

**Phase 4: Additional Features**
1. Seal system
2. Profile management
3. Offline support
4. Analytics integration

**Phase 5: Polish and Optimization**
1. Performance optimization
2. Accessibility improvements
3. Visual polish
4. Testing and bug fixes

### Database Migration

**New Tables to Create**:
```sql
-- user_reflections
CREATE TABLE user_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);

-- user_journey_stage
CREATE TABLE user_journey_stage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  current_stage TEXT CHECK (current_stage IN ('entry', 'carta', 'transition', 'journey', 'preparation', 'chat')),
  last_stage_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- user_purchased_content
CREATE TABLE user_purchased_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content_type TEXT CHECK (content_type IN ('chapter', 'book', 'bundle')),
  content_id TEXT NOT NULL,
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  payment_method TEXT,
  amount DECIMAL(10,2),
  currency TEXT DEFAULT 'BRL',
  UNIQUE(user_id, content_type, content_id)
);
```

**Schema Updates**:
```sql
-- Add is_paid_content to chapters
ALTER TABLE chapters ADD COLUMN is_paid_content BOOLEAN DEFAULT FALSE;

-- Update user_progress to use enum status
ALTER TABLE user_progress 
  ALTER COLUMN status TYPE TEXT,
  ADD CONSTRAINT status_check CHECK (status IN ('not_started', 'in_progress', 'completed'));
```

### Audio Content Preparation

**Carta de um Órfão Audio**:
- Format: MP3 or AAC
- Bitrate: 128kbps (balance quality and size)
- Host: Supabase Storage or CDN
- Metadata: Include text block timestamps in separate JSON

**Text Block Timing File** (JSON):
```json
{
  "audioUrl": "https://storage.supabase.co/carta-audio.mp3",
  "totalDuration": 600,
  "blocks": [
    {
      "text": "First block text...",
      "startTime": 0,
      "endTime": 15
    },
    {
      "text": "Second block text...",
      "startTime": 15,
      "endTime": 32
    }
    // ... more blocks
  ]
}
```

### Performance Optimization

**Code Splitting**:
- Lazy load features not needed immediately
- Use deferred imports for heavy dependencies

**Asset Optimization**:
- Compress images (WebP format)
- Use responsive images (different sizes for mobile/desktop)
- Lazy load images below the fold

**Caching Strategy**:
- Cache chapters locally after first load
- Cache user progress
- Cache audio files for offline playback
- Use service worker for PWA capabilities

**Bundle Size**:
- Target: < 2MB initial bundle
- Use tree shaking
- Remove unused dependencies
- Analyze bundle with `flutter build web --analyze-size`

### Accessibility Checklist

- [ ] All images have alt text
- [ ] All interactive elements have semantic labels
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Touch targets are minimum 48x48 logical pixels
- [ ] Keyboard navigation works for all interactions
- [ ] Focus indicators are visible
- [ ] Screen reader announces state changes
- [ ] Form inputs have labels
- [ ] Error messages are announced
- [ ] Loading states are announced

### Security Considerations

**Authentication**:
- Use Supabase Auth (secure by default)
- Implement session refresh
- Clear sensitive data on logout

**Data Access**:
- Enforce RLS policies in Supabase
- Validate user access to paid content
- Never trust client-side checks alone

**Content Security**:
- Sanitize user input (reflections)
- Prevent XSS in markdown rendering
- Use Content Security Policy headers

**API Keys**:
- Store Supabase keys in environment variables
- Use anon key for client (not service role key)
- Rotate keys if compromised

### Monitoring and Analytics

**Key Metrics**:
- User journey completion rate (Entry → Carta → Transition → Preparation)
- Carta completion rate
- Transition button click rate (conversion)
- Chapter completion rate
- Seal unlock rate
- Time spent per screen
- Error rates
- Performance metrics (load time, FPS)

**Analytics Events**:
```dart
// Screen views
analytics.trackScreenView('entry');
analytics.trackScreenView('carta');
analytics.trackScreenView('transition');

// User actions
analytics.trackEvent('navigation_choice', {'choice': 'raiz'}); // or 'direto'
analytics.trackEvent('transition_button_click');
analytics.trackEvent('chapter_completed', {'chapterId': 'chapter-1'});
analytics.trackEvent('seal_unlocked', {'sealId': 'seal-1'});
analytics.trackEvent('reflection_saved', {'chapterId': 'chapter-1'});

// Audio events
analytics.trackEvent('audio_play', {'source': 'carta'});
analytics.trackEvent('audio_pause', {'position': 45});
analytics.trackEvent('audio_complete');

// Errors
analytics.trackError('audio_load_failed', stackTrace);
```

### Deployment

**Hosting Options**:
1. **Firebase Hosting** (recommended)
   - Easy deployment
   - CDN included
   - Custom domain support
   - SSL included

2. **Vercel**
   - Git-based deployment
   - Preview deployments
   - Edge network

3. **Netlify**
   - Similar to Vercel
   - Good for static sites

**Environment Configuration**:
```dart
// lib/config/environment.dart
class Environment {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const analyticsKey = String.fromEnvironment('ANALYTICS_KEY');
  
  static bool get isProduction => const bool.fromEnvironment('PRODUCTION');
}
```

**Build Command**:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRODUCTION=true
```

### Future Enhancements

**Phase 2 Features** (Post-Launch):
- Payment integration for Livro 2
- Social sharing of seals
- Community features
- Push notifications
- Mobile app (iOS/Android) using same codebase
- Integration into No Secreto app

**Monetization**:
- Livro 2 (Journey System) as paid content
- One-time purchase or subscription
- Payment providers: Stripe, Mercado Pago
- Free trial period

**Content Expansion**:
- Additional books/journeys
- Video content
- Interactive exercises
- Guided meditations



## Summary

This design document specifies a comprehensive Flutter Web application for the "Jornada Deus é Pai" spiritual journey experience. The system migrates and enhances the existing Next.js application while preserving all Supabase data and adding new emotional touchpoints.

### Key Design Decisions

1. **Feature-Based Architecture**: Modular structure enables future integration into No Secreto app
2. **Riverpod State Management**: Predictable, testable state with dependency injection
3. **Hybrid Carta Experience**: Progressive text blocks synchronized with narration create immersive "someone speaking to me" feeling
4. **Golden Rule Philosophy**: Technical freedom + emotional guidance = natural user flow without dark patterns
5. **Minimalist Transition Screen**: Zero distractions create powerful conversion moment
6. **Property-Based Testing**: Selective use for critical business logic (audio sync, state transitions, parsing)
7. **Offline-First**: Local caching ensures smooth experience with unreliable connections
8. **Monetization Ready**: Architecture prepared for paid content without refactoring

### Technical Highlights

- **Clean Architecture**: Clear separation of presentation, domain, and data layers
- **Immutable State**: Equatable models ensure predictable state management
- **Type Safety**: Strong typing throughout with domain models and DTOs
- **Error Handling**: Layered approach with user-friendly Portuguese messages
- **Accessibility**: WCAG AA compliance with semantic labels and keyboard navigation
- **Performance**: < 3s initial load, 60fps animations, optimized assets
- **Testing**: 80% coverage with unit, widget, integration, and property-based tests

### Implementation Roadmap

**Phase 1** (Weeks 1-2): Setup, infrastructure, design system, authentication
**Phase 2** (Weeks 3-4): Entry, Carta, Transition, Preparation screens
**Phase 3** (Weeks 5-6): Journey system, progress tracking, reflections
**Phase 4** (Weeks 7-8): Seals, offline support, analytics
**Phase 5** (Weeks 9-10): Polish, optimization, testing, deployment

### Success Metrics

- **Functional**: All Next.js features work in Flutter Web
- **Emotional**: High conversion rate from Carta → Transition → Preparation
- **Performance**: < 3s load time, 60fps animations
- **Quality**: 80% test coverage, zero critical bugs
- **Integration**: Module ready for No Secreto app

### Next Steps

1. **User Review**: Review and approve this design document
2. **Task Creation**: Generate detailed implementation tasks
3. **Sprint Planning**: Organize tasks into sprints
4. **Development**: Begin Phase 1 implementation
5. **Iteration**: Continuous feedback and refinement

---

**Document Version**: 1.0
**Last Updated**: 2024
**Status**: Ready for Review

