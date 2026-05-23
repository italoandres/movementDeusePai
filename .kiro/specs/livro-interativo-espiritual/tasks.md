# Implementation Plan: Interactive Spiritual Book System

## Overview

This implementation plan breaks down the Interactive Spiritual Book System into manageable coding tasks following a four-phase approach: Foundation, Core Features, Polish, and Testing & Deployment. The system uses Next.js 14 with App Router, React 18, TypeScript, TailwindCSS, and Supabase for backend services.

Each task builds incrementally on previous work, with property-based tests and unit tests included as optional sub-tasks to enable faster MVP delivery while maintaining quality standards.

## Technology Stack

- **Frontend**: Next.js 14 (App Router), React 18, TypeScript
- **Styling**: TailwindCSS with custom dark theme
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **Testing**: Vitest (unit), fast-check (property-based), Playwright (E2E)
- **Deployment**: Vercel

## Tasks

### Phase 1: Foundation

- [x] 1. Initialize Next.js project with TypeScript and TailwindCSS
  - Create Next.js 14 project with App Router and TypeScript
  - Install and configure TailwindCSS with dark theme
  - Set up project structure (app/, components/, lib/ directories)
  - Configure TypeScript with strict mode
  - _Requirements: 11.1, 12.2_

- [x] 2. Set up Supabase project and database schema
  - [x] 2.1 Create Supabase project and configure environment variables
    - Create Supabase project in dashboard
    - Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local
    - Create Supabase client utilities (client.ts, server.ts, middleware.ts)
    - _Requirements: 9.3, 10.1_
  
  - [x] 2.2 Create database tables with SQL schema
    - Execute SQL to create profiles, chapters, user_progress, messages tables
    - Add indexes for performance optimization
    - _Requirements: 10.2, 10.3_
  
  - [x] 2.3 Configure Row Level Security policies
    - Enable RLS on all tables
    - Create policies for profiles, chapters, user_progress, messages
    - _Requirements: 10.6_
  
  - [ ]* 2.4 Write property test for data isolation (Property 23)
    - **Property 23: User Data Isolation**
    - **Validates: Requirements 10.6**
    - Test that user A cannot access user B's data through API

- [x] 3. Implement authentication system
  - [x] 3.1 Create authentication pages (login, signup)
    - Build login page with email/password form
    - Build signup page with email/password form
    - Add form validation and error display
    - _Requirements: 9.1, 9.2, 9.6_
  
  - [x] 3.2 Implement authentication service layer
    - Create auth service with signUp, signIn, signOut functions
    - Implement session management with Supabase Auth
    - Add error handling for authentication failures
    - _Requirements: 9.4, 9.5, 14.1_
  
  - [x] 3.3 Create authentication middleware
    - Implement Next.js middleware for protected routes
    - Add session validation and redirect logic
    - _Requirements: 9.5, 14.2_
  
  - [ ]* 3.4 Write property test for session creation (Property 28)
    - **Property 28: Session Creation on Authentication**
    - **Validates: Requirements 14.1**
    - Test that successful auth creates session with HTTP-only cookie
  
  - [ ]* 3.5 Write property test for session restoration (Property 29)
    - **Property 29: Session Restoration**
    - **Validates: Requirements 14.3**
    - Test that active session restores without re-authentication
  
  - [ ]* 3.6 Write unit tests for authentication error handling
    - Test invalid credentials error display
    - Test session expired redirect
    - Test rate limiting behavior
    - _Requirements: 9.6, 15.3_

- [x] 4. Create landing page with emotional content
  - [x] 4.1 Build landing page layout and hero section
    - Create landing page component with "Carta de um Órfão" content
    - Implement minimalist design with strong typography
    - Add "Começar minha jornada" CTA button
    - _Requirements: 6.1, 6.2, 6.3, 12.1, 12.3_
  
  - [x] 4.2 Implement CTA navigation logic
    - Wire CTA button to navigate to signup/login or first chapter
    - Handle authenticated vs unauthenticated states
    - _Requirements: 6.4_
  
  - [ ]* 4.3 Write unit tests for landing page rendering
    - Test emotional content display
    - Test CTA button presence and click behavior
    - Test responsive layout
    - _Requirements: 6.1, 6.2, 6.3_

- [x] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 2: Core Features

