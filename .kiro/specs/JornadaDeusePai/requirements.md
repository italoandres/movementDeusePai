# Requirements Document: Jornada Deus é Pai - Flutter Web Migration

## Introduction

Este documento define os requisitos para a evolução/migração do projeto "Livro Interativo Espiritual" de Next.js para Flutter Web. O sistema será reconstruído como uma aplicação Flutter Web standalone que também pode ser integrada como módulo no aplicativo "No Secreto". O foco é criar uma experiência emocional profunda que conduza o usuário através de uma jornada espiritual, desde o reconhecimento da orfandade espiritual até o diálogo íntimo com o Pai.

**Contexto Crítico**: Este não é um projeto novo - é uma evolução de um sistema Next.js existente e funcional. Todos os dados do Supabase devem ser preservados e reutilizados. A migração deve manter a funcionalidade existente enquanto adiciona novas experiências (Entry Screen, Carta de um Órfão com vídeo, Preparação para Chat).

**Filosofia de Experiência Emocional**: O sistema segue a Regra de Ouro: "O usuário sempre tem liberdade técnica… mas a experiência faz ele desejar emocionalmente o caminho certo." Cada tela é projetada para conduzir emocionalmente sem forçar tecnicamente, usando hierarquia visual, copy emocional, e timing para criar desejo natural pelo fluxo ideal. Não usamos dark patterns ou bloqueios artificiais - respeitamos a autonomia do usuário enquanto fornecemos orientação emocional clara.

## Glossary

- **System**: A aplicação Flutter Web "Jornada Deus é Pai"
- **User**: Pessoa acessando a aplicação para realizar a jornada espiritual
- **Entry_Screen**: Tela inicial emocional que apresenta a jornada e oferece dois caminhos
- **Livro_1**: Carta de um Órfão - experiência imersiva linear sem capítulos (conteúdo gratuito)
- **Livro_2**: Journey System - sistema de capítulos sequenciais com reflexões (conteúdo pago futuro)
- **Carta_de_um_Orfao**: Experiência emocional imersiva (Livro 1) que parece uma "leitura viva" com narração sincronizada
- **Hybrid_Experience**: Experiência que combina texto progressivo com narração, criando sensação de "alguém falando comigo"
- **Progressive_Text_Blocks**: Blocos de texto que aparecem sincronizados com narração, não todos de uma vez
- **Journey_System**: Sistema de capítulos sequenciais com conteúdo espiritual (Livro 2)
- **Chapter**: Unidade discreta de conteúdo espiritual no Livro 2
- **Reflection**: Texto pessoal que o usuário escreve durante um capítulo do Livro 2
- **Transition_Screen**: Tela obrigatória após Carta de um Órfão que transforma emoção em decisão
- **Preparation_Screen**: Tela de transição antes do chat que reforça a identidade de filho
- **Chat_Interface**: Interface de conversa com o Pai (fora do escopo desta spec, mas destino da jornada)
- **Progress_Tracking**: Sistema de rastreamento do progresso do usuário
- **Seal**: Conquista/selo digital desbloqueável
- **Paid_Content**: Conteúdo que requer pagamento para acesso (Livro 2)
- **Supabase**: Backend existente com autenticação e dados
- **Feature_Module**: Módulo Flutter independente que pode ser integrado em outro app
- **No_Secreto_App**: Aplicativo principal que futuramente integrará este módulo
- **Riverpod**: Biblioteca de state management para Flutter
- **Immersive_Experience**: Experiência que não parece um player de vídeo tradicional
- **Emotional_Guidance**: Estratégia de design que conduz usuário emocionalmente sem forçar tecnicamente
- **Golden_Rule**: Princípio fundamental - usuário tem liberdade técnica, mas experiência cria desejo emocional pelo caminho certo

## Requirements

### Requirement 1: Flutter Web Application Architecture

**User Story:** Como desenvolvedor, quero uma aplicação Flutter Web bem arquitetada, para que o código seja mantível e possa ser integrado no app "No Secreto".

#### Acceptance Criteria

1. THE System SHALL be built using Flutter framework with web support enabled
2. THE System SHALL use feature-based architecture with modular organization
3. THE System SHALL use flutter_riverpod (^2.5.0) for state management
4. THE System SHALL use supabase_flutter (^2.8.3) for backend integration
5. THE System SHALL use equatable (^2.0.7) for value equality
6. THE System SHALL organize code into feature modules (entry, carta, journey, preparation, shared)
7. THE System SHALL separate presentation, domain, and data layers within each feature
8. THE System SHALL NOT have hard dependencies on navigation (to allow integration into No_Secreto_App)
9. THE System SHALL expose a public API for external navigation integration
10. THE System SHALL be deployable as standalone Flutter Web application

