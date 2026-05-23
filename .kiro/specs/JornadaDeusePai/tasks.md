# Implementation Tasks: Jornada Deus é Pai - Flutter Web Migration

## Phase 1: Project Setup and Foundation

### Task 1: Initialize Flutter Web Project
- [ ] 1.1 Create new Flutter project with web support enabled
- [ ] 1.2 Configure pubspec.yaml with dependencies (flutter_riverpod ^2.5.0, supabase_flutter ^2.8.3, equatable ^2.0.7, go_router ^13.0.0, audioplayers, flutter_markdown ^0.6.0)
- [ ] 1.3 Set up feature-based folder structure (features/, shared/)
- [ ] 1.4 Create feature folders: entry, carta, transition, journey, preparation, auth
- [ ] 1.5 Create shared folders: core, theme, widgets, models, providers, services
- [ ] 1.6 Configure web/index.html for Flutter Web
- [ ] 1.7 Set up environment configuration files (.env for Supabase credentials)

### Task 2: Supabase Integration Setup
- [ ] 2.1 Create SupabaseService in shared/services/
- [ ] 2.2 Initialize Supabase client with existing credentials
- [ ] 2.3 Test connection to existing Supabase instance
- [ ] 2.4 Create migration scripts for new tables (user_reflections, user_journey_stage, user_purchased_content)
- [ ] 2.5 Add is_paid_content field to chapters table
- [ ] 2.6 Verify compatibility with existing Next.js schema
- [ ] 2.7 Test data read from existing tables (profiles, chapters, user_progress, seals, user_seals)

### Task 3: Theme and Design System
- [ ] 3.1 Create AppTheme in shared/theme/app_theme.dart
- [ ] 3.2 Define dark theme color palette (primary: warm gold/amber, secondary: soft blue, background: dark gray/black)
- [ ] 3.3 Define typography scale (H1: 32sp, H2: 24sp, H3: 20sp, Body: 16sp, Caption: 14sp)
- [ ] 3.4 Define spacing scale (4, 8, 16, 24, 32, 48, 64 logical pixels)
- [ ] 3.5 Create reusable button styles (primary, secondary)
- [ ] 3.6 Create animation constants (duration: 300ms)
- [ ] 3.7 Ensure WCAG AA color contrast (minimum 4.5:1)

### Task 4: Navigation and Routing Setup
- [ ] 4.1 Create router configuration using go_router
- [ ] 4.2 Define routes: /entry, /carta, /transition, /journey/:chapterId, /preparation, /login, /signup
- [ ] 4.3 Implement authentication guard for protected routes
- [ ] 4.4 Implement forward-only navigation guard for Transition Screen
- [ ] 4.5 Handle deep linking for chapter URLs
- [ ] 4.6 Handle browser back/forward buttons
- [ ] 4.7 Create NavigationDelegate interface for external integration

## Phase 2: Authentication and User Management

### Task 5: Authentication Feature
- [ ] 5.1 Create domain models: UserProfile
- [ ] 5.2 Create AuthRepository interface in domain layer
- [ ] 5.3 Implement AuthRepositoryImpl with Supabase in data layer
- [ ] 5.4 Create AuthNotifier provider with Riverpod
- [ ] 5.5 Create UserProfileNotifier provider
- [ ] 5.6 Build LoginScreen UI
- [ ] 5.7 Build SignupScreen UI
- [ ] 5.8 Implement email/password authentication
- [ ] 5.9 Implement OAuth providers (Google, Apple) if configured
- [ ] 5.10 Implement session management and auto-refresh
- [ ] 5.11 Implement logout functionality
- [ ] 5.12 Handle authentication errors with Portuguese messages
- [ ] 5.13 Test authentication flow end-to-end

### Task 6: User Profile Management
- [ ] 6.1 Create profile loading logic in UserProfileNotifier
- [ ] 6.2 Implement profile update functionality
- [ ] 6.3 Handle profile creation via Supabase trigger (verify existing trigger works)
- [ ] 6.4 Display user profile data in UI
- [ ] 6.5 Test profile data persistence across sessions