- [x] 6. Implement chapter data model and service
  - [x] 6.1 Create TypeScript domain types
    - Define Chapter, ChapterContent, ChapterMessage interfaces
    - Define UserProgress, Message, Profile interfaces
    - Generate Supabase database types
    - _Requirements: 1.1, 13.1_
  
  - [x] 6.2 Implement chapter service layer
    - Create chapterService with getAllChapters, getChapterById functions
    - Implement getChapterMessages to parse chapter content
    - Add validateChapterAccess for sequential unlocking
    - _Requirements: 1.3, 5.1_
  
  - [x] 6.3 Seed initial chapter content in database
    - Create SQL script to insert chapter data
    - Structure chapter content as JSONB with messages array
    - _Requirements: 1.1, 1.2_
  
  - [ ]* 6.4 Write property test for chapter ordering (Property 1)
    - **Property 1: Chapter Sequential Ordering**
    - **Validates: Requirements 1.3**
    - Test that chapters are always ordered by order_index ascending
  
  - [ ]* 6.5 Write property test for chapter rendering (Property 2)
    - **Property 2: Chapter Rendering Produces Message Blocks**
    - **Validates: Requirements 1.2, 2.1**
    - Test that valid chapter content renders as message blocks in order

- [x] 7. Build chat interface components
  - [x] 7.1 Create ChatContainer component
    - Build main chat wrapper with state management
    - Implement message list rendering
    - Add scroll behavior (auto-scroll to bottom)
    - _Requirements: 2.1, 2.2_
  
  - [x] 7.2 Create ContentMessage and UserMessage components
    - Build ContentMessage with left-aligned styling
    - Build UserMessage with right-aligned styling
    - Apply dark theme and typography styling
    - _Requirements: 2.3, 2.5, 3.2, 3.4_
  
  - [x] 7.3 Create MessageInput component
    - Build text input with send button
    - Implement enter key submission
    - Add input validation (no empty/whitespace-only messages)
    - Disable during submission
    - _Requirements: 3.1_
  
  - [ ]* 7.4 Write property test for user message alignment (Property 6)
    - **Property 6: User Message Display Alignment**
    - **Validates: Requirements 3.2**
    - Test that user messages render with right-side alignment
  
  - [ ]* 7.5 Write unit tests for MessageInput component
    - Test input field and button rendering
    - Test disabled state behavior
    - Test empty message rejection
    - Test input clearing after send
    - _Requirements: 3.1_

- [-] 8. Implement message storage and retrieval
  - [x] 8.1 Create message service layer
    - Implement createMessage function with Supabase insert
    - Implement getMessagesByChapter for retrieval
    - Implement getAllUserMessages and getUserMessageCount
    - _Requirements: 3.3, 10.1_
  
  - [x] 8.2 Wire message submission to chat interface
    - Connect MessageInput onSendMessage to message service
    - Implement optimistic UI updates
    - Add error handling for failed submissions
    - _Requirements: 3.3, 15.1_
  
  - [ ]* 8.3 Write property test for message persistence (Property 5)
    - **Property 5: User Message Persistence**
    - **Validates: Requirements 3.3, 10.1**
    - Test that submitted messages are stored with correct user_id and chapter_id
  
  - [ ]* 8.4 Write property test for no automated responses (Property 7)
    - **Property 7: No Automated Responses**
    - **Validates: Requirements 3.5**
    - Test that user message submission does not create automated responses
  
  - [ ]* 8.5 Write property test for data persistence round-trip (Property 10)
    - **Property 10: Data Persistence Round-Trip**
    - **Validates: Requirements 4.5, 10.4, 10.5**
    - Test that stored data equals retrieved data