### Requirement 2: Entry Screen - Emotional Introduction

**User Story:** Como usuário, quero ser recebido com uma mensagem emocional sobre orfandade espiritual, para que eu me identifique com a jornada antes de começar.

#### Acceptance Criteria

1. THE System SHALL display Entry_Screen as the first screen for new or returning users
2. THE Entry_Screen SHALL display emotional text content about spiritual orphanhood
3. THE Entry_Screen SHALL include a primary button labeled "Começar pela raiz"
4. WHEN User clicks "Começar pela raiz", THE System SHALL navigate to Carta_de_um_Orfao (Livro_1)
5. THE Entry_Screen SHALL include a secondary button labeled "Ir direto falar com o Pai"
6. WHEN User clicks "Ir direto falar com o Pai", THE System SHALL navigate to Preparation_Screen (skipping Livro_1)
7. THE Entry_Screen SHALL use minimalist design with strong typography
8. THE Entry_Screen SHALL use dark theme with warm accent colors
9. THE Entry_Screen SHALL be responsive for mobile and desktop viewports
10. THE Entry_Screen SHALL NOT block any navigation path (both buttons always accessible)

### Requirement 3: Carta de um Órfão - Immersive Hybrid Experience (Livro 1)

**User Story:** Como usuário, quero vivenciar a "Carta de um Órfão" como uma experiência híbrida imersiva, para que eu sinta que "alguém está falando comigo" e não que estou assistindo conteúdo ou lendo texto.

#### Acceptance Criteria

1. THE System SHALL display Carta_de_um_Orfao as Livro_1 (linear, single experience, no chapters)
2. THE System SHALL create a Hybrid_Experience combining progressive text with synchronized narration
3. THE Carta_de_um_Orfao SHALL display text in Progressive_Text_Blocks synchronized with narration
4. EACH text block SHALL appear as narration reaches that section
5. THE System SHALL NOT display traditional media controls (play button, pause button, timeline, volume slider, seek bar)
6. WHEN User taps screen, THE System SHALL advance to next text block
7. WHEN User holds screen, THE System SHALL pause narration and text progression
8. WHEN User releases hold, THE System SHALL resume from pause point
9. THE System SHALL auto-advance text blocks if User does not interact
10. THE text blocks SHALL appear with subtle fade-in animation
11. THE experience SHALL feel like "someone speaking to me" not "watching content" or "reading text"
12. THE System SHALL use intimate, personal tone in visual design
13. THE System SHALL maintain emotional atmosphere without technical distractions
14. THE pause control SHALL be discreet (no visible pause button, only hold gesture)
15. THE System SHALL use clean background design (dark or paper-like texture)
16. THE System SHALL use soft, readable typography optimized for emotional impact
17. THE System SHALL synchronize narration audio with text content display
18. THE System SHALL auto-play the experience when User enters the screen
19. THE System SHALL display "Continuar" button at the end of the experience
20. WHEN User clicks "Continuar", THE System SHALL navigate to Transition_Screen
21. THE System SHALL use full-screen immersive layout on mobile
22. THE System SHALL use centered, focused layout on desktop
23. THE System SHALL maintain emotional atmosphere throughout the experience
24. THE System SHALL NOT resemble a traditional video player interface
25. THE System SHALL create sensation of personal conversation, not content consumption
26. THE text blocks SHALL appear in conversational rhythm matching narration pace
27. THE System SHALL use maximum contrast for text readability against background

### Requirement 3.5: Transition Screen - Minimalist Emotional Conversion Point (Mandatory)

**User Story:** Como usuário, quero uma tela de transição minimalista e profunda após a Carta de um Órfão, para que minha emoção seja transformada em decisão de falar com o Pai sem distrações.

#### Acceptance Criteria