## Phase 3: Entry Screen and Journey Stage Tracking

### Task 7: Journey Stage Tracking
- [ ] 7.1 Create JourneyStage enum (entry, carta, transition, journey, preparation, chat)
- [ ] 7.2 Create JourneyStageRepository interface
- [ ] 7.3 Implement JourneyStageRepositoryImpl with Supabase
- [ ] 7.4 Create JourneyStageNotifier provider
- [ ] 7.5 Implement stage update logic
- [ ] 7.6 Implement stage restoration on app launch
- [ ] 7.7 Test stage tracking across user sessions

### Task 8: Entry Screen Feature
- [ ] 8.1 Create EntryScreen widget
- [ ] 8.2 Create EntryContent widget with emotional text about spiritual orphanhood
- [ ] 8.3 Implement primary button "Começar pela raiz" with prominent styling
- [ ] 8.4 Implement secondary button "Ir direto falar com o Pai" with subtle styling
- [ ] 8.5 Implement navigation to CartaScreen on primary button click
- [ ] 8.6 Implement navigation to PreparationScreen on secondary button click
- [ ] 8.7 Update journey stage on navigation
- [ ] 8.8 Implement responsive layout (mobile, tablet, desktop)
- [ ] 8.9 Apply dark theme with warm accent colors
- [ ] 8.10 Test Entry Screen on different screen sizes
- [ ] 8.11 Verify Golden Rule implementation (both buttons accessible, primary visually prominent)

## Phase 4: Carta de um Órfão (Livro 1) - Immersive Hybrid Experience

### Task 9: Audio-Text Synchronization Infrastructure
- [ ] 9.1 Create TextBlock model (text, startTime, endTime)
- [ ] 9.2 Create AudioNarrationController service
- [ ] 9.3 Implement audio player initialization with audioplayers package
- [ ] 9.4 Implement audio playback controls (play, pause, resume)
- [ ] 9.5 Implement position tracking stream
- [ ] 9.6 Implement currentBlockIndex calculation based on audio position
- [ ] 9.7 Handle audio loading and buffering states
- [ ] 9.8 Handle audio errors gracefully (fallback to text-only mode)
- [ ] 9.9 Test audio playback across browsers (Chrome, Safari, Firefox, Edge)

### Task 10: Carta Screen UI and Interaction
- [ ] 10.1 Create CartaScreen widget (full-screen immersive layout)
- [ ] 10.2 Create ProgressiveTextDisplay widget
- [ ] 10.3 Implement text block fade-in animation
- [ ] 10.4 Implement tap gesture to advance text block
- [ ] 10.5 Implement hold gesture to pause narration
- [ ] 10.6 Implement release gesture to resume narration
- [ ] 10.7 Implement auto-advance when user doesn't interact
- [ ] 10.8 Create CartaSyncNotifier provider
- [ ] 10.9 Implement audio-text synchronization logic
- [ ] 10.10 Load text blocks and audio URL from Supabase or config
- [ ] 10.11 Implement clean background design (dark or paper texture)
- [ ] 10.12 Apply soft, readable typography
- [ ] 10.13 Ensure NO traditional media controls visible
- [ ] 10.14 Display subtle progress indicator (not timeline)
- [ ] 10.15 Display "Continuar" button at end of experience
- [ ] 10.16 Navigate to TransitionScreen on "Continuar" click
- [ ] 10.17 Update journey stage to 'transition'
- [ ] 10.18 Implement responsive layout (full-screen mobile, centered desktop)
- [ ] 10.19 Test immersive experience (feels like "someone speaking to me")
- [ ] 10.20 Test all interaction gestures (tap, hold, release)

## Phase 5: Transition Screen - Minimalist Emotional Conversion Point