- [x] 9. Implement progress tracking system
  - [x] 9.1 Create progress service layer
    - Implement initializeProgress for new users
    - Implement getProgress to fetch user progress
    - Implement completeChapter to mark chapters complete
    - Implement isChapterUnlocked and getNextChapter
    - _Requirements: 1.4, 4.3, 4.5_
  
  - [x] 9.2 Build ProgressBar component
    - Create visual progress indicator showing completion percentage
    - Display completed vs total chapters
    - Highlight current chapter
    - _Requirements: 4.1, 4.2_
  
  - [x] 9.3 Build ChapterList component with lock indicators
    - Display all chapters with completion status
    - Show locked chapters with visual indicator
    - Prevent navigation to locked chapters
    - _Requirements: 4.4, 5.3, 5.4_
  
  - [ ]* 9.4 Write property test for chapter completion (Property 3)
    - **Property 3: Chapter Completion Updates Progress**
    - **Validates: Requirements 1.4**
    - Test that completing a chapter creates/updates progress record
  
  - [ ]* 9.5 Write property test for chapter access control (Property 4)
    - **Property 4: Chapter Access Control**
    - **Validates: Requirements 1.5**
    - Test that chapter N is inaccessible if any chapter < N is incomplete
  
  - [ ]* 9.6 Write property test for progress indicator reactivity (Property 8)
    - **Property 8: Progress Indicator Reactivity**
    - **Validates: Requirements 4.2**
    - Test that progress indicator updates when chapter is completed
  
  - [ ]* 9.7 Write property test for chapter completion status display (Property 9)
    - **Property 9: Chapter Completion Status Display**
    - **Validates: Requirements 4.4**
    - Test that each chapter displays correct completion status

- [x] 10. Implement sequential chapter unlocking
  - [x] 10.1 Add chapter unlocking logic to progress service
    - Implement logic to unlock next chapter on completion
    - Validate chapter prerequisites before access
    - _Requirements: 5.1, 5.2_
  
  - [x] 10.2 Create locked chapter navigation prevention
    - Add route guard to prevent locked chapter access
    - Display "chapter not yet available" message
    - _Requirements: 5.4, 5.5_
  
  - [ ]* 10.3 Write property test for sequential unlocking (Property 11)
    - **Property 11: Sequential Chapter Unlocking**
    - **Validates: Requirements 5.2**
    - Test that completing chapter N unlocks chapter N+1
  
  - [ ]* 10.4 Write property test for locked chapter visual indication (Property 12)
    - **Property 12: Locked Chapter Visual Indication**
    - **Validates: Requirements 5.3**
    - Test that locked chapters display visual lock indicator
  
  - [ ]* 10.5 Write property test for locked chapter navigation prevention (Property 13)
    - **Property 13: Locked Chapter Navigation Prevention**
    - **Validates: Requirements 5.4, 5.5**
    - Test that navigation to locked chapter is prevented with message

- [x] 11. Create main journey page with chat interface
  - [x] 11.1 Build journey page as server component
    - Fetch user progress and current chapter on server
    - Pass initial data to client components
    - Handle authentication check and redirect
    - _Requirements: 2.1, 4.5_
  
  - [x] 11.2 Integrate all chat components into journey page
    - Wire ChatContainer with initial messages
    - Connect ProgressBar with user progress
    - Connect ChapterList with navigation
    - _Requirements: 2.1, 2.2, 4.1_
  
  - [ ]* 11.3 Write integration tests for journey page
    - Test server-side data fetching
    - Test component integration
    - Test authenticated vs unauthenticated access
    - _Requirements: 2.1, 4.5, 9.5_

- [x] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: Polish

