# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Post-Purchase Flow Activation Failure
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists across all 3 failure points
  - **Scoped PBT Approach**: Scope the property to concrete failing cases:
    - Case A (Webhook + existing profile): Send approved payment notification for email with existing profile → assert `access_type` becomes 'book' and `has_book_access` becomes true
    - Case B (Webhook + missing profile): Send approved payment notification for email with NO profile → assert purchase saved with `access_released = true` and clear log that access will be picked up on account creation
    - Case C (URL extraction): Render ThankYouScreen with URL containing `?external_reference=test@email.com` → assert email field is populated and readonly
  - **isBugCondition**: `paymentApproved AND (columnsNotExist OR profileNotExists OR urlHasExternalRef AND !extractsEmail OR createAccessIsNoop)`
  - **expectedBehavior**: Webhook updates/logs correctly, email extracted from URL, account created with book access
  - Test webhook handler (TypeScript) with mocked Supabase: verified payment → profile update attempts → observe failure (columns missing or 0 rows affected without fallback logging)
  - Test ThankYouScreen (Dart) rendering: navigate to `/obrigado?external_reference=email@test.com` → verify email field remains empty (extraction not implemented)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found:
    - Profile `access_type` stays 'free' after approved payment (column update fails silently)
    - No log indicating profile was not found when profile doesn't exist
    - ThankYouScreen renders with empty email despite URL containing `external_reference`
    - `_handleCreateAccess` returns without creating real Supabase auth user
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Purchase Webhook and Existing Access Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - **Observe on UNFIXED code**:
    - Webhook with `type: 'merchant_order'` → returns `{ received: true }`, no DB changes
    - Webhook with payment `status: 'pending'` → saves purchase without `access_released: true`, no profile update
    - Webhook with duplicate `payment_id` → returns `{ received: true, message: 'Already processed' }`, no duplicate insert
    - Existing user with `access_type: 'book'` → access_type unchanged after any webhook for same email
    - Free user login → `access_type` remains 'free', no elevation
  - **Write property-based tests**:
    - Generate random webhook payloads with non-payment types (merchant_order, chargebacks, unknown) → assert response is `{ received: true }` and no DB writes occur
    - Generate random payment statuses != 'approved' (pending, rejected, cancelled, in_process) → assert purchase saved but `access_released = false` and profile NOT updated
    - Generate duplicate payment_id scenarios → assert idempotency (skip without error)
    - Generate profile states with access_type in ['book', 'admin'] → assert access_type never downgraded
  - **Preservation scope from design**: All interactions NOT involving (a) webhook with approved payment + profile update, (b) redirect to /obrigado, (c) account creation from ThankYouScreen
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 3. Database migration — add missing columns to profiles table

  - [x] 3.1 Create migration SQL to add book access columns to profiles
    - Add `access_type TEXT DEFAULT 'free'` if not exists
    - Add `has_book_access BOOLEAN DEFAULT false` if not exists
    - Add `book_purchased_at TIMESTAMPTZ` if not exists
    - Add `app_source TEXT DEFAULT 'journey'` if not exists
    - Add `language TEXT DEFAULT 'pt'` if not exists
    - Do NOT add `payment_id` or `payment_provider` to profiles (keep in purchases table only)
    - Use `ALTER TABLE profiles ADD COLUMN IF NOT EXISTS` for safety
    - Create file `supabase/migrations/add-book-access-columns.sql`
    - _Bug_Condition: isBugCondition where columnsNotExist('profiles', ['access_type', 'has_book_access', 'book_purchased_at'])_
    - _Expected_Behavior: All profiles have access columns available for webhook updates_
    - _Preservation: Existing profiles retain current values via DEFAULT — no data loss_
    - _Requirements: 1.1, 2.1_

  - [x] 3.2 Update profile trigger to include access columns in new profile creation
    - Modify `handle_new_user()` in `supabase/create-profile-trigger.sql`
    - Add `access_type DEFAULT 'free'`, `has_book_access DEFAULT false`, `app_source`, `language` to INSERT
    - Ensure trigger sets baseline values so webhook can later UPDATE safely
    - _Bug_Condition: Trigger only inserts basic fields → webhook UPDATE finds no access columns_
    - _Expected_Behavior: New profiles have access_type='free', has_book_access=false ready for updates_
    - _Preservation: Existing trigger behavior for nome, email, perfil_is_complete, senha_is_seted unchanged_
    - _Requirements: 1.1, 2.1, 3.4_