### Task 11: Transition Screen Implementation
- [ ] 11.1 Create TransitionScreen widget
- [ ] 11.2 Create TwoPartMessage widget
- [ ] 11.3 Display first message part: "Talvez você nunca tenha sido apresentado ao seu verdadeiro Pai."
- [ ] 11.4 Implement visual pause (2-3 seconds breathing space)
- [ ] 11.5 Display second message part: "Mas isso pode começar agora."
- [ ] 11.6 Implement soft fade-in animations for message parts
- [ ] 11.7 Display single button: "Falar com o Pai pela primeira vez"
- [ ] 11.8 Navigate to PreparationScreen on button click
- [ ] 11.9 Update journey stage to 'preparation'
- [ ] 11.10 Apply extreme minimalist design (zero distractions)
- [ ] 11.11 Ensure NO back navigation to Carta (forward-only flow)
- [ ] 11.12 Ensure NO decorative elements or breadcrumbs
- [ ] 11.13 Use maximum contrast for message readability
- [ ] 11.14 Make button visually prominent but not aggressive
- [ ] 11.15 Test emotional impact and conversion focus
- [ ] 11.16 Track button clicks with analytics

## Phase 6: Preparation Screen - Identity Reinforcement

### Task 12: Preparation Screen Implementation
- [ ] 12.1 Create PreparationScreen widget
- [ ] 12.2 Create IdentityAffirmation widget
- [ ] 12.3 Display emotional text reinforcing identity as filho/filha
- [ ] 12.4 Display affirmations about being loved and accepted
- [ ] 12.5 Create BreathingExercise widget (optional animated guide)
- [ ] 12.6 Implement "Estou pronto para conversar" button
- [ ] 12.7 Navigate to Chat Interface on button click (placeholder for now)
- [ ] 12.8 Update journey stage to 'chat'
- [ ] 12.9 Apply calming visual design with soft colors
- [ ] 12.10 Make screen skippable (user can proceed immediately)
- [ ] 12.11 Ensure accessible from two paths (after Transition OR directly from Entry)
- [ ] 12.12 Test both entry paths work correctly

## Phase 7: Journey System (Livro 2) - Chapter Navigation

### Task 13: Chapter Data Models and Repository
- [ ] 13.1 Create Chapter domain model
- [ ] 13.2 Create UserProgress domain model with ProgressStatus enum
- [ ] 13.3 Create UserReflection domain model
- [ ] 13.4 Create ChapterRepository interface
- [ ] 13.5 Implement ChapterRepositoryImpl with Supabase
- [ ] 13.6 Create ProgressRepository interface
- [ ] 13.7 Implement ProgressRepositoryImpl with Supabase
- [ ] 13.8 Create ReflectionRepository interface
- [ ] 13.9 Implement ReflectionRepositoryImpl with Supabase
- [ ] 13.10 Test data loading from existing chapters table

### Task 14: Chapter State Management
- [ ] 14.1 Create ChaptersNotifier provider
- [ ] 14.2 Create UserProgressNotifier provider
- [ ] 14.3 Create ReflectionNotifier provider (family provider by chapterId)
- [ ] 14.4 Implement chapter loading logic (ordered by chapter_number)
- [ ] 14.5 Implement progress loading logic
- [ ] 14.6 Implement progress update logic (status, percentage, timestamps)
- [ ] 14.7 Implement chapter completion logic
- [ ] 14.8 Implement next chapter unlock logic
- [ ] 14.9 Implement reflection save logic
- [ ] 14.10 Implement reflection load logic

### Task 15: Chapter UI Components
- [ ] 15.1 Create JourneyScreen widget (chapter list view)
- [ ] 15.2 Create ChapterList widget
- [ ] 15.3 Display chapters in sequential order
- [ ] 15.4 Display chapter status (completed, in-progress, locked)
- [ ] 15.5 Display visual progress indicator
- [ ] 15.6 Create ChapterView widget (single chapter view)
- [ ] 15.7 Display chapter title and subtitle
- [ ] 15.8 Implement content parser for markdown rendering
- [ ] 15.9 Display formatted chapter content
- [ ] 15.10 Create ReflectionInput widget
- [ ] 15.11 Implement multi-line text area with placeholder
- [ ] 15.12 Implement local draft auto-save
- [ ] 15.13 Implement "Salvar Reflexão" button
- [ ] 15.14 Display save confirmation message
- [ ] 15.15 Display "Próximo Capítulo" button at end
- [ ] 15.16 Navigate to next chapter on button click
- [ ] 15.17 Mark chapter as completed on navigation
- [ ] 15.18 Allow navigation back to previous completed chapters
- [ ] 15.19 Prevent navigation to locked chapters
- [ ] 15.20 Test chapter navigation flow end-to-end