1. THE System SHALL display Transition_Screen ALWAYS after User completes Carta_de_um_Orfao
2. THE Transition_Screen SHALL be mandatory and NOT automatically skippable
3. THE Transition_Screen SHALL use extreme minimalist design with zero distractions
4. THE Transition_Screen SHALL display message in two parts with visual pause between them
5. THE first message part SHALL be: "Talvez você nunca tenha sido apresentado ao seu verdadeiro Pai."
6. THE System SHALL display visual pause (breathing space) between message parts
7. THE second message part SHALL be: "Mas isso pode começar agora."
8. THE Transition_Screen SHALL display ONLY ONE button (no secondary actions)
9. THE button SHALL be labeled "Falar com o Pai pela primeira vez"
10. WHEN User clicks the button, THE System SHALL navigate to Preparation_Screen
11. THE Transition_Screen SHALL NOT include decorative elements that distract from message
12. THE Transition_Screen SHALL NOT display navigation breadcrumbs or back buttons
13. THE Transition_Screen SHALL use maximum contrast for message readability
14. THE Transition_Screen SHALL be the conversion point of the entire system
15. THE message SHALL be emotionally direct and personal
16. THE design SHALL create moment of decision, not just information display
17. THE Transition_Screen SHALL maintain the emotional climate from Carta_de_um_Orfao
18. THE Transition_Screen SHALL use soft transitions and animations
19. THE Transition_Screen SHALL naturally guide User to the next step without feeling forced
20. THE Transition_Screen SHALL be a distinct screen (not a modal or overlay)
21. THE Transition_Screen SHALL NOT provide navigation back to Carta (forward-only flow)
22. THE Transition_Screen SHALL NOT display multiple buttons or alternative actions
23. THE Transition_Screen SHALL focus all attention on the message and single action
24. THE visual design SHALL eliminate all technical distractions
25. THE message parts SHALL have sufficient spacing to create emotional impact
26. THE button SHALL be visually prominent but not aggressive
27. THE Transition_Screen SHALL be the culmination of emotional journey from Carta

### Requirement 4: Journey System - Chapter Navigation (Livro 2 - Future Paid Content)

**User Story:** Como usuário, quero navegar por capítulos sequenciais de conteúdo espiritual (Livro 2), para que eu progrida através da jornada de forma estruturada após a experiência inicial.

#### Acceptance Criteria

1. THE System SHALL implement Journey_System as Livro_2 (separate from Carta de um Órfão)
2. THE Journey_System SHALL be prepared for future paid content monetization
3. THE System SHALL display chapters in sequential order based on chapter_number
4. THE System SHALL load chapter data from Supabase chapters table
5. THE System SHALL display chapter title and subtitle
6. THE System SHALL render chapter content as formatted text
7. THE System SHALL display visual progress indicator showing current chapter position
8. THE System SHALL display "Próximo Capítulo" button at the end of each chapter
9. WHEN User completes a chapter, THE System SHALL mark it as completed in user_progress
10. WHEN User clicks "Próximo Capítulo", THE System SHALL navigate to next chapter
11. THE System SHALL unlock next chapter when current chapter is completed
12. THE System SHALL allow User to navigate back to previous completed chapters
13. THE System SHALL display locked indicator for chapters not yet unlocked
14. THE Journey_System SHALL be clearly separated from Livro_1 (Carta de um Órfão)
15. THE Journey_System SHALL NOT be accessible directly from Entry_Screen (only after Transition_Screen)

### Requirement 5: Journey System - Reflection Input

**User Story:** Como usuário, quero escrever reflexões pessoais durante os capítulos, para que eu processe emocionalmente o conteúdo e salve meus pensamentos.

#### Acceptance Criteria

1. THE System SHALL display reflection input field within chapter view
2. THE reflection input field SHALL be a multi-line text area
3. THE System SHALL display placeholder text "Escreva suas reflexões..."
4. WHEN User types in reflection field, THE System SHALL save draft locally
5. THE System SHALL provide "Salvar Reflexão" button
6. WHEN User clicks "Salvar Reflexão", THE System SHALL store reflection in Supabase
7. THE System SHALL associate reflection with User ID and Chapter ID
8. THE System SHALL display previously saved reflections when User returns to chapter
9. THE System SHALL allow User to edit previously saved reflections
10. THE System SHALL display save confirmation message after successful save

### Requirement 5.5: Monetization Architecture Preparation (No Implementation Yet)

**User Story:** Como desenvolvedor, quero preparar a arquitetura para conteúdo pago, para que o sistema possa suportar monetização futura do Livro 2 sem refatoração major.

#### Acceptance Criteria

