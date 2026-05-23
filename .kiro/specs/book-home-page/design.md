# Design Document: Book Home Page

## Overview

A Book Home Page é a página inicial de leitura do livro espiritual "Não Ore, Fale com o Pai" implementada em Flutter Web. Esta página serve como portal de entrada para a jornada espiritual, apresentando uma interface contemplativa e minimalista que prepara emocionalmente o leitor antes de iniciar a leitura dos capítulos.

### Purpose

O propósito desta feature é:
- Criar uma experiência visual contemplativa que prepare o coração do leitor para a jornada espiritual
- Gerenciar e exibir o progresso do usuário através dos capítulos do livro
- Controlar o acesso sequencial aos capítulos através de um sistema de desbloqueio progressivo
- Fornecer navegação intuitiva para os capítulos disponíveis
- Persistir o progresso do usuário entre sessões usando Local Storage

### Key Features

1. **Visual Design System**: Interface minimalista com paleta de cores contemplativa (preto, branco, dourado)
2. **Reflection Quotes**: Frases profundas que aparecem com animações fade-in para preparar o leitor
3. **Progress Tracking**: Exibição visual do progresso do usuário na jornada
4. **Chapter Management**: Lista de capítulos com sistema de bloqueio/desbloqueio progressivo
5. **State Management**: Gerenciamento reativo de estado usando Riverpod
6. **Persistence**: Salvamento automático do progresso em Local Storage
7. **Responsive Design**: Layout adaptativo para diferentes tamanhos de tela
8. **Accessibility**: Suporte completo para navegação por teclado e leitores de tela

### Technology Stack

- **Framework**: Flutter Web (SDK ^3.9.2)
- **State Management**: flutter_riverpod ^2.5.0
- **Routing**: go_router ^13.0.0
- **Persistence**: shared_preferences ^2.2.0
- **Architecture**: Clean Architecture com feature-based organization

## Architecture

### High-Level Architecture

A Book Home Page segue Clean Architecture com separação clara entre camadas:

```
lib/features/book/
├── data/
│   ├── constants/
│   │   └── book_content.dart          # Static content (titles, quotes)
│   ├── data_sources/
│   │   └── progress_local_data_source.dart  # Local Storage operations
│   └── repositories/
│       └── progress_repository_impl.dart    # Repository implementation
├── domain/
│   ├── models/
│   │   ├── chapter.dart               # Chapter entity
│   │   └── user_progress.dart         # Progress entity
│   └── repositories/
│       └── progress_repository.dart   # Repository interface
└── presentation/
    ├── pages/
    │   └── book_home_page.dart        # Main page
    ├── widgets/
    │   ├── book_header.dart           # Title and subtitle
    │   ├── reflection_quotes_section.dart  # Animated quotes
    │   ├── progress_display.dart      # Progress indicator
    │   ├── chapter_list.dart          # Chapter list with lock states
    │   └── cta_button.dart            # Call-to-action button
    ├── providers/
    │   └── progress_providers.dart    # Riverpod providers
    └── state/
        └── progress_notifier.dart     # State management logic
```

### Layer Responsibilities

#### Data Layer
- **Constants**: Static content (book title, quotes, chapter titles)
- **Data Sources**: Interface with Local Storage (shared_preferences)
- **Repositories**: Implementation of domain repository interfaces

#### Domain Layer
- **Models**: Pure Dart entities (Chapter, UserProgress)
- **Repositories**: Abstract interfaces for data operations

#### Presentation Layer
- **Pages**: Full-screen page widgets
- **Widgets**: Reusable UI components
- **Providers**: Riverpod provider definitions
- **State**: StateNotifier classes for complex state management

### State Management Strategy

The application uses Riverpod for reactive state management with the following provider hierarchy:

```dart
// Data Source Provider
progressLocalDataSourceProvider -> ProgressLocalDataSource

// Repository Provider
progressRepositoryProvider -> ProgressRepository

// State Notifier Provider
progressNotifierProvider -> StateNotifier<ProgressState>

// Derived Providers
currentChapterProvider -> int
unlockedChaptersProvider -> List<int>
completedChaptersProvider -> List<int>
chaptersProvider -> List<Chapter>
```

### Navigation Flow

```
BookHomePage
    ├─> [Click CTA Button] ─> ReadingPage (current/first chapter)
    └─> [Click Unlocked Chapter] ─> ReadingPage (specific chapter)
```

Navigation is handled by go_router with the following routes:
- `/book` - Book Home Page
- `/book/chapter/:id` - Reading Page for specific chapter

## Components and Interfaces

### Core Components

#### 1. BookHomePage

**Purpose**: Main page container that orchestrates all child widgets

**Responsibilities**:
- Load progress state on initialization
- Compose child widgets in responsive layout
- Handle loading and error states
- Provide scroll behavior

**Key Properties**:
```dart
class BookHomePage extends ConsumerStatefulWidget {
  const BookHomePage({super.key});
}

class _BookHomePageState extends ConsumerState<BookHomePage> {
  @override
  void initState() {
    super.initState();
    // Load progress from storage
    Future.microtask(() => ref.read(progressNotifierProvider.notifier).loadProgress());
  }
}
```