## Phase 8: Seal System

### Task 16: Seal Data Models and Repository
- [ ] 16.1 Create Seal domain model
- [ ] 16.2 Create UserSeal domain model
- [ ] 16.3 Create SealRepository interface
- [ ] 16.4 Implement SealRepositoryImpl with Supabase
- [ ] 16.5 Test seal data loading from existing seals table

### Task 17: Seal State Management and UI
- [ ] 17.1 Create SealsNotifier provider
- [ ] 17.2 Create UserSealsNotifier provider
- [ ] 17.3 Implement seal unlock condition checking logic
- [ ] 17.4 Implement seal award logic
- [ ] 17.5 Update total_seals in user profile on award
- [ ] 17.6 Create SealAwardDialog widget
- [ ] 17.7 Implement seal award animation
- [ ] 17.8 Display seal name, description, icon
- [ ] 17.9 Display "Faço parte do movimento Deus é Pai" for completion seal
- [ ] 17.10 Create SealList widget
- [ ] 17.11 Display all seals (locked and unlocked)
- [ ] 17.12 Show unlock hints for locked seals
- [ ] 17.13 Test seal unlock after chapter completion

## Phase 9: Monetization Architecture Preparation

### Task 18: Paid Content Infrastructure
- [ ] 18.1 Verify is_paid_content field exists in chapters table
- [ ] 18.2 Create user_purchased_content table in Supabase
- [ ] 18.3 Create PurchasedContent domain model
- [ ] 18.4 Create ContentAccessRepository interface
- [ ] 18.5 Implement ContentAccessRepositoryImpl
- [ ] 18.6 Create ContentAccessNotifier provider
- [ ] 18.7 Implement access verification logic before displaying chapter
- [ ] 18.8 Create LockedContentIndicator widget
- [ ] 18.9 Display "Conteúdo Bloqueado" for paid content without purchase
- [ ] 18.10 Log access attempts to paid content for analytics
- [ ] 18.11 Mark Livro_1 (Carta) as free (is_paid_content=false)
- [ ] 18.12 Mark Livro_2 chapters as paid (is_paid_content=true) for future
- [ ] 18.13 Test access control logic (DO NOT implement payment gateway yet)

## Phase 10: Shared Services and Utilities

### Task 19: Error Handling and User Feedback
- [ ] 19.1 Create ErrorHandlingService in shared/services/
- [ ] 19.2 Implement getUserFriendlyMessage() for common errors
- [ ] 19.3 Create error messages in Portuguese
- [ ] 19.4 Implement centralized error logging
- [ ] 19.5 Create reusable SnackBar/Toast widgets
- [ ] 19.6 Create reusable Dialog widgets for critical errors
- [ ] 19.7 Implement retry mechanism for failed operations
- [ ] 19.8 Test error handling for network errors, auth errors, save errors

### Task 20: Caching and Offline Support
- [ ] 20.1 Create CacheService in shared/services/
- [ ] 20.2 Implement chapter content caching with Hive or SharedPreferences
- [ ] 20.3 Implement progress caching
- [ ] 20.4 Display cached content when offline
- [ ] 20.5 Queue reflection saves when offline
- [ ] 20.6 Sync queued operations when connection restored
- [ ] 20.7 Display offline indicator when network unavailable
- [ ] 20.8 Implement preloading of next chapter content
- [ ] 20.9 Test offline functionality

