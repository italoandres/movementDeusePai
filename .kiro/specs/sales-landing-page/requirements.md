# Requirements Document: Sales Landing Page

## Introduction

Esta especificação define os requisitos para uma landing page de vendas (sales page) em Flutter Web para o livro "Não Ore, Fale com o Pai". A página deve criar uma experiência espiritual contemplativa e minimalista que conduza o visitante a um encontro com Deus como Pai, transcendendo o formato tradicional de páginas de vendas.

A landing page será implementada como uma nova feature no projeto Flutter existente (jornada_deus_pai), seguindo a arquitetura Clean Architecture com Riverpod para gerenciamento de estado.

## Glossary

- **Sales_Page**: A landing page web responsável por apresentar o livro e conduzir o visitante à conversão
- **Hero_Section**: Primeira seção visível da página contendo título principal e CTA primário
- **Section**: Bloco vertical de conteúdo na página que ocupa a viewport completa
- **CTA_Button**: Call-to-action button que direciona o usuário para ação de conversão
- **Fade_Animation**: Animação de transição de opacidade (0 a 1) aplicada a elementos
- **Viewport**: Área visível da tela do usuário
- **Scroll_Behavior**: Comportamento de rolagem suave entre seções
- **Responsive_Layout**: Layout que se adapta a diferentes tamanhos de tela (desktop e mobile)
- **Theme_System**: Sistema de cores e tipografia definido para a página
- **Widget**: Componente reutilizável do Flutter
- **Riverpod_Provider**: Mecanismo de gerenciamento de estado usando Riverpod

## Requirements

### Requirement 1: Visual Theme System

**User Story:** Como visitante, eu quero uma experiência visual minimalista e contemplativa, para que eu possa focar no conteúdo espiritual sem distrações.

#### Acceptance Criteria