**Layout Structure**:
```
Scaffold
└── SingleChildScrollView
    └── Container (responsive width)
        ├── BookHeader
        ├── ReflectionQuotesSection
        ├── ProgressDisplay
        ├── ChapterList
        └── CTAButton
```

#### 2. BookHeader

**Purpose**: Display book title and subtitle

**Responsibilities**:
- Render title with appropriate typography
- Render subtitle with secondary styling
- Apply fade-in animation on mount

**Interface**:
```dart
class BookHeader extends StatelessWidget {
  const BookHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      delay: Duration(milliseconds: 100),
      child: Column(
        children: [
          Text(BookContent.bookTitle, style: titleStyle),
          SizedBox(height: 8),
          Text(BookContent.bookSubtitle, style: subtitleStyle),
        ],
      ),
    );
  }
}
```

#### 3. ReflectionQuotesSection

**Purpose**: Display contemplative quotes with staggered fade-in animations

**Responsibilities**:
- Render list of reflection quotes
- Apply staggered fade-in animations (100ms delay between each)
- Maintain generous vertical spacing

**Interface**:
```dart
class ReflectionQuotesSection extends StatelessWidget {
  const ReflectionQuotesSection({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: BookContent.reflectionQuotes.asMap().entries.map((entry) {
        final index = entry.key;
        final quote = entry.value;
        return FadeInWidget(
          delay: Duration(milliseconds: 300 + (index * 100)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(quote, style: quoteStyle, textAlign: TextAlign.center),
          ),
        );
      }).toList(),
    );
  }
}
```

#### 4. ProgressDisplay

**Purpose**: Show user's current progress in the journey

**Responsibilities**:
- Display "Seu progresso na jornada" title
- Show current chapter number and total chapters
- Format as "Capítulo X de Y"
- Handle case when no progress exists

**Interface**:
```dart
class ProgressDisplay extends ConsumerWidget {
  const ProgressDisplay({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapter = ref.watch(currentChapterProvider);
    final totalChapters = BookContent.chapterTitles.length;
    
    return FadeInWidget(
      delay: Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(BookContent.progressTitle, style: progressTitleStyle),
          SizedBox(height: 8),
          Text('Capítulo $currentChapter de $totalChapters', style: progressValueStyle),
        ],
      ),
    );
  }
}
```

#### 5. ChapterList

**Purpose**: Display all chapters with lock/unlock states

**Responsibilities**:
- Render list of all chapters
- Show lock icon for locked chapters
- Apply reduced opacity to locked chapters
- Handle tap events for unlocked chapters
- Provide hover feedback for unlocked chapters
- Prevent interaction with locked chapters