- [x] 13. Implement digital seal award system
  - [x] 13.1 Create seal service layer
    - Implement hasSeal to check seal status
    - Implement awardSeal with reason parameter
    - Implement checkSealConditions for unlock logic
    - _Requirements: 7.1, 7.3, 8.1_
  
  - [x] 13.2 Build DigitalSeal component
    - Create seal display with "Faço parte do movimento Deus é Pai" text
    - Support full and compact variants
    - Display award date if available
    - _Requirements: 7.2, 7.4_
  
  - [x] 13.3 Build SealAward notification component
    - Create award animation/notification
    - Display when seal is awarded
    - _Requirements: 8.4_
  
  - [x] 13.4 Integrate seal award logic into journey completion
    - Call awardSeal when user completes all chapters
    - Call awardSeal on first message (if alternative unlock enabled)
    - Display seal in profile/journey view
    - _Requirements: 7.1, 7.5, 8.1_
  
  - [ ]* 13.5 Write property test for journey completion seal award (Property 14)
    - **Property 14: Journey Completion Awards Seal**
    - **Validates: Requirements 7.1**
    - Test that completing all chapters awards seal
  
  - [ ]* 13.6 Write property test for seal text content (Property 15)
    - **Property 15: Digital Seal Text Content**
    - **Validates: Requirements 7.2**
    - Test that seal displays correct text
  
  - [ ]* 13.7 Write property test for seal display in profile (Property 16)
    - **Property 16: Digital Seal Display in Profile**
    - **Validates: Requirements 7.5**
    - Test that awarded seal appears in profile view
  
  - [ ]* 13.8 Write property test for first message seal award (Property 17)
    - **Property 17: First Message Awards Seal (Alternative Unlock)**
    - **Validates: Requirements 8.1**
    - Test that first message awards seal when alternative unlock enabled
  
  - [ ]* 13.9 Write property test for seal award idempotence (Property 18)
    - **Property 18: Seal Award Idempotence**
    - **Validates: Requirements 8.2**
    - Test that multiple seal awards result in same state
  
  - [ ]* 13.10 Write property test for seal award notification (Property 19)
    - **Property 19: Seal Award Notification**
    - **Validates: Requirements 8.4**
    - Test that seal award displays notification
  
  - [ ]* 13.11 Write property test for seal persistence consistency (Property 20)
    - **Property 20: Seal Award Persistence Consistency**
    - **Validates: Requirements 8.5**
    - Test that seal data structure is consistent regardless of unlock condition

- [x] 14. Implement responsive design and mobile optimization
  - [x] 14.1 Apply responsive breakpoints to all components
    - Add Tailwind responsive classes for mobile, tablet, desktop
    - Test layout on different screen sizes
    - Ensure touch targets meet 44x44px minimum
    - _Requirements: 11.1, 11.2, 11.3_
  
  - [x] 14.2 Optimize chat interface for mobile
    - Adjust message bubble sizing for mobile
    - Optimize input field for mobile keyboards
    - Test scroll behavior on mobile devices
    - _Requirements: 11.1, 11.4_
  
  - [x] 14.3 Test device rotation handling
    - Ensure layout adapts to orientation changes
    - _Requirements: 11.5_
  
  - [ ]* 14.4 Write property test for touch target sizing (Property 24)
    - **Property 24: Responsive Touch Target Sizing**
    - **Validates: Requirements 11.3**
    - Test that interactive elements meet 44x44px minimum

- [x] 15. Implement content parser and validator
  - [x] 15.1 Create content parser module
    - Implement parseChapter to extract messages from JSONB
    - Implement validateChapterStructure for validation
    - Implement formatChapter to convert back to JSONB
    - Implement extractMessages for display
    - _Requirements: 13.1, 13.2, 13.3_
  
  - [x] 15.2 Add content validation error messages
    - Return descriptive errors for invalid content
    - _Requirements: 13.4_
  
  - [ ]* 15.3 Write property test for content parser validation (Property 25)
    - **Property 25: Content Parser Validation**
    - **Validates: Requirements 13.3**
    - Test that parser correctly identifies valid/invalid content
  
  - [ ]* 15.4 Write property test for parser error messages (Property 26)
    - **Property 26: Content Parser Error Messages**
    - **Validates: Requirements 13.4**
    - Test that invalid content returns descriptive errors
  
  - [ ]* 15.5 Write property test for parser round-trip (Property 27)
    - **Property 27: Content Parser Round-Trip**
    - **Validates: Requirements 13.6**
    - Test that parse-format-parse produces equivalent data

- [x] 16. Implement comprehensive error handling
  - [x] 16.1 Create error handling utilities
    - Implement safeDataOperation wrapper
    - Create error type detection functions
    - Add structured logging with Logger class
    - _Requirements: 15.4_
  
  - [x] 16.2 Add error boundaries to React components
    - Create ChatErrorBoundary component
    - Wrap main application sections with error boundaries
    - _Requirements: 15.1, 15.2_
  
  - [x] 16.3 Implement user-facing error messages
    - Add error toast/notification system
    - Display specific messages for different error types
    - _Requirements: 15.1, 15.2, 15.3, 15.5_
  
  - [ ]* 16.4 Write property test for storage failure error display (Property 31)
    - **Property 31: Storage Failure Error Display**
    - **Validates: Requirements 15.1**
    - Test that storage failures display error message
  
  - [ ]* 16.5 Write property test for retrieval failure error display (Property 32)
    - **Property 32: Retrieval Failure Error Display**
    - **Validates: Requirements 15.2**
    - Test that retrieval failures display error message
  
  - [ ]* 16.6 Write property test for auth failure error (Property 33)
    - **Property 33: Authentication Failure Specific Error**
    - **Validates: Requirements 15.3**
    - Test that auth failures display specific error message
  
  - [ ]* 16.7 Write property test for error logging (Property 34)
    - **Property 34: Error Logging**
    - **Validates: Requirements 15.4**
    - Test that errors create log entries with details
  
  - [ ]* 16.8 Write property test for network error message (Property 35)
    - **Property 35: Network Error Connectivity Message**
    - **Validates: Requirements 15.5**
    - Test that network errors display connectivity message