### Task 21: Analytics Integration
- [ ] 21.1 Create AnalyticsService in shared/services/
- [ ] 21.2 Integrate Firebase Analytics or similar
- [ ] 21.3 Implement screen view tracking
- [ ] 21.4 Implement event tracking (chapter completed, reflection saved, seal unlocked)
- [ ] 21.5 Track audio events (play, pause, complete) for Carta
- [ ] 21.6 Track navigation path choices (raiz vs direto)
- [ ] 21.7 Track Transition Screen button clicks
- [ ] 21.8 Track time spent on each screen
- [ ] 21.9 Track error occurrences
- [ ] 21.10 Ensure LGPD compliance for user privacy
- [ ] 21.11 Track conversion rate from Carta → Transition → Preparation

## Phase 11: Responsive Design and Accessibility

### Task 22: Responsive Layout Implementation
- [ ] 22.1 Implement mobile-first responsive design for all screens
- [ ] 22.2 Define breakpoints: mobile (<600px), tablet (600-1024px), desktop (>1024px)
- [ ] 22.3 Adapt Entry Screen layout for all breakpoints
- [ ] 22.4 Adapt Carta Screen layout (full-screen mobile, centered desktop)
- [ ] 22.5 Adapt Transition Screen layout for all breakpoints
- [ ] 22.6 Adapt Preparation Screen layout for all breakpoints
- [ ] 22.7 Adapt Journey/Chapter screens layout for all breakpoints
- [ ] 22.8 Test all screens on mobile, tablet, desktop viewports

### Task 23: Accessibility Implementation
- [ ] 23.1 Ensure minimum touch target size of 48x48 logical pixels
- [ ] 23.2 Add semantic labels for screen readers
- [ ] 23.3 Implement keyboard navigation for all interactive elements
- [ ] 23.4 Display focus indicators on interactive elements
- [ ] 23.5 Ensure scalable text respects user font size preferences
- [ ] 23.6 Add alternative text for all images and icons
- [ ] 23.7 Test with Flutter accessibility tools
- [ ] 23.8 Test with screen readers (TalkBack, VoiceOver)
- [ ] 23.9 Verify WCAG AA color contrast compliance

## Phase 12: Performance Optimization

### Task 24: Performance Tuning
- [ ] 24.1 Optimize initial load time (target: <3s on 3G)
- [ ] 24.2 Implement code splitting for features
- [ ] 24.3 Implement lazy loading for non-critical content
- [ ] 24.4 Optimize images for web delivery
- [ ] 24.5 Optimize audio files for web delivery
- [ ] 24.6 Minimize bundle size
- [ ] 24.7 Implement loading indicators for async operations
- [ ] 24.8 Test performance on 3G connection
- [ ] 24.9 Ensure 60fps animations
- [ ] 24.10 Profile and optimize render performance

## Phase 13: Testing

### Task 25: Unit and Widget Tests
- [ ] 25.1 Write unit tests for all domain models
- [ ] 25.2 Write unit tests for all use cases/business logic
- [ ] 25.3 Write unit tests for all repositories
- [ ] 25.4 Write unit tests for all providers/notifiers
- [ ] 25.5 Write widget tests for Entry Screen
- [ ] 25.6 Write widget tests for Carta Screen components
- [ ] 25.7 Write widget tests for Transition Screen
- [ ] 25.8 Write widget tests for Preparation Screen
- [ ] 25.9 Write widget tests for Journey/Chapter screens
- [ ] 25.10 Write widget tests for Seal components
- [ ] 25.11 Write widget tests for Auth screens
- [ ] 25.12 Achieve minimum 80% code coverage

### Task 26: Integration Tests
- [ ] 26.1 Write integration test for authentication flow (login, signup, logout)
- [ ] 26.2 Write integration test for Entry → Carta → Transition → Preparation flow
- [ ] 26.3 Write integration test for Entry → Preparation direct flow
- [ ] 26.4 Write integration test for chapter navigation and progress tracking
- [ ] 26.5 Write integration test for reflection save and retrieval
- [ ] 26.6 Write integration test for seal unlock
- [ ] 26.7 Write integration test for offline functionality
- [ ] 26.8 Write integration test for error handling
- [ ] 26.9 Test all critical user flows end-to-end