**Interface**:
```dart
class ChapterList extends ConsumerWidget {
  const ChapterList({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider);
    
    return FadeInWidget(
      delay: Duration(milliseconds: 700),
      child: Column(
        children: chapters.map((chapter) => ChapterListItem(chapter: chapter)).toList(),
      ),
    );
  }
}

class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  const ChapterListItem({super.key, required this.chapter});
}

class _ChapterListItemState extends State<ChapterListItem> {
  bool _isHovered = false;
  
  void _handleTap() {
    if (widget.chapter.isUnlocked) {
      context.go('/book/chapter/${widget.chapter.id}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: Opacity(
          opacity: widget.chapter.isUnlocked ? 1.0 : 0.4,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered && widget.chapter.isUnlocked 
                ? Colors.white.withOpacity(0.05) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('${widget.chapter.id}. ${widget.chapter.title}', style: chapterStyle),
                if (!widget.chapter.isUnlocked) ...[
                  SizedBox(width: 8),
                  Text('🔒', style: TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 6. CTAButton

**Purpose**: Primary call-to-action button for starting or continuing reading

**Responsibilities**:
- Display "Começar leitura" when user hasn't started
- Display "Continuar leitura" when user has progress
- Navigate to Chapter 1 when starting fresh
- Navigate to current chapter when continuing
- Provide prominent visual styling

**Interface**:
```dart
class CTAButton extends ConsumerWidget {
  const CTAButton({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapter = ref.watch(currentChapterProvider);
    final hasStarted = currentChapter > 1;
    final buttonText = hasStarted 
      ? BookContent.continueReadingButton 
      : BookContent.startReadingButton;
    
    return FadeInWidget(
      delay: Duration(milliseconds: 800),
      child: ElevatedButton(
        onPressed: () => context.go('/book/chapter/$currentChapter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD4AF37), // Gold
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
```

#### 7. FadeInWidget

**Purpose**: Reusable widget for fade-in animations

**Responsibilities**:
- Animate opacity from 0.0 to 1.0
- Support configurable delay
- Use smooth easing curve

**Interface**:
```dart
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  
  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
```

### State Management Components

#### ProgressNotifier

**Purpose**: Manage progress state and business logic

**Responsibilities**:
- Load progress from repository on initialization
- Update progress when chapters are completed
- Unlock next chapter when current is completed
- Save progress to repository on changes
- Notify listeners of state changes

**Interface**:
```dart
class ProgressNotifier extends StateNotifier<ProgressState> {
  final ProgressRepository _repository;
  
  ProgressNotifier(this._repository) : super(ProgressState.initial());
  
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    try {
      final progress = await _repository.getProgress();
      state = ProgressState(
        currentChapter: progress?.currentChapter ?? 1,
        completedChapters: progress?.completedChapters ?? [],
        unlockedChapters: progress?.unlockedChapters ?? [1],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> completeChapter(int chapterId) async {
    final updatedCompleted = [...state.completedChapters, chapterId];
    final updatedUnlocked = [...state.unlockedChapters];
    
    // Unlock next chapter if not already unlocked
    if (!updatedUnlocked.contains(chapterId + 1)) {
      updatedUnlocked.add(chapterId + 1);
    }
    
    // Update current chapter to next chapter
    final nextChapter = chapterId + 1;
    
    state = state.copyWith(
      currentChapter: nextChapter,
      completedChapters: updatedCompleted,
      unlockedChapters: updatedUnlocked,
    );
    
    await _saveProgress();
  }
  
  Future<void> _saveProgress() async {
    try {
      final progress = UserProgress(
        currentChapter: state.currentChapter,
        completedChapters: state.completedChapters,
        unlockedChapters: state.unlockedChapters,
      );
      await _repository.saveProgress(progress);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
```

#### ProgressState

**Purpose**: Immutable state object for progress data

**Interface**:
```dart
class ProgressState {
  final int currentChapter;
  final List<int> completedChapters;
  final List<int> unlockedChapters;
  final bool isLoading;
  final String? error;
  
  const ProgressState({
    required this.currentChapter,
    required this.completedChapters,
    required this.unlockedChapters,
    this.isLoading = false,
    this.error,
  });
  
  factory ProgressState.initial() {
    return ProgressState(
      currentChapter: 1,
      completedChapters: [],
      unlockedChapters: [1],
      isLoading: false,
      error: null,
    );
  }
  
  ProgressState copyWith({
    int? currentChapter,
    List<int>? completedChapters,
    List<int>? unlockedChapters,
    bool? isLoading,
    String? error,
  }) {
    return ProgressState(
      currentChapter: currentChapter ?? this.currentChapter,
      completedChapters: completedChapters ?? this.completedChapters,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
```

### Repository Components

#### ProgressRepository (Interface)

**Purpose**: Abstract interface for progress data operations

**Interface**:
```dart
abstract class ProgressRepository {
  Future<UserProgress?> getProgress();
  Future<void> saveProgress(UserProgress progress);
  Future<void> clearProgress();
}
```

#### ProgressRepositoryImpl

**Purpose**: Implementation of ProgressRepository using Local Storage

**Responsibilities**:
- Serialize/deserialize UserProgress to/from JSON
- Store data in shared_preferences
- Handle storage errors gracefully

**Interface**:
```dart
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource _localDataSource;
  
  ProgressRepositoryImpl(this._localDataSource);
  
  @override
  Future<UserProgress?> getProgress() async {
    try {
      return await _localDataSource.getProgress();
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    }
  }
  
  @override
  Future<void> saveProgress(UserProgress progress) async {
    try {
      await _localDataSource.saveProgress(progress);
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }
  
  @override
  Future<void> clearProgress() async {
    try {
      await _localDataSource.clearProgress();
    } catch (e) {
      throw Exception('Failed to clear progress: $e');
    }
  }
}
```

#### ProgressLocalDataSource

**Purpose**: Direct interface with shared_preferences

**Responsibilities**:
- Read/write JSON data to Local Storage
- Handle serialization/deserialization
- Manage storage keys

**Interface**:
```dart
class ProgressLocalDataSource {
  static const String _progressKey = 'user_progress';
  final SharedPreferences _prefs;
  
  ProgressLocalDataSource(this._prefs);
  
  Future<UserProgress?> getProgress() async {
    final jsonString = _prefs.getString(_progressKey);
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserProgress.fromJson(json);
  }
  
  Future<void> saveProgress(UserProgress progress) async {
    final jsonString = jsonEncode(progress.toJson());
    await _prefs.setString(_progressKey, jsonString);
  }
  
  Future<void> clearProgress() async {
    await _prefs.remove(_progressKey);
  }
}
```

## Data Models

### Chapter

**Purpose**: Represents a single chapter in the book

**Properties**:
```dart
class Chapter {
  final int id;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  
  const Chapter({
    required this.id,
    required this.title,
    required this.isUnlocked,
    this.isCompleted = false,
  });
  
  Chapter copyWith({
    int? id,
    String? title,
    bool? isUnlocked,
    bool? isCompleted,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

### UserProgress

**Purpose**: Represents user's progress through the book

**Properties**:
```dart
class UserProgress {
  final int currentChapter;
  final List<int> completedChapters;
  final List<int> unlockedChapters;
  
  const UserProgress({
    required this.currentChapter,
    required this.completedChapters,
    required this.unlockedChapters,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'currentChapter': currentChapter,
      'completedChapters': completedChapters,
      'unlockedChapters': unlockedChapters,
    };
  }
  
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentChapter: json['currentChapter'] as int,
      completedChapters: List<int>.from(json['completedChapters'] as List),
      unlockedChapters: List<int>.from(json['unlockedChapters'] as List),
    );
  }
}
```

## Correctness Properties


*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified the following testable properties. Many criteria are EXAMPLE-based tests (specific scenarios) or NOT TESTABLE (subjective design requirements). The properties below represent universal behaviors that should hold across all valid inputs.

**Redundancy Analysis:**
- Properties 6.2, 6.4, and 6.5 all test chapter display characteristics. These can be combined into a single comprehensive property about chapter rendering.
- Properties 7.2 and 10.5 both test that completing a chapter unlocks the next one. These are the same behavior tested at different layers.
- Properties 11.3, 11.4, and 11.5 all test persistence round-trip. These can be combined into a single comprehensive property.
- Properties 8.1 and 8.4 both test navigation with correct chapter ID. These can be combined.

**Final Properties (after removing redundancy):**

### Property 1: Progress Format Consistency

*For any* current chapter number and total chapter count, the progress display SHALL format the text as "Capítulo X de Y" where X is the current chapter and Y is the total.

**Validates: Requirements 5.3**

### Property 2: Chapter Display Completeness

*For any* chapter in the book, the chapter list SHALL display both the chapter number and title, and if the chapter is locked, SHALL display a lock icon and reduce opacity to less than 1.0.

**Validates: Requirements 6.2, 6.4, 6.5**

### Property 3: Sequential Chapter Ordering

*For any* list of chapters, the chapter list SHALL display them in sequential order sorted by chapter ID from first to last.

**Validates: Requirements 6.6**

### Property 4: Chapter Unlock Progression

*For any* chapter N that is completed, the system SHALL unlock chapter N+1 and add it to the unlocked chapters list.

**Validates: Requirements 7.2, 10.5**

### Property 5: Locked Chapter Navigation Prevention

*For any* chapter that is locked, clicking on that chapter SHALL NOT trigger navigation to the reading page.

**Validates: Requirements 7.3, 8.2**

### Property 6: Unlocked Chapter Navigation

*For any* chapter that is unlocked, clicking on that chapter SHALL navigate to the reading page with the correct chapter ID.

**Validates: Requirements 7.4, 8.1, 8.4**

### Property 7: Unlock State Persistence Round-Trip

*For any* set of unlocked chapters, saving the progress and then loading it SHALL preserve the exact same set of unlocked chapters.

**Validates: Requirements 7.5**

### Property 8: Hover Feedback for Unlocked Chapters

*For any* unlocked chapter, hovering over the chapter item SHALL change the visual state (background color or opacity).

**Validates: Requirements 8.3**

### Property 9: CTA Navigation to Current Chapter

*For any* current chapter number greater than 1, clicking the CTA button SHALL navigate to that specific chapter.

**Validates: Requirements 9.4**

### Property 10: Completed Chapters List Update

*For any* chapter that is completed, that chapter's ID SHALL be added to the completed chapters list in the progress state.

**Validates: Requirements 10.4**

### Property 11: State Change Notification

*For any* change to the progress state (current chapter, completed chapters, or unlocked chapters), all registered listeners SHALL be notified of the state change.

**Validates: Requirements 10.6**

### Property 12: Progress Save on Change

*For any* change to user progress (current chapter, completed chapters, or unlocked chapters), the system SHALL call the save method to persist the progress to Local Storage.

**Validates: Requirements 11.1**

### Property 13: Progress Persistence Round-Trip

*For any* valid UserProgress object (with current chapter, completed chapters list, and unlocked chapters list), serializing to JSON and then deserializing SHALL produce an equivalent UserProgress object with the same values.

**Validates: Requirements 11.3, 11.4, 11.5**

### Property 14: Locked Chapter Accessibility Label

*For any* chapter that is locked, the semantic label for screen readers SHALL include information indicating the locked status.

**Validates: Requirements 14.5**

## Error Handling

### Error Scenarios

The Book Home Page handles the following error scenarios:

#### 1. Local Storage Unavailable

**Scenario**: shared_preferences is not available or fails to initialize

**Handling**:
- Display error message: "Não foi possível acessar o armazenamento local. Verifique as permissões do navegador."
- Provide retry button to attempt reinitialization
- Fall back to in-memory state (progress will not persist)

**Implementation**:
```dart
try {
  final prefs = await SharedPreferences.getInstance();
  return ProgressLocalDataSource(prefs);
} catch (e) {
  // Show error to user
  state = state.copyWith(error: 'Não foi possível acessar o armazenamento local.');
  // Return in-memory fallback
  return InMemoryProgressDataSource();
}
```

#### 2. Progress Load Failure

**Scenario**: Loading progress from Local Storage fails due to corrupted data or deserialization error

**Handling**:
- Log error for debugging
- Clear corrupted data from storage
- Initialize with default progress (Chapter 1 unlocked)
- Display info message: "Seu progresso foi reiniciado. Começando do Capítulo 1."

**Implementation**:
```dart
try {
  final progress = await _repository.getProgress();
  state = ProgressState.fromProgress(progress);
} catch (e) {
  await _repository.clearProgress();
  state = ProgressState.initial();
  state = state.copyWith(
    error: 'Seu progresso foi reiniciado. Começando do Capítulo 1.'
  );
}
```

#### 3. Progress Save Failure

**Scenario**: Saving progress to Local Storage fails due to storage quota exceeded or write error

**Handling**:
- Display error message: "Não foi possível salvar seu progresso. Verifique o espaço disponível."
- Keep state in memory (user can continue but progress won't persist)
- Retry save on next state change

**Implementation**:
```dart
try {
  await _repository.saveProgress(progress);
} catch (e) {
  state = state.copyWith(
    error: 'Não foi possível salvar seu progresso. Verifique o espaço disponível.'
  );
  // State remains in memory, will retry on next change
}
```

#### 4. Navigation Failure

**Scenario**: Navigation to reading page fails due to invalid route or router error

**Handling**:
- Display error message: "Não foi possível abrir o capítulo. Tente novamente."
- Log error with chapter ID for debugging
- Keep user on current page

**Implementation**:
```dart
try {
  context.go('/book/chapter/${chapter.id}');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Não foi possível abrir o capítulo. Tente novamente.'))
  );
}
```

#### 5. Invalid Progress State

**Scenario**: Progress state contains invalid data (e.g., current chapter > total chapters)

**Handling**:
- Validate state on load
- Correct invalid values automatically
- Log warning for debugging

**Implementation**:
```dart
ProgressState _validateState(ProgressState state) {
  final totalChapters = BookContent.chapterTitles.length;
  
  // Correct current chapter if out of bounds
  final validCurrentChapter = state.currentChapter.clamp(1, totalChapters);
  
  // Remove invalid chapter IDs from lists
  final validCompleted = state.completedChapters
    .where((id) => id >= 1 && id <= totalChapters)
    .toList();
  
  final validUnlocked = state.unlockedChapters
    .where((id) => id >= 1 && id <= totalChapters)
    .toList();
  
  // Ensure at least chapter 1 is unlocked
  if (!validUnlocked.contains(1)) {
    validUnlocked.insert(0, 1);
  }
  
  return state.copyWith(
    currentChapter: validCurrentChapter,
    completedChapters: validCompleted,
    unlockedChapters: validUnlocked,
  );
}
```

### Error Display Strategy

All errors are displayed using a consistent pattern:

1. **Transient Errors** (save failures, network issues): Display as SnackBar at bottom of screen
2. **Critical Errors** (storage unavailable): Display as banner at top of page with retry button
3. **Recoverable Errors** (corrupted data): Auto-recover and show info message

Error messages follow these principles:
- Clear and user-friendly language (no technical jargon)
- Actionable guidance (what the user can do)
- Appropriate tone (calm and reassuring for spiritual content)

## Testing Strategy

### Testing Approach

The Book Home Page uses a comprehensive testing strategy combining unit tests, widget tests, and property-based tests:

#### 1. Unit Tests

**Purpose**: Test individual functions, classes, and business logic in isolation

**Coverage**:
- Data model serialization/deserialization (UserProgress.toJson/fromJson)
- Repository implementations (ProgressRepositoryImpl)
- State notifier logic (ProgressNotifier methods)
- Data source operations (ProgressLocalDataSource)
- Validation functions (state validation, input sanitization)

**Example**:
```dart
test('UserProgress serialization round-trip preserves data', () {
  final progress = UserProgress(
    currentChapter: 3,
    completedChapters: [1, 2],
    unlockedChapters: [1, 2, 3],
  );
  
  final json = progress.toJson();
  final deserialized = UserProgress.fromJson(json);
  
  expect(deserialized.currentChapter, progress.currentChapter);
  expect(deserialized.completedChapters, progress.completedChapters);
  expect(deserialized.unlockedChapters, progress.unlockedChapters);
});
```

#### 2. Widget Tests

**Purpose**: Test UI components and their interactions

**Coverage**:
- Widget rendering (all widgets render without errors)
- User interactions (taps, hovers, keyboard navigation)
- State-driven UI updates (loading, error, success states)
- Responsive layout (mobile vs desktop)
- Accessibility (semantic labels, focus management)
- Animation presence (FadeInWidget usage)

**Example**:
```dart
testWidgets('ChapterListItem shows lock icon for locked chapters', (tester) async {
  final lockedChapter = Chapter(
    id: 2,
    title: 'Test Chapter',
    isUnlocked: false,
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChapterListItem(chapter: lockedChapter),
      ),
    ),
  );
  
  expect(find.text('🔒'), findsOneWidget);
  expect(find.text('2. Test Chapter'), findsOneWidget);
});
```

#### 3. Property-Based Tests

**Purpose**: Verify universal properties hold across many generated inputs

**Configuration**:
- Minimum 100 iterations per property test
- Use package: `test` with custom property test helpers or `dart_check` package
- Each test tagged with: `Feature: book-home-page, Property {number}: {property_text}`

**Coverage**: All 14 correctness properties defined in this document

**Example**:
```dart
// Property 4: Chapter Unlock Progression
test('Property 4: Completing chapter N unlocks chapter N+1', () {
  final random = Random();
  
  for (int i = 0; i < 100; i++) {
    // Generate random chapter number (1 to 7, leaving room for N+1)
    final chapterN = random.nextInt(7) + 1;
    
    final notifier = ProgressNotifier(mockRepository);
    notifier.state = ProgressState(
      currentChapter: chapterN,
      completedChapters: [],
      unlockedChapters: [chapterN],
    );
    
    // Complete chapter N
    notifier.completeChapter(chapterN);
    
    // Verify chapter N+1 is unlocked
    expect(
      notifier.state.unlockedChapters.contains(chapterN + 1),
      true,
      reason: 'Chapter ${chapterN + 1} should be unlocked after completing chapter $chapterN',
    );
  }
}, tags: ['property', 'Feature: book-home-page, Property 4: Chapter Unlock Progression']);
```

#### 4. Integration Tests

**Purpose**: Test complete user flows end-to-end

**Coverage**:
- Full page load with real Local Storage
- Complete chapter and verify unlock flow
- Navigation between pages
- Error recovery flows

**Example**:
```dart
testWidgets('Complete user flow: load page, click chapter, navigate', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Wait for page to load
  await tester.pumpAndSettle();
  
  // Verify initial state
  expect(find.text('Começar leitura'), findsOneWidget);
  
  // Click CTA button
  await tester.tap(find.text('Começar leitura'));
  await tester.pumpAndSettle();
  
  // Verify navigation to reading page
  expect(find.byType(ReadingPage), findsOneWidget);
});
```

### Test Organization

Tests are organized by layer and component:

```
test/
├── unit/
│   ├── data/
│   │   ├── data_sources/
│   │   │   └── progress_local_data_source_test.dart
│   │   └── repositories/
│   │       └── progress_repository_impl_test.dart
│   ├── domain/
│   │   └── models/
│   │       ├── chapter_test.dart
│   │       └── user_progress_test.dart
│   └── presentation/
│       └── state/
│           └── progress_notifier_test.dart
├── widget/
│   └── presentation/
│       ├── pages/
│       │   └── book_home_page_test.dart
│       └── widgets/
│           ├── book_header_test.dart
│           ├── reflection_quotes_section_test.dart
│           ├── progress_display_test.dart
│           ├── chapter_list_test.dart
│           ├── cta_button_test.dart
│           └── fade_in_widget_test.dart
├── property/
│   └── book_home_page_properties_test.dart
└── integration/
    └── book_home_page_flow_test.dart
```

### Property-Based Testing Library

For Dart/Flutter, we will use a custom property testing approach since there's no mature PBT library like QuickCheck or Hypothesis. The approach:

1. **Manual Randomization**: Use `dart:math` Random to generate test inputs
2. **Iteration Loop**: Run each property test 100+ times with different inputs
3. **Shrinking**: On failure, manually reduce input to minimal failing case
4. **Tagging**: Tag all property tests for easy filtering

**Custom Property Test Helper**:
```dart
void propertyTest(
  String description,
  void Function(Random) testFn, {
  int iterations = 100,
  int? seed,
}) {
  test(description, () {
    final random = Random(seed);
    for (int i = 0; i < iterations; i++) {
      try {
        testFn(random);
      } catch (e) {
        fail('Property failed on iteration $i with seed $seed: $e');
      }
    }
  });
}
```

### Test Coverage Goals

- **Unit Tests**: 90%+ coverage of business logic
- **Widget Tests**: 80%+ coverage of UI components
- **Property Tests**: 100% coverage of all 14 correctness properties
- **Integration Tests**: All critical user flows covered

### Continuous Integration

All tests run automatically on:
- Every commit (unit + widget tests)
- Pull requests (all tests including property tests)
- Pre-deployment (full test suite + integration tests)

Property tests run with fixed seed in CI for reproducibility, and with random seed locally for exploration.

## Responsive Design

### Breakpoints

The Book Home Page uses two primary breakpoints:

- **Mobile**: viewport width < 600px
- **Desktop**: viewport width ≥ 600px

### Layout Adaptations

#### Mobile Layout (< 600px)

**Container**:
- Full width (100% of viewport)
- Horizontal padding: 16px
- Vertical padding: 24px

**Typography**:
- Title: 18px
- Subtitle: 14px
- Quotes: 16px
- Chapter text: 16px
- Progress text: 14px

**Spacing**:
- Section spacing: 32px
- Quote spacing: 24px
- Chapter item spacing: 12px

**CTA Button**:
- Full width
- Height: 48px
- Font size: 16px

#### Desktop Layout (≥ 600px)

**Container**:
- Max width: 800px
- Centered horizontally
- Horizontal padding: 48px
- Vertical padding: 48px

**Typography**:
- Title: 24px
- Subtitle: 16px
- Quotes: 20px
- Chapter text: 18px
- Progress text: 16px

**Spacing**:
- Section spacing: 48px
- Quote spacing: 32px
- Chapter item spacing: 16px

**CTA Button**:
- Auto width (content + padding)
- Height: 56px
- Font size: 18px

### Implementation

Responsive layout is implemented using MediaQuery:

```dart
class BookHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isMobile ? double.infinity : 800,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 48,
              vertical: isMobile ? 24 : 48,
            ),
            child: Column(
              children: [
                BookHeader(isMobile: isMobile),
                SizedBox(height: isMobile ? 32 : 48),
                ReflectionQuotesSection(isMobile: isMobile),
                SizedBox(height: isMobile ? 32 : 48),
                ProgressDisplay(isMobile: isMobile),
                SizedBox(height: isMobile ? 32 : 48),
                ChapterList(isMobile: isMobile),
                SizedBox(height: isMobile ? 32 : 48),
                CTAButton(isMobile: isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Touch Targets

All interactive elements meet minimum touch target size:
- Minimum: 48x48 dp (mobile)
- Recommended: 56x56 dp (desktop)

Chapter list items have full-width touch targets with adequate vertical spacing to prevent mis-taps.

## Accessibility

### WCAG 2.1 Compliance

The Book Home Page targets WCAG 2.1 Level AA compliance:

#### Color Contrast

- **Text on Background**: White (#FFFFFF) on Black (#000000) = 21:1 ratio ✓ (exceeds 7:1 requirement)
- **Gold Accent**: Gold (#D4AF37) on Black (#000000) = 9.5:1 ratio ✓ (exceeds 4.5:1 requirement)

#### Keyboard Navigation

All interactive elements are keyboard accessible:

**Tab Order**:
1. CTA Button (primary action)
2. Chapter 1 (if unlocked)
3. Chapter 2 (if unlocked)
4. ... (remaining unlocked chapters)

**Keyboard Shortcuts**:
- `Tab`: Move to next interactive element
- `Shift + Tab`: Move to previous interactive element
- `Enter` or `Space`: Activate focused element
- `Escape`: Close error messages (if any)

**Focus Indicators**:
```dart
focusNode: _focusNode,
decoration: BoxDecoration(
  border: _isFocused 
    ? Border.all(color: Color(0xFFD4AF37), width: 2)
    : null,
),
```

#### Screen Reader Support

All UI elements have semantic labels:

**Chapter Items**:
```dart
Semantics(
  label: widget.chapter.isUnlocked
    ? 'Capítulo ${widget.chapter.id}: ${widget.chapter.title}. Desbloqueado. Toque para ler.'
    : 'Capítulo ${widget.chapter.id}: ${widget.chapter.title}. Bloqueado.',
  button: widget.chapter.isUnlocked,
  enabled: widget.chapter.isUnlocked,
  child: ChapterListItemContent(...),
)
```

**Progress Display**:
```dart
Semantics(
  label: 'Seu progresso na jornada: Capítulo $current de $total',
  readOnly: true,
  child: ProgressDisplayContent(...),
)
```

**CTA Button**:
```dart
Semantics(
  label: hasStarted 
    ? 'Continuar leitura do capítulo $current'
    : 'Começar leitura do capítulo 1',
  button: true,
  child: ElevatedButton(...),
)
```

**Loading State**:
```dart
Semantics(
  label: 'Carregando seu progresso',
  liveRegion: true,
  child: CircularProgressIndicator(),
)
```

**Error Messages**:
```dart
Semantics(
  label: 'Erro: $errorMessage',
  liveRegion: true,
  child: ErrorDisplay(...),
)
```

#### Text Scaling

All text respects user's text scaling preferences:
- Use `TextStyle` with relative sizes
- Test with text scale factors: 1.0, 1.5, 2.0
- Ensure layout doesn't break at large text sizes

#### Reduced Motion

Respect user's reduced motion preferences:

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;

final animationDuration = reduceMotion 
  ? Duration.zero 
  : Duration(milliseconds: 600);
```

### Accessibility Testing

**Manual Testing**:
- Screen reader testing (TalkBack on Android, VoiceOver on iOS)
- Keyboard-only navigation
- High contrast mode
- Text scaling (up to 200%)
- Reduced motion mode

**Automated Testing**:
```dart
testWidgets('Book home page meets accessibility guidelines', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  // Check for semantic labels
  expect(find.bySemanticsLabel(RegExp('Capítulo.*')), findsWidgets);
  
  // Check for sufficient contrast (handled by design system)
  // Check for keyboard navigation (focus nodes present)
  // Check for screen reader support (Semantics widgets present)
});
```

## Performance Considerations

### Initial Load Performance

**Target**: Page should be interactive within 1 second on average hardware

**Optimizations**:
1. **Lazy Loading**: Defer non-critical animations until after first paint
2. **Minimal Dependencies**: Keep widget tree shallow
3. **Efficient State**: Use Riverpod's selective rebuilds
4. **Local Storage**: Async load doesn't block UI render

**Load Sequence**:
```
1. Render skeleton UI (0ms)
2. Start progress load (async)
3. First paint with loading indicator (< 100ms)
4. Progress loaded, update UI (< 500ms)
5. Start fade-in animations (< 600ms)
6. Page fully interactive (< 1000ms)
```

### Animation Performance

**Target**: 60 FPS (16ms per frame) for all animations

**Optimizations**:
1. Use `FadeTransition` (GPU-accelerated) instead of `AnimatedOpacity`
2. Avoid layout changes during animations
3. Use `RepaintBoundary` for animated sections
4. Stagger animations to distribute load

### Memory Management

**Considerations**:
- Dispose animation controllers in widget dispose
- Use `const` constructors where possible
- Avoid memory leaks in listeners
- Clear large data structures when not needed

### Storage Performance

**Optimizations**:
- Debounce save operations (max 1 save per second)
- Use JSON for efficient serialization
- Keep stored data minimal (< 1KB)

```dart
Timer? _saveTimer;

void _debouncedSave() {
  _saveTimer?.cancel();
  _saveTimer = Timer(Duration(seconds: 1), () {
    _saveProgress();
  });
}
```

## Security Considerations

### Data Privacy

**Local Storage**:
- Progress data stored locally in browser
- No sensitive personal information stored
- Data never transmitted to external servers
- User can clear data via browser settings

### Input Validation

**Chapter IDs**:
- Validate chapter IDs are within valid range (1 to total chapters)
- Sanitize IDs before navigation
- Prevent injection attacks via URL manipulation

```dart
void _navigateToChapter(int chapterId) {
  final totalChapters = BookContent.chapterTitles.length;
  
  if (chapterId < 1 || chapterId > totalChapters) {
    throw ArgumentError('Invalid chapter ID: $chapterId');
  }
  
  context.go('/book/chapter/$chapterId');
}
```

### XSS Prevention

**Content Rendering**:
- All static content is hardcoded (no user input)
- No dynamic HTML rendering
- No eval() or similar dangerous operations

### State Integrity

**Progress Validation**:
- Validate progress state on load
- Correct invalid values automatically
- Prevent impossible states (e.g., completed but locked)

## Deployment Considerations

### Build Configuration

**Flutter Web Build**:
```bash
flutter build web --release --web-renderer canvaskit
```

**Renderer Choice**:
- Use CanvasKit for better animation performance
- Fallback to HTML renderer for older browsers

### Browser Compatibility

**Supported Browsers**:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Polyfills**:
- Not required (Flutter handles cross-browser compatibility)

### Asset Optimization

**Images**: None (text-only page)
**Fonts**: Use system fonts (no custom fonts to load)
**Icons**: Use Unicode emoji (no icon fonts needed)

### Caching Strategy

**Service Worker**:
- Cache app shell for offline access
- Cache static assets indefinitely
- Network-first for API calls (if added later)

### Monitoring

**Metrics to Track**:
- Page load time (target: < 1s)
- Time to interactive (target: < 1s)
- Animation frame rate (target: 60 FPS)
- Error rate (target: < 0.1%)
- Local Storage failures (target: < 0.01%)

**Error Tracking**:
- Log all errors to console
- Track error patterns for debugging
- Monitor storage quota exceeded errors

## Future Enhancements

### Potential Improvements

1. **Progress Sync**: Sync progress across devices via Supabase
2. **Reading Streaks**: Track consecutive days of reading
3. **Bookmarks**: Allow users to bookmark specific chapters
4. **Notes**: Let users add personal notes to chapters
5. **Themes**: Additional color themes (light mode, sepia)
6. **Audio**: Audio narration of chapters
7. **Sharing**: Share progress or quotes on social media
8. **Achievements**: Unlock achievements for milestones
9. **Reminders**: Daily reading reminders
10. **Analytics**: Track reading patterns and insights

### Extensibility Points

The architecture supports these extensions:

- **New Data Sources**: Add Supabase repository alongside local storage
- **New State**: Extend ProgressState with additional fields
- **New Widgets**: Add new sections to page layout
- **New Animations**: Add more sophisticated animations
- **New Routes**: Add new pages to the book feature

## Conclusion

The Book Home Page design provides a solid foundation for a contemplative spiritual reading experience. The architecture is clean, testable, and extensible. The implementation follows Flutter best practices and accessibility guidelines. The property-based testing approach ensures correctness across a wide range of inputs and scenarios.

Key strengths:
- ✅ Clean Architecture with clear separation of concerns
- ✅ Reactive state management with Riverpod
- ✅ Comprehensive testing strategy with property-based tests
- ✅ Full accessibility support (WCAG 2.1 AA)
- ✅ Responsive design for mobile and desktop
- ✅ Robust error handling
- ✅ Performance optimizations
- ✅ Extensible architecture for future enhancements

The design is ready for implementation.