1. THE System SHALL prepare database schema to support paid content distinction
2. THE chapters table SHALL include is_paid_content BOOLEAN field (default: false)
3. THE System SHALL create user_purchased_content table with fields: id, user_id, content_type, content_id, purchased_at, payment_method
4. THE System SHALL verify User access before displaying chapter content
5. WHEN chapter has is_paid_content=true AND User has NOT purchased, THE System SHALL display "Conteúdo Bloqueado" indicator
6. THE System SHALL prepare UI components for locked content display
7. THE System SHALL NOT implement payment gateway in this phase
8. THE System SHALL NOT implement purchase flow in this phase
9. THE Livro_1 (Carta de um Órfão) SHALL always be free (is_paid_content=false)
10. THE Livro_2 (Journey System chapters) SHALL be marked as is_paid_content=true for future monetization
11. THE System SHALL log access attempts to paid content for analytics
12. THE System SHALL provide clear separation between free and paid content in data model

### Requirement 6: Preparation Screen - Chat Transition

**User Story:** Como usuário, quero uma tela de preparação antes de ir para o chat, para que eu me sinta emocionalmente pronto para conversar com o Pai.

#### Acceptance Criteria

1. THE System SHALL display Preparation_Screen after User completes Transition_Screen
2. THE System SHALL display Preparation_Screen when User clicks "Ir direto falar com o Pai" from Entry_Screen (skipping Livro_1)
3. THE Preparation_Screen SHALL display emotional text reinforcing User's identity as filho/filha
4. THE Preparation_Screen SHALL display affirmations about being loved and accepted
5. THE Preparation_Screen SHALL include "Estou pronto para conversar" button
6. WHEN User clicks "Estou pronto para conversar", THE System SHALL navigate to Chat_Interface
7. THE Preparation_Screen SHALL use calming visual design with soft colors
8. THE Preparation_Screen SHALL display breathing exercise or moment of pause
9. THE Preparation_Screen SHALL be skippable (User can proceed immediately)
10. THE Preparation_Screen SHALL NOT require any input from User
11. THE Preparation_Screen SHALL serve as identity reinforcement before chat
12. THE Preparation_Screen SHALL be accessible from two paths: after Transition_Screen OR directly from Entry_Screen

### Requirement 7: Progress Tracking and Persistence

**User Story:** Como usuário, quero que meu progresso seja salvo automaticamente, para que eu possa continuar de onde parei em qualquer dispositivo.

#### Acceptance Criteria

1. THE System SHALL track User progress in Supabase user_progress table
2. WHEN User completes a chapter, THE System SHALL update status to 'completed'
3. WHEN User starts a chapter, THE System SHALL update status to 'in_progress'
4. THE System SHALL record started_at timestamp when chapter is first accessed
5. THE System SHALL record completed_at timestamp when chapter is completed
6. THE System SHALL update last_accessed_at timestamp on each chapter access
7. THE System SHALL calculate and store progress_percentage for each chapter
8. THE System SHALL track time_spent in seconds for each chapter
9. WHEN User logs in, THE System SHALL restore progress from Supabase
10. THE System SHALL sync progress across devices in real-time

### Requirement 8: Seal System Integration

**User Story:** Como usuário, quero desbloquear selos/conquistas durante minha jornada, para que eu tenha reconhecimento simbólico do meu progresso.

#### Acceptance Criteria

1. THE System SHALL check seal unlock conditions after each chapter completion
2. THE System SHALL load seal definitions from Supabase seals table
3. WHEN seal unlock condition is met, THE System SHALL award seal to User
4. THE System SHALL store awarded seals in Supabase user_seals table
5. THE System SHALL display seal award animation when seal is unlocked
6. THE System SHALL display seal name, description, and icon
7. THE System SHALL display "Faço parte do movimento Deus é Pai" for journey completion seal
8. THE System SHALL display User's total seal count in profile
9. THE System SHALL allow User to view all unlocked seals
10. THE System SHALL display locked seals with hint about unlock condition

### Requirement 9: Authentication Integration

**User Story:** Como usuário, quero fazer login com minha conta existente do Supabase, para que eu acesse meus dados salvos da versão Next.js.

#### Acceptance Criteria