- [x] 4. Fix webhook handler — robust logging and missing profile fallback

  - [x] 4.1 Refactor profile update to only use guaranteed columns
    - Remove `book_purchased_at`, `payment_id`, `payment_provider` from the profile UPDATE statement
    - Only update `access_type = 'book'` and `has_book_access = true` on profiles
    - Keep all payment details in the `purchases` table (already stores payment_id, email, status)
    - _Bug_Condition: Webhook tries to SET columns that may not exist on profiles_
    - _Expected_Behavior: UPDATE only uses columns guaranteed by migration (access_type, has_book_access)_
    - _Preservation: purchases table continues storing full payment details_
    - _Requirements: 1.1, 2.1_

  - [x] 4.2 Add row-count check and fallback logging for missing profile
    - After `supabase.from('profiles').update(...)`, check if response indicates 0 rows affected
    - If 0 rows: log `[Webhook] Profile not found for ${email} — access will be picked up on account creation via purchases table`
    - If rows affected: log `[Webhook] Profile updated to book access for: ${email}`
    - Do NOT attempt to create profile from webhook (user creates account later via ThankYouScreen)
    - _Bug_Condition: UPDATE affects 0 rows when profile doesn't exist, no error/log indicates the gap_
    - _Expected_Behavior: Clear log distinguishes "profile updated" from "profile not found, deferred to signup"_
    - _Preservation: Webhook still returns 200 in both cases, no new failure modes_
    - _Requirements: 1.2, 2.2_

  - [x] 4.3 Add comprehensive structured logging at each webhook decision point
    - Log: webhook received (type, action, data.id)
    - Log: payment type check result (is_payment or ignored)
    - Log: payment fetch result (status, email, external_reference)
    - Log: approval check (approved vs other status)
    - Log: idempotency check (new vs already processed)
    - Log: purchase insert result (success/error)
    - Log: profile update result (updated/not found/error)
    - Use structured format: `[Webhook] Step: detail`
    - _Requirements: 2.1, 2.2_

- [x] 5. Update ProfileService to support `withBookAccess` parameter

  - [x] 5.1 Add `withBookAccess` parameter to `ensureProfileExists()`
    - Add optional `bool withBookAccess = false` parameter
    - When `withBookAccess` is true AND profile is being created: set `has_book_access: true`, `access_type: 'book'`
    - When `withBookAccess` is true AND profile already exists with `has_book_access: false`: do UPDATE to set book access
    - When `withBookAccess` is false: keep current behavior unchanged
    - _Bug_Condition: ThankYouScreen needs to create profile with book access but ProfileService doesn't support it_
    - _Expected_Behavior: ProfileService can create/update profile with book access in single call_
    - _Preservation: Existing callers pass no param → default false → behavior unchanged_
    - _Requirements: 2.5, 3.4_

  - [x] 5.2 Add purchase validation method to ProfileService
    - Add method `Future<bool> validatePurchase(String email)` that queries purchases table
    - Check if `email` has a record with `access_released = true`
    - Return true if purchase exists, false otherwise
    - This prevents account creation for emails that did NOT actually purchase
    - _Requirements: 2.5_

