# Post-Purchase Flow Fix — Bugfix Design

## Overview

O fluxo pós-compra está quebrado em 3 pontos que impedem compradores de ativar seu acesso ao livro "Não Ore. Fale com o Pai." após pagamento aprovado no Mercado Pago. O webhook falha silenciosamente ao atualizar profiles (colunas potencialmente inexistentes e ausência de fallback para profile não encontrado), a ThankYouScreen força navegação desnecessária para `/criar-acesso`, e os query params com `external_reference` (email) não são extraídos da URL de retorno. O fix consolida a criação de conta diretamente na `/obrigado`, extrai o email da URL, robustece o webhook com logging e fallback, e atualiza o profile trigger para incluir colunas de acesso ao livro.

## Glossary

- **Bug_Condition (C)**: O conjunto de condições que causam falha no fluxo pós-compra — webhook não atualiza/cria acesso, email não é extraído da URL, conta não é criada
- **Property (P)**: Comportamento correto — webhook registra compra e atualiza/prepara acesso, ThankYouScreen exibe form inline com email preenchido, conta é criada com acesso ao livro e login automático
- **Preservation**: Funcionalidades existentes que devem permanecer intactas — webhook ignora non-payment e non-approved, idempotência, acesso free/admin inalterado, landing page e jornada gratuita funcionando
- **`handleNewUser()`**: Trigger function em `create-profile-trigger.sql` que cria profile automaticamente no signup
- **`ProfileService`**: Serviço Flutter em `profile_service.dart` que garante profile existe client-side como fallback
- **`external_reference`**: Campo da preferência do Mercado Pago que contém o email do comprador, retornado como query param na URL de sucesso
- **ThankYouScreen**: Tela Flutter em `/obrigado` que será reescrita para conter o form de criação de conta inline

## Bug Details

### Bug Condition

O bug se manifesta quando um usuário completa pagamento no Mercado Pago e é redirecionado para `/app/#/obrigado`. Três sub-condições independentes causam falha:

1. O webhook tenta `UPDATE profiles SET book_purchased_at, payment_id, payment_provider` mas essas colunas podem não existir na tabela
2. Se o profile não existe ainda (usuário não tem conta), o webhook apenas faz UPDATE que afeta 0 rows — sem fallback
3. A ThankYouScreen não extrai `external_reference` da URL e exige navegação para `/criar-acesso` onde o código de criação de conta é TODO

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type PostPurchaseFlowInput {paymentApproved, profileExists, urlHasExternalRef, screenContext}
  OUTPUT: boolean
  
  webhookFails := input.paymentApproved 
                  AND (NOT columnsExist('profiles', ['book_purchased_at', 'payment_id', 'payment_provider'])
                       OR (NOT input.profileExists AND webhookOnlyDoesUpdate()))
  
  emailNotExtracted := input.urlHasExternalRef 
                       AND NOT thankYouScreenExtractsEmail()
  
  accountNotCreated := input.screenContext == 'criar-acesso' 
                       AND createAccessIsNoop()
  
  RETURN webhookFails OR emailNotExtracted OR accountNotCreated