1. THE System SHALL integrate with existing Supabase authentication
2. THE System SHALL support email/password authentication
3. THE System SHALL support OAuth providers (Google, Apple) if configured
4. THE System SHALL display login screen for unauthenticated users
5. THE System SHALL display signup screen for new users
6. WHEN User successfully authenticates, THE System SHALL load User profile from profiles table
7. THE System SHALL maintain session state using Supabase session management
8. THE System SHALL automatically refresh expired sessions
9. THE System SHALL provide logout functionality
10. WHEN User logs out, THE System SHALL clear local state and return to Entry_Screen

### Requirement 10: Data Migration and Compatibility

**User Story:** Como desenvolvedor, quero garantir compatibilidade total com os dados existentes do Next.js, para que nenhum dado de usuário seja perdido na migração.

#### Acceptance Criteria

1. THE System SHALL read from existing Supabase schema without modifications
2. THE System SHALL use profiles table with fields: id, nome, email, perfil_is_complete, senha_is_seted, total_seals, current_chapter
3. THE System SHALL use chapters table with fields: id, chapter_number, title, subtitle, content, summary, required_seals, estimated_time, difficulty, is_paid_content
4. THE System SHALL use user_progress table with fields: id, user_id, chapter_id, status, progress_percentage, time_spent, started_at, completed_at, last_accessed_at
5. THE System SHALL use seals table with fields: id, code, name, description, icon_url, category, rarity, points
6. THE System SHALL use user_seals table with fields: id, user_id, seal_id, unlocked_at, source
7. THE System SHALL create new table user_reflections with fields: id, user_id, chapter_id, content, created_at, updated_at
8. THE System SHALL create new table user_journey_stage with fields: id, user_id, current_stage, last_stage_at
9. THE System SHALL create new table user_purchased_content with fields: id, user_id, content_type, content_id, purchased_at, payment_method
10. THE System SHALL handle missing or null fields gracefully
11. THE System SHALL maintain backward compatibility with Next.js app accessing same database

### Requirement 11: Responsive Design and Accessibility

**User Story:** Como usuário, quero que a aplicação funcione bem no meu celular e seja acessível, para que eu possa usar em qualquer dispositivo e condição.

#### Acceptance Criteria

1. THE System SHALL implement mobile-first responsive design
2. THE System SHALL adapt layout for screen widths: mobile (<600px), tablet (600-1024px), desktop (>1024px)
3. THE System SHALL use minimum touch target size of 48x48 logical pixels
4. THE System SHALL support screen readers with semantic HTML and ARIA labels
5. THE System SHALL provide sufficient color contrast (WCAG AA minimum 4.5:1)
6. THE System SHALL support keyboard navigation for all interactive elements
7. THE System SHALL display focus indicators on interactive elements
8. THE System SHALL use scalable text that respects user font size preferences
9. THE System SHALL provide alternative text for all images and icons
10. THE System SHALL test with Flutter accessibility tools and screen readers

### Requirement 12: Performance and Offline Support

**User Story:** Como usuário, quero que a aplicação carregue rapidamente e funcione offline quando possível, para que eu tenha uma experiência fluida mesmo com conexão instável.

#### Acceptance Criteria

1. THE System SHALL achieve initial load time under 3 seconds on 3G connection
2. THE System SHALL cache chapter content locally after first load
3. THE System SHALL display cached content when offline
4. THE System SHALL queue reflection saves when offline and sync when online
5. THE System SHALL display offline indicator when network is unavailable
6. THE System SHALL preload next chapter content in background
7. THE System SHALL optimize images and videos for web delivery
8. THE System SHALL use lazy loading for non-critical content
9. THE System SHALL minimize bundle size using code splitting
10. THE System SHALL display loading indicators for async operations

### Requirement 13: Immersive Audio-Text Synchronization

**User Story:** Como desenvolvedor, quero implementar sincronização robusta entre áudio e texto para a Carta de um Órfão, para que usuários tenham uma experiência imersiva confiável em diferentes navegadores.

#### Acceptance Criteria

1. THE System SHALL use audio player package for narration playback
2. THE System SHALL support MP3 or AAC audio formats
3. THE System SHALL synchronize text display with audio timestamps
4. THE System SHALL display loading indicator while audio buffers
5. THE System SHALL handle audio load errors gracefully
6. WHEN audio fails to load, THE System SHALL display error message and allow text-only reading
7. THE System SHALL provide discreet pause/resume control
8. THE System SHALL remember playback position if User navigates away
9. THE System SHALL display subtle progress indicator (not traditional timeline)
10. THE System SHALL work across major browsers (Chrome, Safari, Firefox, Edge)
11. THE System SHALL NOT display traditional media player controls
12. THE System SHALL maintain immersive atmosphere throughout playback