## Phase 14: Integration Module for No Secreto App

### Task 27: Module Packaging
- [ ] 27.1 Create JornadaDeusePaiModule as public API entry point
- [ ] 27.2 Define NavigationDelegate interface for external navigation
- [ ] 27.3 Accept ThemeData parameter for visual consistency
- [ ] 27.4 Accept initial route parameter
- [ ] 27.5 Emit events for journey milestones (chapter completed, seal unlocked)
- [ ] 27.6 Remove hard dependencies on go_router (use navigation delegate)
- [ ] 27.7 Create example integration code
- [ ] 27.8 Document public API in README
- [ ] 27.9 Version using semantic versioning
- [ ] 27.10 Test module integration in isolation

## Phase 15: Deployment and CI/CD

### Task 28: CI/CD Pipeline Setup
- [ ] 28.1 Create GitHub Actions workflow for CI
- [ ] 28.2 Configure CI to run tests on every pull request
- [ ] 28.3 Configure CI to run linting and code analysis
- [ ] 28.4 Configure CI to build Flutter Web bundle
- [ ] 28.5 Create CD workflow for staging deployment (develop branch)
- [ ] 28.6 Create CD workflow for production deployment (main branch)
- [ ] 28.7 Configure environment variables for Supabase
- [ ] 28.8 Generate source maps for debugging
- [ ] 28.9 Implement deployment monitoring and rollback on failure

### Task 29: Hosting and Deployment
- [ ] 29.1 Choose hosting platform (Firebase Hosting or Vercel)
- [ ] 29.2 Configure hosting for Flutter Web
- [ ] 29.3 Set up custom domain (if applicable)
- [ ] 29.4 Configure SSL/HTTPS
- [ ] 29.5 Deploy to staging environment
- [ ] 29.6 Test staging deployment
- [ ] 29.7 Deploy to production environment
- [ ] 29.8 Verify production deployment
- [ ] 29.9 Set up monitoring and error tracking (Sentry or similar)

## Phase 16: Content Management and Final Polish

### Task 30: Content Loading and Management
- [ ] 30.1 Verify all content loads from Supabase (not hardcoded)
- [ ] 30.2 Configure video URL for Carta de um Órfão in database
- [ ] 30.3 Implement content caching with configurable TTL
- [ ] 30.4 Implement content refresh mechanism
- [ ] 30.5 Implement manual refresh for content updates
- [ ] 30.6 Validate content structure on load
- [ ] 30.7 Handle missing content gracefully
- [ ] 30.8 Display content update notification when new content available
- [ ] 30.9 Test content management workflow

### Task 31: Final Testing and Polish
- [ ] 31.1 Conduct end-to-end user acceptance testing
- [ ] 31.2 Test all user flows on multiple devices
- [ ] 31.3 Test on multiple browsers (Chrome, Safari, Firefox, Edge)
- [ ] 31.4 Verify data compatibility with Next.js app
- [ ] 31.5 Test Golden Rule implementation (freedom + emotional guidance)
- [ ] 31.6 Verify conversion rates from analytics
- [ ] 31.7 Fix any remaining bugs or issues
- [ ] 31.8 Polish animations and transitions
- [ ] 31.9 Optimize performance based on profiling
- [ ] 31.10 Prepare launch documentation and user guides

---

## Notes

- **Priority**: Tasks are organized in phases for logical implementation order
- **Dependencies**: Some tasks depend on completion of previous tasks (e.g., Task 10 depends on Task 9)
- **Testing**: Testing tasks (Phase 13) should be done incrementally alongside feature development
- **Golden Rule**: Throughout implementation, ensure all features follow the Golden Rule philosophy (technical freedom + emotional guidance)
- **Data Preservation**: All tasks must maintain compatibility with existing Supabase data from Next.js app
- **Livro 1 vs Livro 2**: Keep clear separation between Carta de um Órfão (Livro 1, free, linear) and Journey System (Livro 2, paid, chapters)