1. THE Theme_System SHALL use black (#000000) as the background color
2. THE Theme_System SHALL use white (#FFFFFF) as the primary text color
3. THE Theme_System SHALL use gold (#D4AF37) as the accent color for highlights and CTAs
4. THE Theme_System SHALL define large typography with generous spacing between elements
5. THE Theme_System SHALL avoid visual pollution by limiting decorative elements

### Requirement 2: Page Structure and Layout

**User Story:** Como visitante, eu quero navegar por uma sequência de seções verticais, para que eu possa absorver o conteúdo em um ritmo contemplativo.

#### Acceptance Criteria

1. THE Sales_Page SHALL contain exactly 8 vertical sections in sequential order
2. WHEN the Sales_Page loads, THE Sales_Page SHALL display the Hero_Section first
3. THE Sales_Page SHALL arrange sections in this order: Hero, Silêncio, Dor, Quebra de Crença, Revelação, Experiência, Momento Guiado, CTA Final
4. THE Responsive_Layout SHALL adapt to desktop viewport widths (≥1024px)
5. THE Responsive_Layout SHALL adapt to mobile viewport widths (<1024px)
6. WHEN viewport width is ≥1024px, THE Sales_Page SHALL display text with maximum width of 800px centered horizontally
7. WHEN viewport width is <1024px, THE Sales_Page SHALL display text with 24px horizontal padding

### Requirement 3: Hero Section Content

**User Story:** Como visitante, eu quero ver imediatamente a proposta central do livro, para que eu possa decidir se quero continuar explorando.

#### Acceptance Criteria

1. THE Hero_Section SHALL display the main text "Você não precisa orar… você pode falar com o Pai" centered vertically and horizontally
2. THE Hero_Section SHALL display the subtext "Talvez ninguém nunca tenha te ensinado isso." below the main text
3. THE Hero_Section SHALL display a CTA_Button with the text "Começar agora"
4. THE CTA_Button SHALL use gold (#D4AF37) as background color
5. THE CTA_Button SHALL use black (#000000) as text color
6. WHEN the user hovers over the CTA_Button on desktop, THE CTA_Button SHALL increase opacity to 0.9

### Requirement 4: Silêncio Section Content

**User Story:** Como visitante, eu quero experimentar um momento de pausa visual, para que eu possa refletir sobre o que acabei de ler.

#### Acceptance Criteria

1. THE Silêncio_Section SHALL display the text "isso não é mais um livro espiritual" in small font size (16px)
2. THE Silêncio_Section SHALL center the text vertically and horizontally
3. THE Silêncio_Section SHALL use white (#FFFFFF) text color with 70% opacity

### Requirement 5: Dor Section Content

**User Story:** Como visitante, eu quero me identificar com experiências de dor espiritual, para que eu possa reconhecer minha própria jornada.

#### Acceptance Criteria

1. THE Dor_Section SHALL display the question "Você já orou… e sentiu que ninguém estava ouvindo?"
2. THE Dor_Section SHALL display the question "Já tentou fazer tudo certo… e mesmo assim sentiu vazio?" below the first question
3. THE Dor_Section SHALL separate the two questions with 48px vertical spacing
4. THE Dor_Section SHALL center both questions horizontally

### Requirement 6: Quebra de Crença Section Content

**User Story:** Como visitante, eu quero questionar minhas crenças anteriores, para que eu possa estar aberto a uma nova perspectiva.

#### Acceptance Criteria

1. THE Quebra_Section SHALL display the text "E se o problema nunca foi você… mas a forma como te ensinaram?"
2. THE Quebra_Section SHALL center the text vertically and horizontally
3. THE Quebra_Section SHALL use gold (#D4AF37) text color for emphasis

### Requirement 7: Revelação Section Content

**User Story:** Como visitante, eu quero entender a verdade central sobre Deus como Pai, para que eu possa ter esperança de um relacionamento diferente.

#### Acceptance Criteria

1. THE Revelação_Section SHALL display the text "Deus nunca quis distância. Ele sempre quis ser Pai."
2. THE Revelação_Section SHALL center the text vertically and horizontally
3. THE Revelação_Section SHALL use larger font size (32px on desktop, 24px on mobile)

### Requirement 8: Experiência Section Content

**User Story:** Como visitante, eu quero entender o que o livro oferece, para que eu possa avaliar se é relevante para mim.

#### Acceptance Criteria

1. THE Experiência_Section SHALL display the text "Este livro não vai te ensinar a orar melhor. Vai te mostrar algo mais simples: voltar a falar com o Pai."
2. THE Experiência_Section SHALL center the text vertically and horizontally
3. THE Experiência_Section SHALL use white (#FFFFFF) text color

### Requirement 9: Momento Guiado Section Content

**User Story:** Como visitante, eu quero experimentar um momento de conexão espiritual, para que eu possa sentir a proposta do livro antes de comprar.

#### Acceptance Criteria

1. THE Momento_Guiado_Section SHALL display the text "Fecha os olhos por um instante… e fala com Ele agora."
2. THE Momento_Guiado_Section SHALL highlight the text with a subtle gold border (1px solid #D4AF37)
3. THE Momento_Guiado_Section SHALL add 96px vertical spacing after the text to create contemplative pause
4. THE Momento_Guiado_Section SHALL center the text horizontally

### Requirement 10: CTA Final Section Content

**User Story:** Como visitante, eu quero uma chamada clara para ação após a experiência contemplativa, para que eu possa dar o próximo passo.

#### Acceptance Criteria

1. THE CTA_Final_Section SHALL display the text "Se você quer continuar isso…" above the button
2. THE CTA_Final_Section SHALL display a CTA_Button with the text "Entrar no Secreto"
3. THE CTA_Button SHALL use gold (#D4AF37) as background color
4. THE CTA_Button SHALL use black (#000000) as text color
5. WHEN the user clicks the CTA_Button, THE Sales_Page SHALL navigate to the authentication flow

### Requirement 11: Scroll Behavior

**User Story:** Como visitante, eu quero uma experiência de rolagem suave, para que a transição entre seções seja contemplativa e não abrupta.

#### Acceptance Criteria

1. WHEN the user scrolls the page, THE Scroll_Behavior SHALL use smooth scrolling animation
2. THE Scroll_Behavior SHALL complete scroll transitions within 600ms
3. WHEN the user clicks a CTA_Button in Hero_Section, THE Sales_Page SHALL scroll smoothly to CTA_Final_Section

### Requirement 12: Fade-In Animations

**User Story:** Como visitante, eu quero que as seções apareçam gradualmente, para que eu possa absorver o conteúdo em um ritmo contemplativo.

#### Acceptance Criteria

1. WHEN a Section enters the viewport, THE Section SHALL fade in from opacity 0 to opacity 1
2. THE Fade_Animation SHALL complete within 700ms
3. THE Fade_Animation SHALL use ease-out timing function
4. WHEN the Sales_Page loads, THE Hero_Section SHALL fade in immediately without delay
5. WHEN a Section is 20% visible in viewport, THE Fade_Animation SHALL trigger
6. THE Sales_Page SHALL apply sequential delay of 200ms between consecutive sections during initial load

### Requirement 13: Button Interactions

**User Story:** Como visitante, eu quero feedback visual ao interagir com botões, para que eu saiba que minha ação foi reconhecida.

#### Acceptance Criteria

1. WHEN the user hovers over a CTA_Button on desktop, THE CTA_Button SHALL transition opacity to 0.9 within 200ms
2. WHEN the user stops hovering over a CTA_Button, THE CTA_Button SHALL transition opacity back to 1.0 within 200ms
3. WHEN the user taps a CTA_Button on mobile, THE CTA_Button SHALL show a scale animation to 0.98 within 100ms
4. THE CTA_Button SHALL have rounded corners with 8px border radius

### Requirement 14: Typography System

**User Story:** Como visitante, eu quero uma tipografia clara e legível, para que eu possa ler confortavelmente o conteúdo espiritual.

#### Acceptance Criteria

1. THE Theme_System SHALL use font size 48px for Hero_Section main text on desktop
2. THE Theme_System SHALL use font size 32px for Hero_Section main text on mobile
3. THE Theme_System SHALL use font size 20px for Hero_Section subtext on desktop
4. THE Theme_System SHALL use font size 16px for Hero_Section subtext on mobile
5. THE Theme_System SHALL use font size 24px for standard section text on desktop
6. THE Theme_System SHALL use font size 18px for standard section text on mobile
7. THE Theme_System SHALL use line height of 1.6 for all body text
8. THE Theme_System SHALL use font weight 300 (light) for body text
9. THE Theme_System SHALL use font weight 400 (regular) for emphasis text

### Requirement 15: Component Architecture

**User Story:** Como desenvolvedor, eu quero componentes reutilizáveis e bem organizados, para que eu possa manter e estender a landing page facilmente.

#### Acceptance Criteria

1. THE Sales_Page SHALL be implemented in lib/features/sales/ directory
2. THE Sales_Page SHALL create a SalesHeroSection widget in sales_hero_section.dart
3. THE Sales_Page SHALL create a SalesTextSection widget in sales_text_section.dart
4. THE Sales_Page SHALL create a SalesCtaButton widget in sales_cta_button.dart
5. THE Sales_Page SHALL create a SalesMomentoGuiadoSection widget in sales_momento_guiado_section.dart
6. THE Sales_Page SHALL follow Clean Architecture with presentation/domain/data layers
7. THE Sales_Page SHALL use Riverpod_Provider for state management

### Requirement 16: Navigation Integration

**User Story:** Como visitante, eu quero ser direcionado para o próximo passo após clicar no CTA, para que eu possa começar minha jornada.

#### Acceptance Criteria

1. WHEN the user clicks "Começar agora" in Hero_Section, THE Sales_Page SHALL scroll to CTA_Final_Section
2. WHEN the user clicks "Entrar no Secreto" in CTA_Final_Section, THE Sales_Page SHALL navigate to authentication screen
3. THE Sales_Page SHALL use GoRouter for navigation
4. THE Sales_Page SHALL define route path as "/sales" in app router configuration

### Requirement 17: Accessibility

**User Story:** Como visitante com necessidades de acessibilidade, eu quero poder navegar e entender a página, para que eu possa ter acesso ao conteúdo espiritual.

#### Acceptance Criteria

1. THE CTA_Button SHALL have semantic label describing its action
2. THE Sales_Page SHALL support keyboard navigation for all interactive elements
3. WHEN the user presses Tab key, THE Sales_Page SHALL move focus to next interactive element
4. THE Sales_Page SHALL maintain minimum contrast ratio of 4.5:1 between text and background
5. THE Sales_Page SHALL provide alternative text for any decorative elements

### Requirement 18: Performance

**User Story:** Como visitante, eu quero que a página carregue rapidamente, para que eu não perca o interesse antes de ver o conteúdo.

#### Acceptance Criteria

1. THE Sales_Page SHALL render initial viewport content within 2 seconds on 3G connection
2. THE Sales_Page SHALL lazy-load sections below the fold
3. THE Fade_Animation SHALL use GPU-accelerated CSS properties (opacity, transform)
4. THE Sales_Page SHALL avoid layout shifts during content loading

### Requirement 19: Mobile Touch Interactions

**User Story:** Como visitante mobile, eu quero interações touch responsivas, para que eu possa navegar confortavelmente no meu dispositivo.

#### Acceptance Criteria

1. THE CTA_Button SHALL have minimum touch target size of 48x48 pixels
2. WHEN the user swipes vertically, THE Sales_Page SHALL scroll smoothly
3. THE Sales_Page SHALL disable horizontal scroll
4. THE Sales_Page SHALL support pinch-to-zoom for accessibility

### Requirement 20: Content Spacing and Rhythm

**User Story:** Como visitante, eu quero espaçamento generoso entre elementos, para que eu possa respirar e refletir sobre cada mensagem.

#### Acceptance Criteria

1. THE Sales_Page SHALL use minimum 96px vertical spacing between sections on desktop
2. THE Sales_Page SHALL use minimum 64px vertical spacing between sections on mobile
3. THE Hero_Section SHALL use 24px spacing between main text and subtext
4. THE Hero_Section SHALL use 48px spacing between subtext and CTA_Button
5. THE Dor_Section SHALL use 48px spacing between questions
6. THE Momento_Guiado_Section SHALL use 96px spacing after the guided moment text