### Requirement 14: State Management with Riverpod

**User Story:** Como desenvolvedor, quero usar Riverpod para state management, para que o estado da aplicação seja previsível e testável.

#### Acceptance Criteria

1. THE System SHALL use flutter_riverpod for all state management
2. THE System SHALL define providers for authentication state
3. THE System SHALL define providers for user profile state
4. THE System SHALL define providers for chapter data and navigation
5. THE System SHALL define providers for progress tracking
6. THE System SHALL define providers for seal management
7. THE System SHALL use StateNotifier for complex state logic
8. THE System SHALL use FutureProvider for async data loading
9. THE System SHALL use StreamProvider for real-time Supabase updates
10. THE System SHALL implement proper provider disposal to prevent memory leaks

### Requirement 15: Feature Module Independence

**User Story:** Como desenvolvedor, quero que cada feature seja um módulo independente, para que o código seja organizado e possa ser integrado no app "No Secreto".

#### Acceptance Criteria

1. THE System SHALL organize code into feature folders: entry, carta, journey, preparation, shared
2. EACH feature module SHALL contain: presentation (screens, widgets), domain (models, use cases), data (repositories, data sources)
3. THE System SHALL define clear public APIs for each feature module
4. THE System SHALL use dependency injection for cross-feature dependencies
5. THE System SHALL NOT allow direct imports between feature modules (only through shared)
6. THE shared module SHALL contain: core utilities, common widgets, theme, constants
7. THE System SHALL define navigation contracts that can be implemented externally
8. THE System SHALL expose JornadaDeusePaiModule as entry point for integration
9. THE JornadaDeusePaiModule SHALL accept navigation callbacks from parent app
10. THE System SHALL be testable in isolation without parent app

### Requirement 16: Theme and Visual Design

**User Story:** Como usuário, quero uma interface visualmente atraente com tema escuro, para que a experiência seja imersiva e emocionalmente envolvente.

#### Acceptance Criteria

1. THE System SHALL use dark theme as default
2. THE System SHALL define color palette: primary (warm gold/amber), secondary (soft blue), background (dark gray/black), surface (dark gray), error (soft red)
3. THE System SHALL use consistent typography scale with font family optimized for readability
4. THE System SHALL use heading styles: H1 (32sp), H2 (24sp), H3 (20sp), Body (16sp), Caption (14sp)
5. THE System SHALL use consistent spacing scale: 4, 8, 16, 24, 32, 48, 64 logical pixels
6. THE System SHALL use rounded corners (8px) for cards and buttons
7. THE System SHALL use subtle shadows for elevation
8. THE System SHALL implement smooth transitions and animations (300ms duration)
9. THE System SHALL use fade-in animations for content appearance
10. THE System SHALL maintain visual consistency across all screens

### Requirement 17: Error Handling and User Feedback

**User Story:** Como usuário, quero receber feedback claro quando algo dá errado, para que eu saiba o que aconteceu e o que fazer.

#### Acceptance Criteria

1. THE System SHALL display user-friendly error messages in Portuguese
2. WHEN network error occurs, THE System SHALL display "Problema de conexão. Verifique sua internet."
3. WHEN authentication fails, THE System SHALL display specific error message
4. WHEN data save fails, THE System SHALL display "Não foi possível salvar. Tente novamente."
5. THE System SHALL log detailed errors for debugging (not shown to user)
6. THE System SHALL display loading indicators during async operations
7. THE System SHALL display success messages after important actions (save, completion)
8. THE System SHALL use SnackBar or Toast for temporary messages
9. THE System SHALL use Dialog for critical errors requiring user action
10. THE System SHALL provide retry mechanism for failed operations

### Requirement 18: Content Parser for Chapter Rendering

**User Story:** Como desenvolvedor, quero um parser robusto para renderizar conteúdo dos capítulos, para que o texto seja formatado corretamente com markdown e estilos.

#### Acceptance Criteria

1. THE System SHALL parse chapter content from TEXT field in database
2. THE Content_Parser SHALL support markdown formatting (bold, italic, headings, lists)
3. THE Content_Parser SHALL support line breaks and paragraphs
4. THE Content_Parser SHALL support embedded images via markdown syntax
5. THE Content_Parser SHALL validate content structure before rendering
6. WHEN content is invalid, THE Content_Parser SHALL return descriptive error
7. THE Content_Parser SHALL sanitize content to prevent XSS attacks
8. THE Content_Parser SHALL render content using Flutter widgets (not WebView)
9. THE Content_Parser SHALL support custom styling for spiritual quotes
10. FOR ALL valid content, parsing then rendering SHALL produce readable formatted text