END FUNCTION
```

### Examples

- **Pagamento aprovado, profile existe, colunas ausentes**: Webhook retorna 200, `console.error('[Webhook] Error updating profile:', ...)`, profile permanece `access_type: 'free'` — mas purchase é salva com `access_released: true`
- **Pagamento aprovado, profile NÃO existe**: Webhook faz UPDATE...WHERE email='x@y.com', afeta 0 rows, nenhum erro logado, purchase salva mas acesso nunca é reconhecido quando conta for criada
- **Redirecionamento com `?external_reference=email@test.com`**: ThankYouScreen renderiza sem extrair params, email fica vazio, usuário precisa digitá-lo manualmente
- **Usuário clica "criar meu acesso"**: Navega para `/criar-acesso`, preenche form, clica "entrar na caminhada", `_handleCreateAccess()` faz `Future.delayed` e `context.go('/home')` sem criar conta real

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Webhook retorna 200 e ignora notificações que NÃO são de tipo payment (merchant_order, chargebacks)
- Webhook salva registro sem liberar acesso para pagamentos com status != 'approved' (pending, rejected)
- Webhook mantém idempotência via check de payment_id duplicado na tabela purchases
- Usuários com `access_type` 'book' ou 'admin' mantêm seu tipo sem rebaixamento
- Landing page de vendas e jornada gratuita funcionam sem autenticação
- Usuários free que fazem login veem conteúdo gratuito sem alteração de access_type
- Mouse clicks, navegação por rotas existentes e todo comportamento não-relacionado ao fluxo pós-compra

**Scope:**
Todas as interações que NÃO envolvem: (a) webhook com pagamento approved + tentativa de update de profile, (b) redirecionamento pós-pagamento para /obrigado, (c) criação de conta a partir da ThankYouScreen — devem ser completamente inalteradas por este fix.

## Hypothesized Root Cause

Based on the bug analysis, the most likely issues are:

1. **Colunas inexistentes no profile (webhook)**: O webhook tenta setar `book_purchased_at`, `payment_id`, `payment_provider` no profile mas essas colunas podem não existir na tabela profiles do Supabase. O trigger `handle_new_user()` só insere `id, nome, email, perfil_is_complete, senha_is_seted` — sem colunas de acesso ao livro.

2. **Ausência de fallback para profile inexistente (webhook)**: O código faz apenas `supabase.from('profiles').update(...)` sem verificar se o UPDATE afetou alguma row. Se o profile não existe (usuário ainda não criou conta), o update retorna sem erro mas afeta 0 rows. A compra fica salva em `purchases` mas o acesso nunca é propagado para o profile futuro.

3. **ThankYouScreen estática sem extração de URL params**: A `ThankYouScreen` é um widget estático que apenas renderiza texto e um botão para `/criar-acesso`. Não usa `GoRouterState` para extrair `state.uri.queryParameters['external_reference']`. Em Flutter Web com hash routing, a URL real é `/app/#/obrigado?external_reference=email` e GoRouter expõe os query params via `state.uri.queryParameters`.

4. **CreateAccessScreen com TODO placeholders**: O `_handleCreateAccess()` não chama `Supabase.instance.client.auth.signUp()`, não invoca `ProfileService.ensureProfileExists()`, não seta `has_book_access: true`, e não faz login automático. O código é literalmente `Future.delayed` + `context.go('/home')`.

5. **Profile trigger não inclui colunas de book access**: O trigger `handle_new_user()` insere apenas campos básicos. Quando o webhook encontra o profile (criado pelo trigger), não há colunas `book_purchased_at`, `payment_id`, `payment_provider` — causando erro no UPDATE. Mesmo `access_type` e `has_book_access` podem estar ausentes se não foram adicionadas à tabela.

## Correctness Properties

Property 1: Bug Condition - Post-Purchase Access Activation

_For any_ approved payment where the webhook receives notification AND either the profile exists without book access columns OR the profile doesn't exist yet, the fixed system SHALL ensure the purchase is recorded with `access_released = true` and, if the profile exists, update it with `access_type = 'book'` and `has_book_access = true` using only columns guaranteed to exist, with comprehensive logging at each step.

**Validates: Requirements 2.1, 2.2**

Property 2: Bug Condition - Email Extraction and Inline Account Creation

_For any_ redirect from Mercado Pago to `/obrigado` containing `external_reference` query parameter, the ThankYouScreen SHALL extract the email, display it readonly in an inline account creation form, and upon submission SHALL create a Supabase auth user, ensure profile with `has_book_access = true`, perform auto-login, and redirect to `/home`.

**Validates: Requirements 2.3, 2.4, 2.5**

Property 3: Preservation - Non-Payment Webhook Behavior

_For any_ webhook notification that is NOT an approved payment (non-payment types, pending/rejected status, or duplicate payment_id), the fixed webhook SHALL produce exactly the same behavior as the original — returning 200, ignoring non-payments, saving without releasing access for non-approved, and skipping duplicates.

**Validates: Requirements 3.1, 3.2, 3.3**

Property 4: Preservation - Existing Access Types and Free Flows

_For any_ user interaction that does NOT involve post-purchase activation (admin/book users, free users logging in, landing page visitors, free journey users), the fixed system SHALL produce exactly the same behavior, preserving existing access levels and unauthenticated access to public routes.

**Validates: Requirements 3.4, 3.5, 3.6**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `supabase/create-profile-trigger.sql`

**Function**: `handle_new_user()`