- [x] 6. Rewrite ThankYouScreen with inline account creation

  - [x] 6.1 Extract email from URL query parameters
    - Update `/obrigado` route in `app_router.dart` to pass `GoRouterState` to ThankYouScreen
    - Accept `email` parameter in ThankYouScreen constructor (from `state.uri.queryParameters['external_reference']`)
    - In `initState`, set `_emailController.text = widget.email ?? ''`
    - If email is present, mark email field as readonly
    - _Bug_Condition: ThankYouScreen doesn't extract external_reference from URL_
    - _Expected_Behavior: Email auto-populated from URL, readonly, gold styling_
    - _Requirements: 1.3, 1.4, 2.3, 2.4_

  - [x] 6.2 Replace static content with inline account creation form
    - Remove "criar meu acesso" button that navigates to `/criar-acesso`
    - Add headline: "Seu acesso já está pronto."
    - Add subtitle: "Agora só falta criar sua senha para entrar no seu espaço diante do Pai."
    - Add email field (readonly, gold styling, pre-filled)
    - Add nome field (hint: "como quer ser chamado")
    - Add senha field (hint: "escolha uma senha", obscured)
    - Add "entrar na caminhada" button with loading state
    - Maintain contemplative design tokens (_bgColor, _goldPrimary, _textPrimary, _textSecondary)
    - _Bug_Condition: ThankYouScreen is static with no form, requires navigation to /criar-acesso_
    - _Expected_Behavior: All-in-one inline form on /obrigado, no separate screen needed_
    - _Requirements: 1.3, 2.3_

  - [x] 6.3 Implement full Supabase signUp flow on form submission
    - Validate fields (email non-empty, nome non-empty, senha >= 6 chars)
    - Call `ProfileService.instance.validatePurchase(email)` — if false, show error "Não encontramos uma compra para este email"
    - Call `Supabase.instance.client.auth.signUp(email: email, password: senha, data: {'nome': nome})`
    - Handle error: if email already registered, show "Já existe uma conta com este email. Faça login."
    - On success: call `ProfileService.instance.ensureProfileExists(displayName: nome, withBookAccess: true)`
    - Auto-login is implicit from signUp (Supabase sets session)
    - Navigate to `/home` via `context.go('/home')`
    - _Bug_Condition: _handleCreateAccess is Future.delayed + context.go('/home') without real auth_
    - _Expected_Behavior: Real signUp → profile with book access → auto-login → /home_
    - _Requirements: 1.5, 2.5_

  - [x] 6.4 Handle edge cases in account creation
    - Email already registered: show inline error message with gold styling
    - Weak password (< 6 chars): show validation message before submitting
    - Network error: show retry message
    - Missing external_reference in URL: show email field as editable (user can type manually)
    - _Requirements: 2.5_

- [x] 7. Remove /criar-acesso route from router

  - [x] 7.1 Remove GoRoute for `/criar-acesso` from app_router.dart
    - Delete the GoRoute with path `/criar-acesso` and name `criarAcesso`
    - Remove import of `CreateAccessScreen`
    - Remove `/criar-acesso` from the redirect whitelist in the redirect function
    - _Preservation: No other route references /criar-acesso — removal is safe_
    - _Requirements: 2.3_

  - [x] 7.2 Update ThankYouScreen route to pass query params
    - Modify the `/obrigado` GoRoute builder to extract `state.uri.queryParameters['external_reference']`
    - Pass extracted email to `ThankYouScreen(email: extractedEmail)`
    - Ensure both `/obrigado` and AppRoutes.thankYou routes pass the email parameter
    - _Requirements: 2.4_

- [x] 8. Add API endpoint for purchase validation (Flutter → Supabase)

  - [x] 8.1 Create Next.js API route for purchase validation
    - Create `app/api/checkout/validate-purchase/route.ts`
    - Accept POST with `{ email: string }`
    - Query purchases table for `email` with `access_released = true`
    - Return `{ valid: true, product_id }` or `{ valid: false }`
    - Use service role key (server-side only)
    - Alternatively: if Flutter can query purchases directly via Supabase RLS (user can read own purchases by email), use client-side query in ProfileService instead
    - _Requirements: 2.5_

- [x] 9. Fix implementation verification

  - [x] 9.1 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Post-Purchase Flow Activation Success
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied:
      - Webhook updates profile with `access_type = 'book'` for existing profiles
      - Webhook logs clear message when profile not found
      - ThankYouScreen extracts email from URL and displays readonly
      - Account creation actually creates Supabase auth user with book access
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 9.2 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Purchase Webhook and Existing Access Behavior
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm: non-payment webhooks still ignored, non-approved still saved without access, duplicates still skipped, existing access types not downgraded, public routes still accessible
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 10. Checkpoint - Ensure all tests pass
  - Run full test suite for webhook handler (TypeScript tests)
  - Run Flutter widget tests for ThankYouScreen
  - Run ProfileService unit tests
  - Verify migration SQL is syntactically correct
  - Verify router no longer has `/criar-acesso` route
  - Ask the user if questions arise or if manual Supabase testing is needed