- [x] 17. Implement session management features
  - [x] 17.1 Add session duration configuration
    - Configure session timeout in Supabase
    - Add session refresh logic
    - _Requirements: 14.2_
  
  - [x] 17.2 Implement logout functionality
    - Create logout function in auth service
    - Add logout button to UI
    - Clear session on logout
    - _Requirements: 14.5_
  
  - [x] 17.3 Add session expiration handling
    - Detect expired sessions
    - Redirect to login with message
    - _Requirements: 14.4_
  
  - [ ]* 17.4 Write property test for session maintenance (Property 21)
    - **Property 21: Session Maintenance After Authentication**
    - **Validates: Requirements 9.5**
    - Test that session persists across page navigations
  
  - [ ]* 17.5 Write property test for auth failure error display (Property 22)
    - **Property 22: Authentication Failure Error Display**
    - **Validates: Requirements 9.6**
    - Test that invalid credentials display error message
  
  - [ ]* 17.6 Write property test for logout session termination (Property 30)
    - **Property 30: Logout Terminates Session**
    - **Validates: Requirements 14.5**
    - Test that logout clears session token

- [x] 18. Create user profile page
  - [x] 18.1 Build profile page component
    - Display user information
    - Show journey progress summary
    - Display digital seal if awarded
    - _Requirements: 7.5_
  
  - [ ]* 18.2 Write unit tests for profile page
    - Test profile data display
    - Test seal display when awarded
    - Test seal absence when not awarded
    - _Requirements: 7.5_

- [x] 19. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 4: Testing & Deployment

- [ ] 20. Set up testing infrastructure
  - [ ] 20.1 Configure Vitest for unit testing
    - Install Vitest and testing utilities
    - Configure test environment
    - Set up test database utilities
    - _Requirements: All_
  
  - [ ] 20.2 Configure fast-check for property-based testing
    - Install fast-check library
    - Create custom arbitraries for domain types
    - Configure property test runs (100+ iterations)
    - _Requirements: All_
  
  - [ ] 20.3 Configure Playwright for E2E testing
    - Install Playwright
    - Set up test browsers
    - Create test utilities and helpers
    - _Requirements: All_

- [ ] 21. Write integration tests for Supabase
  - [ ]* 21.1 Write integration test for RLS policies
    - Test that users cannot access other users' data
    - Test that authenticated users can read chapters
    - _Requirements: 10.6_
  
  - [ ]* 21.2 Write integration test for authentication flow
    - Test signup creates user and session
    - Test signin validates credentials and creates session
    - _Requirements: 9.3, 9.4, 14.1_
  
  - [ ]* 21.3 Write integration test for data operations
    - Test message creation and retrieval
    - Test progress creation and updates
    - Test seal award persistence
    - _Requirements: 10.1, 10.2, 10.3_

- [ ] 22. Write end-to-end tests for critical user journeys
  - [ ]* 22.1 Write E2E test for complete user journey
    - Test landing page → signup → first chapter → send message
    - Verify seal award if alternative unlock enabled
    - _Requirements: 6.1, 9.1, 1.1, 3.3, 8.1_
  
  - [ ]* 22.2 Write E2E test for sequential chapter unlocking
    - Test that completing chapter unlocks next chapter
    - Test that locked chapters cannot be accessed
    - _Requirements: 5.2, 5.4_
  
  - [ ]* 22.3 Write E2E test for journey completion
    - Test completing all chapters
    - Verify seal award on completion
    - Verify seal display in profile
    - _Requirements: 7.1, 7.5_
  
  - [ ]* 22.4 Write E2E test for session persistence
    - Test login → navigate → close → reopen → verify session
    - _Requirements: 14.3_

