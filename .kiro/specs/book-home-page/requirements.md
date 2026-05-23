# Requirements Document

## Introduction

Este documento especifica os requisitos para a página inicial de leitura do livro espiritual "Não Ore, Fale com o Pai" em Flutter Web. A página serve como portal de entrada para a jornada espiritual, preparando emocionalmente o leitor antes de iniciar a leitura dos capítulos. O sistema deve criar uma experiência contemplativa e profunda, gerenciando o progresso do usuário através dos capítulos do livro.

## Glossary

- **Book_Home_Page**: A página inicial de leitura que exibe o progresso e os capítulos disponíveis
- **Chapter**: Um capítulo individual do livro espiritual
- **User_Progress**: O estado atual de leitura do usuário, incluindo capítulo atual e capítulos completados
- **Reflection_Quote**: Frase profunda exibida para preparar o coração do leitor
- **Chapter_Lock**: Estado que impede acesso a capítulos não liberados
- **Progress_State**: Provedor Riverpod que gerencia o estado de progresso do usuário
- **Local_Storage**: Armazenamento local do navegador para persistir progresso
- **Fade_Animation**: Animação de transição suave entre estados de opacidade
- **Reading_Page**: Página de leitura do conteúdo de um capítulo específico
- **CTA_Button**: Botão de chamada para ação (Call-to-Action) principal da página

## Requirements

### Requirement 1: Visual Design System