### Requirement 19: Navigation and Routing

**User Story:** Como usuário, quero navegar facilmente entre telas, para que eu possa explorar a jornada sem me perder.

#### Acceptance Criteria

1. THE System SHALL implement declarative routing using go_router or similar
2. THE System SHALL define routes: /entry, /carta, /transition, /journey/:chapterId, /preparation, /chat
3. THE System SHALL support deep linking to specific chapters
4. THE System SHALL maintain navigation history for back button
5. THE System SHALL handle browser back/forward buttons correctly
6. THE System SHALL preserve scroll position when navigating back
7. THE System SHALL display navigation breadcrumbs on desktop
8. THE System SHALL provide "Voltar" button on all screens except Entry_Screen and Transition_Screen
9. THE System SHALL prevent navigation to locked chapters via URL manipulation
10. THE System SHALL redirect unauthenticated users to login screen
11. THE System SHALL enforce forward-only flow from Carta to Transition to Preparation
12. THE Transition_Screen SHALL NOT allow back navigation to Carta

### Requirement 20: Testing Strategy

**User Story:** Como desenvolvedor, quero testes automatizados abrangentes, para que eu tenha confiança na qualidade e correção do código.

#### Acceptance Criteria

1. THE System SHALL include unit tests for all business logic and state management
2. THE System SHALL include widget tests for all custom widgets
3. THE System SHALL include integration tests for critical user flows
4. THE System SHALL achieve minimum 80% code coverage
5. THE System SHALL test authentication flow (login, signup, logout)
6. THE System SHALL test chapter navigation and progress tracking
7. THE System SHALL test reflection save and retrieval
8. THE System SHALL test seal unlock conditions
9. THE System SHALL test offline functionality
10. THE System SHALL test error handling and edge cases

### Requirement 21: Deployment and CI/CD

**User Story:** Como desenvolvedor, quero pipeline de CI/CD automatizado, para que deploys sejam confiáveis e rápidos.

#### Acceptance Criteria

1. THE System SHALL use GitHub Actions for CI/CD pipeline
2. THE CI pipeline SHALL run tests on every pull request
3. THE CI pipeline SHALL run linting and code analysis
4. THE CI pipeline SHALL build Flutter Web bundle
5. THE CD pipeline SHALL deploy to staging environment on merge to develop branch
6. THE CD pipeline SHALL deploy to production on merge to main branch
7. THE System SHALL be hosted on Firebase Hosting or Vercel
8. THE System SHALL use environment variables for Supabase configuration
9. THE System SHALL generate source maps for debugging
10. THE System SHALL monitor deployment success and rollback on failure

### Requirement 22: Integration with No Secreto App

**User Story:** Como desenvolvedor do app "No Secreto", quero integrar o módulo Jornada Deus é Pai, para que usuários acessem a jornada dentro do app principal.

#### Acceptance Criteria

1. THE System SHALL expose JornadaDeusePaiModule as public Flutter package
2. THE JornadaDeusePaiModule SHALL accept NavigationDelegate for custom navigation
3. THE JornadaDeusePaiModule SHALL accept ThemeData for visual consistency with parent app
4. THE JornadaDeusePaiModule SHALL emit events for journey milestones (chapter completed, seal unlocked)
5. THE JornadaDeusePaiModule SHALL accept initial route parameter
6. THE JornadaDeusePaiModule SHALL NOT depend on specific navigation library
7. THE JornadaDeusePaiModule SHALL provide example integration code
8. THE JornadaDeusePaiModule SHALL document public API in README
9. THE JornadaDeusePaiModule SHALL version using semantic versioning
10. THE JornadaDeusePaiModule SHALL be publishable to pub.dev or private registry

### Requirement 23: User Journey Stage Tracking

**User Story:** Como sistema, quero rastrear em qual estágio da jornada o usuário está, para que eu possa personalizar a experiência e retomar de onde parou.

#### Acceptance Criteria