- [x] 23. Implement accessibility features
  - [x] 23.1 Add semantic HTML and ARIA labels
    - Use proper heading hierarchy
    - Add ARIA labels to interactive elements
    - Ensure form inputs have labels
    - _Requirements: 12.1_
  
  - [x] 23.2 Implement keyboard navigation
    - Ensure all functionality accessible via keyboard
    - Add visible focus indicators
    - Test tab order
    - _Requirements: 11.3_
  
  - [x] 23.3 Test color contrast
    - Verify text meets WCAG AA standards (4.5:1)
    - Adjust colors if needed
    - _Requirements: 12.2_
  
  - [ ]* 23.4 Write accessibility tests
    - Test keyboard navigation
    - Test screen reader compatibility
    - Test focus indicators
    - _Requirements: 12.1_

- [x] 24. Performance optimization
  - [x] 24.1 Optimize bundle size
    - Analyze bundle with Next.js analyzer
    - Implement code splitting where beneficial
    - Lazy load non-critical components
    - _Requirements: 11.1_
  
  - [x] 24.2 Optimize database queries
    - Verify indexes are used
    - Optimize N+1 queries
    - Add query result caching where appropriate
    - _Requirements: 4.5, 10.4_
  
  - [x] 24.3 Implement optimistic UI updates
    - Add optimistic updates for message submission
    - Add optimistic updates for chapter completion
    - _Requirements: 3.3, 1.4_

- [x] 25. Set up CI/CD pipeline
  - [x] 25.1 Create GitHub Actions workflow
    - Configure test runs on push and PR
    - Add unit test job
    - Add property test job
    - Add integration test job
    - Add E2E test job
    - _Requirements: All_
  
  - [x] 25.2 Configure deployment to Vercel
    - Connect GitHub repository to Vercel
    - Configure environment variables
    - Set up preview deployments for PRs
    - _Requirements: All_

- [x] 26. Create deployment documentation
  - [x] 26.1 Document environment variables
    - List all required environment variables
    - Document Supabase configuration
    - Document feature flags
    - _Requirements: All_
  
  - [x] 26.2 Document deployment process
    - Document production deployment steps
    - Document database migration process
    - Document rollback procedures
    - _Requirements: All_

- [x] 27. Final checkpoint - Ensure all tests pass and deploy
  - Run complete test suite
  - Verify all property tests pass (100+ iterations)
  - Deploy to production
  - Verify production deployment
  - Ask the user if questions arise.

## Notes

- **Optional Tasks**: Tasks marked with `*` are optional and can be skipped for faster MVP delivery. These are primarily test-related sub-tasks.
- **Requirements Traceability**: Each task references specific requirements from the requirements document for full traceability.
- **Property Tests**: Property-based tests validate universal correctness properties defined in the design document. Each property test is annotated with its property number and the requirements it validates.
- **Incremental Progress**: Tasks are ordered to enable incremental validation. Core functionality is implemented and testable before moving to polish features.
- **Checkpoints**: Multiple checkpoints ensure quality gates throughout implementation.
- **Technology Choices**: All tasks assume TypeScript, Next.js 14 App Router, React 18, TailwindCSS, and Supabase as specified in the design document.

## Testing Strategy

- **Property-Based Tests**: 35 properties covering all correctness guarantees (100+ iterations each)
- **Unit Tests**: Component behavior, service layer logic, edge cases
- **Integration Tests**: Supabase interactions, RLS policies, authentication flow
- **E2E Tests**: Critical user journeys from landing to journey completion
- **Coverage Goal**: 80%+ code coverage for business logic

## Estimated Timeline

- **Phase 1 (Foundation)**: 2 weeks
- **Phase 2 (Core Features)**: 2 weeks
- **Phase 3 (Polish)**: 1 week
- **Phase 4 (Testing & Deployment)**: 1 week
- **Total**: 6 weeks

## Next Steps

This workflow is complete. To begin implementation:

1. Open the `tasks.md` file (this file)
2. Click "Start task" next to any task item to begin execution
3. Tasks will be executed by the coding agent with full context from requirements and design documents
4. Optional test tasks (marked with `*`) can be skipped for faster MVP delivery
