# Implementation Plan: Sales Landing Page

## Overview

This implementation plan breaks down the Sales Landing Page feature into discrete coding tasks. The feature will be built using Flutter Web with Riverpod for state management, following Clean Architecture principles. The page creates a contemplative, minimalist experience with smooth animations and responsive design.

**Implementation Language:** Dart/Flutter

**Key Technical Decisions:**
- Clean Architecture with presentation/domain/data layers
- Riverpod for state management
- GoRouter for navigation
- GPU-accelerated animations using AnimatedOpacity
- Responsive design with breakpoints at 1024px

## Tasks

- [x] 1. Set up feature structure and constants
  - Create directory structure: `lib/features/sales/presentation/`, `lib/features/sales/domain/`, `lib/features/sales/data/`
  - Create `lib/features/sales/data/constants/sales_content.dart` with all static text content
  - Create `lib/features/sales/data/constants/sales_theme.dart` with color constants, typography sizes, and spacing values
  - Create `lib/features/sales/domain/models/section_config.dart` with SectionConfig model
  - Create `lib/features/sales/domain/models/responsive_breakpoints.dart` with ResponsiveBreakpoints utility class
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 14.1-14.9, 20.1-20.6_

- [ ] 2. Implement reusable UI components
  - [x] 2.1 Create SalesCtaButton widget
    - Create `lib/features/sales/presentation/widgets/sales_cta_button.dart`
    - Implement StatefulWidget with hover state tracking
    - Apply gold background (#D4AF37), black text (#000000), 8px border radius
    - Implement hover effect (opacity 0.9, 200ms transition) for desktop
    - Implement tap effect (scale 0.98, 100ms transition) for mobile
    - Ensure minimum 48x48px touch target size
    - Add semantic label for accessibility
    - _Requirements: 3.3, 3.4, 3.5, 3.6, 10.2, 10.3, 10.4, 13.1-13.4, 17.1, 19.1_

  - [ ]* 2.2 Write widget tests for SalesCtaButton
    - Test button renders with correct text and colors
    - Test hover state changes opacity on desktop
    - Test tap state scales button on mobile
    - Test minimum touch target size
    - Test semantic label exists
    - _Requirements: 3.3, 3.4, 3.5, 13.1-13.4, 17.1_

  - [x] 2.3 Create SalesTextSection widget
    - Create `lib/features/sales/presentation/widgets/sales_text_section.dart`
    - Implement ConsumerWidget with configurable text, textStyle, textColor, verticalSpacing, isVisible
    - Apply AnimatedOpacity with 700ms duration and ease-out curve
    - Center text horizontally with responsive padding (800px max width desktop, 24px padding mobile)
    - Support custom vertical spacing between sections
    - _Requirements: 2.6, 2.7, 12.1-12.3, 14.5-14.9, 20.1, 20.2_

  - [ ]* 2.4 Write widget tests for SalesTextSection
    - Test section renders text with correct styling
    - Test fade-in animation triggers when isVisible changes
    - Test responsive padding on desktop and mobile
    - Test custom vertical spacing
    - _Requirements: 2.6, 2.7, 12.1-12.3_

- [ ] 3. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Implement specialized section components
  - [x] 4.1 Create SalesHeroSection widget
    - Create `lib/features/sales/presentation/widgets/sales_hero_section.dart`
    - Implement ConsumerWidget with onCtaPressed callback
    - Display main text "Você não precisa orar… você pode falar com o Pai" with responsive font size (48px desktop, 32px mobile)
    - Display subtext "Talvez ninguém nunca tenha te ensinado isso." with responsive font size (20px desktop, 16px mobile)
    - Display SalesCtaButton with text "Começar agora"
    - Apply 24px spacing between main text and subtext, 48px spacing between subtext and button
    - Apply fade-in animation on mount
    - Center content vertically and horizontally
    - _Requirements: 3.1, 3.2, 3.3, 14.1-14.4, 20.3, 20.4_

  - [ ]* 4.2 Write widget tests for SalesHeroSection
    - Test hero section renders all text elements
    - Test CTA button triggers callback when tapped
    - Test responsive typography at different viewport widths
    - Test spacing between elements
    - _Requirements: 3.1, 3.2, 3.3, 14.1-14.4, 20.3, 20.4_

  - [x] 4.3 Create SalesMomentoGuiadoSection widget
    - Create `lib/features/sales/presentation/widgets/sales_momento_guiado_section.dart`
    - Implement ConsumerWidget with isVisible parameter
    - Display text "Fecha os olhos por um instante… e fala com Ele agora."
    - Apply subtle gold border (1px solid #D4AF37)
    - Add 96px vertical spacing after text
    - Apply fade-in animation when visible
    - Center content horizontally
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 20.6_

  - [ ]* 4.4 Write widget tests for SalesMomentoGuiadoSection
    - Test section renders text with gold border
    - Test fade-in animation triggers when isVisible changes
    - Test vertical spacing after text
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 20.6_

- [ ] 5. Implement Riverpod providers for state management
  - [x] 5.1 Create scroll management providers
    - Create `lib/features/sales/presentation/providers/scroll_providers.dart`
    - Implement salesScrollControllerProvider with proper disposal
    - Implement scrollPositionProvider as StateProvider<double>
    - Implement SectionVisibilityNotifier as StateNotifierProvider<Map<int, bool>>
    - Add updateVisibility method to SectionVisibilityNotifier
    - _Requirements: 11.1, 11.2, 12.5, 15.7_

  - [x] 5.2 Create navigation provider
    - Create `lib/features/sales/presentation/providers/sales_navigation_provider.dart`
    - Implement SalesNavigation class with navigateToAuth and scrollToSection methods
    - Implement salesNavigationProvider as Provider<SalesNavigation>
    - Add error handling for navigation failures with user-friendly messages
    - _Requirements: 10.5, 11.3, 16.1, 16.2, 16.3_

- [ ] 6. Implement main SalesScreen
  - [x] 6.1 Create SalesScreen widget
    - Create `lib/features/sales/presentation/screens/sales_screen.dart`
    - Implement ConsumerStatefulWidget with ScrollController lifecycle management
    - Set up SingleChildScrollView with scroll listener for section visibility detection
    - Render all 8 sections in sequential order: Hero, Silêncio, Dor, Quebra, Revelação, Experiência, Momento Guiado, CTA Final
    - Apply black background (#000000)
    - Implement scroll-to-section functionality for CTA buttons
    - Calculate section visibility based on 20% threshold
    - Apply sequential 200ms delay between section animations on initial load
    - _Requirements: 2.1, 2.2, 2.3, 11.1, 11.2, 12.4, 12.5, 12.6, 15.1_

  - [x] 6.2 Implement section content rendering
    - Render Silêncio section with text "isso não é mais um livro espiritual" (16px, 70% opacity)
    - Render Dor section with two questions separated by 48px spacing
    - Render Quebra section with gold text color (#D4AF37)
    - Render Revelação section with larger font size (32px desktop, 24px mobile)
    - Render Experiência section with standard styling
    - Render Momento Guiado section using SalesMomentoGuiadoSection widget
    - Render CTA Final section with text "Se você quer continuar isso…" and "Entrar no Secreto" button
    - _Requirements: 4.1-4.3, 5.1-5.4, 6.1-6.3, 7.1-7.3, 8.1-8.3, 9.1-9.4, 10.1-10.5, 20.5_

  - [ ]* 6.3 Write widget tests for SalesScreen
    - Test screen renders all 8 sections in correct order
    - Test scroll listener updates section visibility
    - Test scroll-to-section functionality
    - Test sequential animation delays
    - _Requirements: 2.1, 2.2, 2.3, 11.1, 12.4, 12.5, 12.6_

- [ ] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Integrate with app router and navigation
  - [x] 8.1 Add sales route to GoRouter configuration
    - Locate existing router configuration file (likely `lib/core/router/app_router.dart` or similar)
    - Add route constant `sales = '/sales'` and `salesName = 'sales'` to AppRoutes class
    - Add GoRoute for sales page with path '/sales' and builder returning SalesScreen
    - Ensure route is accessible to unauthenticated users
    - _Requirements: 16.3, 16.4_

  - [x] 8.2 Wire up navigation actions
    - Connect "Começar agora" button in Hero section to scroll to CTA Final section
    - Connect "Entrar no Secreto" button in CTA Final section to navigate to login screen
    - Implement smooth scroll animation with 600ms duration and easeInOut curve
    - Add error handling for navigation failures
    - _Requirements: 10.5, 11.2, 11.3, 16.1, 16.2_

  - [ ]* 8.3 Write integration tests for navigation flow
    - Test clicking "Começar agora" scrolls to CTA Final section
    - Test clicking "Entrar no Secreto" navigates to login screen
    - Test smooth scroll animation completes in 600ms
    - Test navigation error handling
    - _Requirements: 10.5, 11.2, 11.3, 16.1, 16.2_

- [ ] 9. Implement responsive design and accessibility
  - [x] 9.1 Add responsive layout logic
    - Implement viewport width detection using MediaQuery
    - Apply desktop layout (800px max width) when viewport ≥1024px
    - Apply mobile layout (24px padding) when viewport <1024px
    - Ensure responsive typography switches at breakpoint
    - Test layout on various screen sizes
    - _Requirements: 2.4, 2.5, 2.6, 2.7, 14.1-14.6_

  - [x] 9.2 Implement accessibility features
    - Add semantic labels to all CTA buttons
    - Ensure keyboard navigation works for all interactive elements (Tab key, Enter key)
    - Verify text contrast ratios meet WCAG AA standards (4.5:1)
    - Add focus indicators for keyboard navigation
    - Support screen reader navigation with proper semantic structure
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

  - [ ]* 9.3 Write accessibility tests
    - Test semantic labels exist on all buttons
    - Test keyboard navigation moves focus correctly
    - Test Enter key activates focused buttons
    - Test text contrast ratios
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

- [ ] 10. Optimize performance and animations
  - [x] 10.1 Implement performance optimizations
    - Use const constructors for all static widgets
    - Implement lazy loading for below-fold sections if needed
    - Ensure animations use GPU-accelerated properties (opacity, transform)
    - Add performance monitoring to detect animation frame drops
    - Disable animations if device performance is poor or reduce motion is enabled
    - _Requirements: 18.1, 18.2, 18.3, 18.4_

  - [x] 10.2 Implement mobile touch interactions
    - Ensure all CTA buttons have minimum 48x48px touch target
    - Verify smooth vertical scrolling on mobile devices
    - Disable horizontal scroll
    - Support pinch-to-zoom for accessibility
    - _Requirements: 19.1, 19.2, 19.3, 19.4_

  - [ ]* 10.3 Write performance tests
    - Test initial viewport renders within 2 seconds
    - Test animations maintain 60fps
    - Test lazy loading works correctly
    - Test touch target sizes meet minimum requirements
    - _Requirements: 18.1, 18.2, 19.1_

- [ ] 11. Final integration and polish
  - [x] 11.1 Verify all content and styling
    - Verify all section texts match requirements exactly
    - Verify all colors match theme (black background, white text, gold accents)
    - Verify all spacing matches requirements (96px desktop, 64px mobile between sections)
    - Verify all typography sizes match requirements
    - Verify all animations work smoothly
    - _Requirements: 1.1-1.5, 14.1-14.9, 20.1-20.6_

  - [x] 11.2 Test complete user flow
    - Test complete flow from landing on /sales to clicking final CTA
    - Test responsive behavior at various viewport sizes
    - Test on different browsers (Chrome, Firefox, Safari)
    - Test on mobile devices (iOS, Android)
    - Verify smooth scroll behavior throughout
    - _Requirements: 2.1-2.7, 11.1-11.3, 16.1-16.4_

  - [ ]* 11.3 Write visual regression tests
    - Create golden file tests for SalesScreen at desktop width
    - Create golden file tests for SalesScreen at mobile width
    - Create golden file tests for each section component
    - _Requirements: 1.1-1.5, 2.6, 2.7_

- [ ] 12. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- The design document does not include Correctness Properties, so property-based tests are not applicable
- Testing focuses on widget tests, integration tests, and accessibility tests
- All code should follow existing project conventions in `jornada_deus_pai`
- Use Riverpod for state management throughout
- Follow Clean Architecture with clear separation of presentation/domain/data layers