1. THE System SHALL track current journey stage in user_journey_stage table
2. THE System SHALL define stages: 'entry', 'carta', 'transition', 'journey', 'preparation', 'chat'
3. WHEN User completes Entry_Screen, THE System SHALL update stage to 'carta' or 'preparation'
4. WHEN User completes Carta_de_um_Orfao, THE System SHALL update stage to 'transition'
5. WHEN User completes Transition_Screen, THE System SHALL update stage to 'preparation'
6. WHEN User completes Preparation_Screen, THE System SHALL update stage to 'chat'
7. THE System SHALL record last_stage_at timestamp on each stage change
8. WHEN User returns, THE System SHALL resume from last stage
9. THE System SHALL allow User to revisit previous stages (except transition which is forward-only)
10. THE System SHALL use stage data for analytics and personalization
11. THE 'journey' stage SHALL be reserved for future Livro_2 implementation
12. THE System SHALL distinguish between Livro_1 path (entry → carta → transition → preparation) and direct path (entry → preparation)

### Requirement 24: Content Management Preparation

**User Story:** Como administrador, quero que o sistema esteja preparado para gerenciamento de conteúdo futuro, para que eu possa atualizar capítulos e vídeos sem deploy de código.

#### Acceptance Criteria

1. THE System SHALL load all content from Supabase (not hardcoded)
2. THE System SHALL support video URL configuration in database
3. THE System SHALL cache content with configurable TTL
4. THE System SHALL refresh content when cache expires
5. THE System SHALL provide manual refresh mechanism for content
6. THE System SHALL validate content structure on load
7. THE System SHALL handle missing content gracefully
8. THE System SHALL support content versioning (future enhancement)
9. THE System SHALL log content load errors for monitoring
10. THE System SHALL display content update notification when new content available

### Requirement 25: Analytics and Monitoring

**User Story:** Como product owner, quero dados sobre como usuários interagem com a jornada, para que eu possa melhorar a experiência.

#### Acceptance Criteria

1. THE System SHALL integrate with Firebase Analytics or similar
2. THE System SHALL track screen views for all major screens (entry, carta, transition, preparation, journey, chat)
3. THE System SHALL track chapter completion events
4. THE System SHALL track reflection save events
5. THE System SHALL track seal unlock events
6. THE System SHALL track audio play/pause/complete events for Carta de um Órfão
7. THE System SHALL track navigation path choices (raiz vs direto)
8. THE System SHALL track time spent on each screen
9. THE System SHALL track error occurrences
10. THE System SHALL respect user privacy and LGPD compliance
11. THE System SHALL track Transition_Screen button clicks
12. THE System SHALL track conversion rate from Carta to Transition to Preparation
13. THE System SHALL track paid content access attempts for future monetization insights

### Requirement 26: Design Philosophy and User Guidance (Golden Rule)

**User Story:** Como designer do sistema, quero seguir uma filosofia clara de experiência do usuário, para que o sistema conduza emocionalmente sem forçar tecnicamente.

#### Acceptance Criteria

1. THE System SHALL follow the Golden_Rule: "User has technical freedom, but experience creates emotional desire for the right path"
2. THE System SHALL NOT use dark patterns or artificial blocks to force user behavior
3. THE System SHALL use visual hierarchy to guide user attention to primary actions
4. THE System SHALL use emotional copy and timing to create natural desire for intended flow
5. THE Entry_Screen SHALL make "Começar pela raiz" visually primary while keeping "Ir direto" accessible
6. THE Carta_de_um_Orfao SHALL make continuation natural while allowing pause
7. THE Transition_Screen SHALL create emotional desire to proceed without technical forcing
8. THE System SHALL respect user autonomy while providing clear Emotional_Guidance
9. THE System SHALL measure conversion rates to validate emotional guidance effectiveness
10. THE System SHALL NOT punish users who choose alternative paths
11. THE design decisions SHALL prioritize emotional resonance over technical constraints
12. THE System SHALL create experiences where users WANT to follow the intended journey
13. THE System SHALL apply Golden_Rule to all user interactions and navigation decisions
14. THE System SHALL use design, copy, and timing as primary guidance tools
15. THE System SHALL maintain balance between freedom and guidance in all features
16. THE System SHALL validate that technical freedom exists for all user choices
17. THE System SHALL ensure emotional guidance enhances rather than manipulates experience
18. THE System SHALL document design decisions that implement Golden_Rule principles
19. THE System SHALL test user flows to confirm natural emotional progression
20. THE System SHALL avoid blocking, forcing, or restricting user navigation artificially