**Specific Changes**:
1. **Add book access columns to trigger**: Include `access_type DEFAULT 'free'`, `has_book_access DEFAULT false` in the INSERT within the trigger. This ensures every new profile has these columns populated.
2. **Add migration for existing profiles**: Create ALTER TABLE statement to add `book_purchased_at TIMESTAMPTZ`, `payment_id TEXT`, `payment_provider TEXT` columns if they don't exist.

---

**File**: `app/api/webhooks/mercadopago/route.ts`

**Function**: `POST(request)`

**Specific Changes**:
1. **Remove potentially missing columns from UPDATE**: Only update `access_type` and `has_book_access` (guaranteed to exist after migration). Move `book_purchased_at`, `payment_id`, `payment_provider` to the purchases table (already there as `payment_id`).
2. **Add row-count check after UPDATE**: After updating profile, check if any row was affected. If 0 rows updated (profile doesn't exist yet), log clearly that access will be picked up on account creation via the purchases table.
3. **Add comprehensive structured logging**: Log at each decision point — webhook received, payment type check, payment fetch, approval check, email extraction, idempotency check, purchase insert, profile update result.
4. **Ensure purchases table has all needed info**: The `purchases` table already stores `email`, `payment_id`, `access_released` — this is the source of truth for "user bought but hasn't created account yet".

---

**File**: `jornada_deus_pai/lib/features/sales/presentation/screens/thank_you_screen.dart`

**Function**: Complete rewrite of `ThankYouScreen`

**Specific Changes**:
1. **Extract `external_reference` from URL**: In `initState` or via GoRouter's `state.uri.queryParameters['external_reference']`, extract the email. Since GoRouter passes state in builder, pass email via constructor or use `GoRouterState.of(context)`.
2. **Replace static content with inline form**: Remove the "criar meu acesso" button + contemplative text. Replace with: headline "Seu acesso já está pronto.", subtitle "Agora só falta criar sua senha para entrar no seu espaço diante do Pai.", email field (readonly, gold styling), nome field, senha field, and "entrar na caminhada" button.
3. **Implement account creation flow**: On button press: validate fields → `supabase.auth.signUp(email, password, data: {nome})` → `ProfileService.ensureProfileExists(displayName: nome)` → update profile to `has_book_access: true, access_type: 'book'` → auto-login is implicit from signUp → `context.go('/home')`.
4. **Handle edge cases**: Email already registered (show "já existe uma conta com este email, faça login"), weak password, network errors. Check `purchases` table to validate this email actually purchased.

---

**File**: `jornada_deus_pai/lib/shared/core/app_router.dart`

**Specific Changes**:
1. **Remove `/criar-acesso` route**: Delete the GoRoute for `/criar-acesso` since functionality is absorbed into `/obrigado`.
2. **Update ThankYouScreen route to pass query params**: Ensure the `/obrigado` route builder passes `state` to ThankYouScreen so it can access query parameters.
3. **Remove `/criar-acesso` from redirect whitelist**: Clean up the redirect function.

---

**File**: `jornada_deus_pai/lib/shared/services/profile_service.dart`

**Function**: `ensureProfileExists()`

**Specific Changes**:
1. **Add `withBookAccess` parameter**: Allow callers to specify that the profile should be created/updated with `has_book_access: true` and `access_type: 'book'`.
2. **Update existing profile if book access needed**: If profile exists but `has_book_access` is false and `withBookAccess` is true, do an UPDATE.

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Test the webhook with mock payment notifications and verify profile state in the database. Test the ThankYouScreen rendering with URL query params and verify email extraction. Run CreateAccessScreen and verify no actual Supabase calls are made.

**Test Cases**:
1. **Webhook Profile Update Test**: Send approved payment notification for an email with existing profile → verify `access_type` remains 'free' (will fail on unfixed code if columns don't exist)
2. **Webhook Missing Profile Test**: Send approved payment notification for email with NO profile → verify purchase is saved but no profile update occurs (demonstrates the gap)
3. **URL Parameter Extraction Test**: Navigate to `/obrigado?external_reference=test@email.com` → verify email field is empty (will demonstrate extraction failure on unfixed code)
4. **Account Creation Noop Test**: Fill form on CreateAccessScreen and submit → verify no auth user is created in Supabase (demonstrates TODO placeholder)

**Expected Counterexamples**:
- Profile `access_type` stays 'free' after approved payment webhook (column update fails silently or columns don't exist)
- ThankYouScreen renders with empty email despite URL containing `external_reference`
- `_handleCreateAccess` returns without creating Supabase auth user
- Possible causes: missing DB columns, UPDATE without fallback, no URL param extraction, TODO placeholders

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  IF input.type == 'webhook_approved_payment' THEN
    result := webhookHandler_fixed(input)
    ASSERT purchases.find(payment_id) EXISTS AND access_released == true
    IF profileExists(input.email) THEN
      ASSERT profile.access_type == 'book'
      ASSERT profile.has_book_access == true
    END IF
    ASSERT logs.contain('Payment APPROVED', 'Profile updated' OR 'Profile not found, access via purchases')
  END IF
  
  IF input.type == 'thank_you_redirect' THEN
    screen := renderThankYouScreen(input.url_with_external_reference)
    ASSERT screen.emailField.value == input.external_reference
    ASSERT screen.emailField.readOnly == true
    ASSERT screen.hasInlineForm == true
  END IF
  
  IF input.type == 'account_creation_submit' THEN
    result := handleCreateAccess_fixed(input.email, input.nome, input.senha)
    ASSERT supabase.auth.user(input.email) EXISTS
    ASSERT profile(input.email).has_book_access == true
    ASSERT profile(input.email).access_type == 'book'
    ASSERT session.isAuthenticated == true
    ASSERT navigation.currentRoute == '/home'
  END IF
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  IF input.type == 'non_payment_webhook' THEN
    ASSERT webhookHandler_original(input) == webhookHandler_fixed(input)
    // Returns { received: true }, no DB changes
  END IF
  
  IF input.type == 'non_approved_payment' THEN
    ASSERT webhookHandler_original(input) == webhookHandler_fixed(input)
    // Saves purchase without releasing access
  END IF
  
  IF input.type == 'duplicate_payment' THEN
    ASSERT webhookHandler_original(input) == webhookHandler_fixed(input)
    // Returns 'Already processed'
  END IF
  
  IF input.type == 'existing_book_user_login' THEN
    ASSERT accessType_before == accessType_after == 'book'
  END IF
  
  IF input.type == 'free_user_login' THEN
    ASSERT accessType_before == accessType_after == 'free'
  END IF
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many webhook payloads with varying types, statuses, and payment IDs to verify the webhook's routing logic is unchanged
- It catches edge cases in URL parsing that manual unit tests might miss
- It provides strong guarantees that non-purchase navigation flows are unaffected

**Test Plan**: Observe behavior on UNFIXED code first for non-payment webhooks, non-approved payments, and duplicate checks. Then write property-based tests capturing that behavior.

**Test Cases**:
1. **Non-Payment Webhook Preservation**: Verify that merchant_order, chargebacks, and unknown types continue to be ignored with 200 response
2. **Non-Approved Payment Preservation**: Verify that pending/rejected payments are saved without releasing access
3. **Idempotency Preservation**: Verify that duplicate payment_id notifications are skipped without re-processing
4. **Access Type Preservation**: Verify that existing book/admin users are never downgraded
5. **Public Route Preservation**: Verify that sales page, free journey, and entry screen remain accessible without auth

### Unit Tests

- Test webhook route handler with various payload shapes (body.data.id vs query param data.id)
- Test email extraction from `payment.external_reference` vs `payment.payer.email` fallback
- Test profile update success/failure paths with mocked Supabase client
- Test ThankYouScreen renders correctly with and without `external_reference` query param
- Test `_handleCreateAccess` creates auth user, ensures profile, sets book access, and navigates
- Test edge cases: email already exists, invalid password, network timeout, missing external_reference

### Property-Based Tests

- Generate random webhook payloads (varying type, action, data.id, status) and verify routing decisions match spec (only process approved payments)
- Generate random URL query parameter combinations and verify email extraction works for `external_reference` and gracefully handles missing/malformed params
- Generate random profile states and verify webhook never downgrades access_type from book/admin to anything lower

### Integration Tests

- Full flow: checkout creates preference → webhook receives approved → ThankYouScreen loads with email → user creates account → profile has book access → user lands on /home
- Retry flow: user leaves ThankYouScreen without creating account → returns later → purchase exists in DB → creates account → ProfileService picks up access from purchases
- Webhook-then-signup: webhook fires before user creates account → purchase saved → user creates account via ThankYouScreen → profile created with book access based on purchases table lookup