**User Story:** Como um leitor, eu quero uma interface visualmente contemplativa e minimalista, para que eu possa me preparar emocionalmente para a leitura espiritual.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL use black background (#000000)
2. THE Book_Home_Page SHALL use white text (#FFFFFF) for primary content
3. THE Book_Home_Page SHALL use gold accent color (#D4AF37) for highlights and emphasis
4. THE Book_Home_Page SHALL maintain generous spacing between all visual elements
5. THE Book_Home_Page SHALL apply minimalist design principles with no visual clutter

### Requirement 2: Header Display

**User Story:** Como um leitor, eu quero ver o título e subtítulo do livro no topo da página, para que eu saiba qual jornada estou iniciando.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL display "Não Ore, Fale com o Pai" as the main title in small text
2. THE Book_Home_Page SHALL display "uma jornada de volta ao relacionamento" as subtitle below the title
3. THE Book_Home_Page SHALL position the header at the top of the page with appropriate spacing

### Requirement 3: Reflection Quotes Display

**User Story:** Como um leitor, eu quero ver frases reflexivas profundas, para que eu possa entrar em um estado contemplativo antes de começar a leitura.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL display 3 to 5 reflection quotes in the center section
2. THE Book_Home_Page SHALL display the quote "Quando foi a última vez que você se sentiu realmente visto?"
3. THE Book_Home_Page SHALL display the quote "Você fala com Deus… ou só repete palavras?"
4. THE Book_Home_Page SHALL display the quote "Você se sente filho… ou apenas alguém tentando acertar?"
5. THE Book_Home_Page SHALL arrange quotes vertically with generous spacing between each quote
6. WHEN the Book_Home_Page loads, THE Book_Home_Page SHALL animate each quote with fade-in effect

### Requirement 4: Fade-In Animations

**User Story:** Como um leitor, eu quero que os elementos apareçam suavemente na tela, para que a experiência seja contemplativa e não abrupta.

#### Acceptance Criteria

1. WHEN the Book_Home_Page loads, THE Fade_Animation SHALL animate elements with duration between 400ms and 700ms
2. WHEN displaying multiple Reflection_Quotes, THE Fade_Animation SHALL apply a staggered delay between each quote
3. THE Fade_Animation SHALL use smooth easing curves for natural motion
4. THE Fade_Animation SHALL transition opacity from 0.0 to 1.0

### Requirement 5: Progress Display

**User Story:** Como um leitor, eu quero ver meu progresso na jornada, para que eu saiba onde estou no livro.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL display the text "Seu progresso na jornada"
2. WHEN User_Progress exists, THE Book_Home_Page SHALL display current chapter number and total chapters
3. THE Book_Home_Page SHALL format progress as "Capítulo X de Y" where X is current and Y is total
4. THE Book_Home_Page SHALL display progress information above the chapter list

### Requirement 6: Chapter List Display

**User Story:** Como um leitor, eu quero ver a lista de capítulos do livro, para que eu saiba quais capítulos estão disponíveis.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL display all chapters in a vertical list
2. THE Book_Home_Page SHALL display chapter number and title for each Chapter
3. THE Book_Home_Page SHALL visually distinguish unlocked chapters from locked chapters
4. WHEN a Chapter is locked, THE Book_Home_Page SHALL display a lock icon (🔒) next to the chapter
5. WHEN a Chapter is locked, THE Book_Home_Page SHALL reduce the opacity of the chapter item
6. THE Book_Home_Page SHALL display chapters in sequential order from first to last

### Requirement 7: Chapter Unlock Logic

**User Story:** Como um leitor, eu quero que apenas capítulos liberados sejam acessíveis, para que eu siga a jornada na ordem correta.

#### Acceptance Criteria

1. WHEN the user first accesses the Book_Home_Page, THE Chapter_Lock SHALL unlock only Chapter 1
2. WHEN a Chapter is completed, THE Chapter_Lock SHALL unlock the next sequential Chapter
3. WHEN a Chapter is locked, THE Book_Home_Page SHALL prevent navigation to that Chapter
4. WHEN a Chapter is unlocked, THE Book_Home_Page SHALL allow navigation to that Chapter
5. THE Chapter_Lock SHALL maintain unlock state across browser sessions

### Requirement 8: Chapter Navigation

**User Story:** Como um leitor, eu quero clicar em capítulos desbloqueados para lê-los, para que eu possa avançar na jornada.

#### Acceptance Criteria

1. WHEN a user clicks an unlocked Chapter, THE Book_Home_Page SHALL navigate to the Reading_Page for that Chapter
2. WHEN a user clicks a locked Chapter, THE Book_Home_Page SHALL not navigate and SHALL provide no visual feedback
3. WHEN a user hovers over an unlocked Chapter, THE Book_Home_Page SHALL provide visual hover feedback
4. THE Book_Home_Page SHALL pass the chapter ID to the Reading_Page during navigation

### Requirement 9: Call-to-Action Button

**User Story:** Como um leitor, eu quero um botão principal que me leve para a leitura, para que eu tenha uma ação clara a tomar.

#### Acceptance Criteria

1. WHEN the user has never started reading, THE CTA_Button SHALL display "Começar leitura"
2. WHEN the user has started reading, THE CTA_Button SHALL display "Continuar leitura"
3. WHEN the CTA_Button is clicked and user has not started, THE Book_Home_Page SHALL navigate to Chapter 1
4. WHEN the CTA_Button is clicked and user has started, THE Book_Home_Page SHALL navigate to the current chapter in progress
5. THE CTA_Button SHALL be visually prominent and positioned below the chapter list

### Requirement 10: Progress State Management

**User Story:** Como um desenvolvedor, eu quero gerenciar o estado de progresso com Riverpod, para que o estado seja reativo e consistente.

#### Acceptance Criteria

1. THE Progress_State SHALL track the current chapter number
2. THE Progress_State SHALL track which chapters are completed
3. THE Progress_State SHALL track which chapters are unlocked
4. WHEN a chapter is completed, THE Progress_State SHALL update the completed chapters list
5. WHEN a chapter is completed, THE Progress_State SHALL unlock the next chapter
6. THE Progress_State SHALL notify all listeners when state changes

### Requirement 11: Progress Persistence

**User Story:** Como um leitor, eu quero que meu progresso seja salvo automaticamente, para que eu não perca meu lugar na jornada.

#### Acceptance Criteria

1. WHEN User_Progress changes, THE Book_Home_Page SHALL save progress to Local_Storage
2. WHEN the Book_Home_Page loads, THE Book_Home_Page SHALL load progress from Local_Storage
3. THE Book_Home_Page SHALL persist current chapter number
4. THE Book_Home_Page SHALL persist completed chapters list
5. THE Book_Home_Page SHALL persist unlocked chapters list
6. WHEN Local_Storage is empty, THE Book_Home_Page SHALL initialize with default progress (Chapter 1 unlocked)

### Requirement 12: Component Architecture

**User Story:** Como um desenvolvedor, eu quero uma arquitetura de componentes modular, para que o código seja manutenível e testável.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL be implemented in lib/features/book/presentation/pages/book_home_page.dart
2. THE Book_Home_Page SHALL use a separate widget for progress display
3. THE Book_Home_Page SHALL use a separate widget for chapter list display
4. THE Book_Home_Page SHALL use a separate widget for reflection quotes section
5. THE Book_Home_Page SHALL compose these widgets in the main page layout

### Requirement 13: Responsive Layout

**User Story:** Como um leitor usando diferentes tamanhos de tela, eu quero que a página se adapte ao meu dispositivo, para que a experiência seja ótima em qualquer tela.

#### Acceptance Criteria

1. WHEN the viewport width is less than 600px, THE Book_Home_Page SHALL use mobile layout with full-width elements
2. WHEN the viewport width is 600px or greater, THE Book_Home_Page SHALL use desktop layout with centered content
3. THE Book_Home_Page SHALL maintain readability across all viewport sizes
4. THE Book_Home_Page SHALL adjust spacing proportionally to viewport size

### Requirement 14: Accessibility

**User Story:** Como um leitor com necessidades de acessibilidade, eu quero que a página seja navegável e compreensível, para que eu possa participar da jornada espiritual.

#### Acceptance Criteria

1. THE Book_Home_Page SHALL provide semantic HTML structure for screen readers
2. THE Book_Home_Page SHALL provide sufficient color contrast between text and background
3. THE Book_Home_Page SHALL provide keyboard navigation for all interactive elements
4. THE Book_Home_Page SHALL provide focus indicators for keyboard navigation
5. WHEN a Chapter is locked, THE Book_Home_Page SHALL communicate lock status to screen readers

### Requirement 15: Loading State

**User Story:** Como um leitor, eu quero feedback visual durante o carregamento, para que eu saiba que o sistema está funcionando.

#### Acceptance Criteria

1. WHEN the Book_Home_Page is loading progress data, THE Book_Home_Page SHALL display a loading indicator
2. WHEN progress data is loaded, THE Book_Home_Page SHALL hide the loading indicator and display content
3. THE Book_Home_Page SHALL complete loading within 2 seconds under normal network conditions
4. WHEN loading fails, THE Book_Home_Page SHALL display an error message with retry option

### Requirement 16: Error Handling

**User Story:** Como um leitor, eu quero mensagens claras quando algo der errado, para que eu saiba como proceder.

#### Acceptance Criteria

1. WHEN Local_Storage is unavailable, THE Book_Home_Page SHALL display an error message
2. WHEN progress cannot be saved, THE Book_Home_Page SHALL notify the user
3. WHEN navigation fails, THE Book_Home_Page SHALL display an error message
4. THE Book_Home_Page SHALL provide actionable error messages that guide the user to resolution
