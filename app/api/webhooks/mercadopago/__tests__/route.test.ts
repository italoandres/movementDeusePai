import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { NextRequest } from 'next/server';

/**
 * Bug Condition Exploration Test — Post-Purchase Flow Activation Failure
 *
 * **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**
 *
 * This test DEMONSTRATES the bugs in the current webhook handler:
 *
 * Bug 1.1: Webhook tries to UPDATE profiles with columns (book_purchased_at,
 *           payment_id, payment_provider) that may not exist — causing the
 *           update to fail silently. Even if the update "succeeds" at the
 *           Supabase level, the profile's access_type stays 'free'.
 *
 * Bug 1.2: When a profile doesn't exist (0 rows affected by UPDATE), there's
 *           no fallback logging indicating that access will be deferred.
 *
 * Bug 1.3/1.4 (Flutter): ThankYouScreen doesn't extract external_reference
 *           from URL query parameters — documented as comments below.
 *
 * Bug 1.5 (Flutter): CreateAccessScreen's _handleCreateAccess is a noop
 *           (Future.delayed + context.go without real Supabase signUp) —
 *           documented as comments below.
 *
 * EXPECTED OUTCOME: These tests FAIL on unfixed code because they assert
 * the CORRECT behavior which is currently broken. Failure proves the bugs exist.
 */

// --- Mocks ---

// Mock the Mercado Pago client
const mockPaymentGet = vi.fn();
vi.mock('@/lib/mercadopago/client', () => ({
  paymentClient: {
    get: (...args: unknown[]) => mockPaymentGet(...args),
  },
}));

// Mock Supabase client
const mockSupabaseUpdate = vi.fn();
const mockSupabaseInsert = vi.fn();
const mockSupabaseProfileSelectResult = vi.fn();
const mockSupabaseMaybeSingle = vi.fn();

const mockSupabaseFrom = vi.fn((table: string) => {
  if (table === 'purchases') {
    return {
      insert: mockSupabaseInsert,
      select: () => ({
        eq: () => ({
          maybeSingle: mockSupabaseMaybeSingle,
        }),
      }),
    };
  }
  if (table === 'profiles') {
    return {
      update: (data: Record<string, unknown>) => {
        mockSupabaseUpdate(data);
        return {
          eq: () => ({
            select: mockSupabaseProfileSelectResult,
          }),
        };
      },
    };
  }
  return {};
});

vi.mock('@supabase/supabase-js', () => ({
  createClient: () => ({
    from: mockSupabaseFrom,
  }),
}));

// Capture console output for log assertion
const consoleLogs: string[] = [];
const consoleErrors: string[] = [];

describe('Bug Condition Exploration: Webhook Post-Purchase Flow', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    consoleLogs.length = 0;
    consoleErrors.length = 0;

    vi.spyOn(console, 'log').mockImplementation((...args: unknown[]) => {
      consoleLogs.push(args.map(String).join(' '));
    });
    vi.spyOn(console, 'error').mockImplementation((...args: unknown[]) => {
      consoleErrors.push(args.map(String).join(' '));
    });

    // Default: no existing purchase (idempotency check passes)
    mockSupabaseMaybeSingle.mockResolvedValue({ data: null, error: null });
    // Default: insert succeeds
    mockSupabaseInsert.mockResolvedValue({ error: null });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('Case A: Approved payment with EXISTING profile — access_type stays free (Bug 1.1)', () => {
    it('should update profile with ONLY access_type and has_book_access (no extra columns)', async () => {
      /**
       * BUG DEMONSTRATION:
       * The current webhook sends book_purchased_at, payment_id, payment_provider
       * to the profiles table UPDATE. These columns may not exist, causing the
       * update to fail silently OR update with irrelevant columns while the
       * real access columns don't change.
       *
       * EXPECTED (correct) behavior: Only update access_type='book' and has_book_access=true
       * ACTUAL (buggy) behavior: Tries to set book_purchased_at, payment_id, payment_provider
       */
      mockPaymentGet.mockResolvedValue({
        id: 12345,
        status: 'approved',
        external_reference: 'buyer@example.com',
        payer: { email: 'buyer@example.com' },
      });

      // Simulate profile exists — update "succeeds" and returns the updated row
      mockSupabaseProfileSelectResult.mockResolvedValue({ data: [{ id: 'profile-1' }], error: null });

      const { POST } = await import('../route');

      const request = new NextRequest('http://localhost:3000/api/webhooks/mercadopago', {
        method: 'POST',
        body: JSON.stringify({
          type: 'payment',
          action: 'payment.created',
          data: { id: '12345' },
        }),
      });

      await POST(request);

      // ASSERTION: The webhook should ONLY update access_type and has_book_access
      // This will FAIL because the current code also sends book_purchased_at,
      // payment_id, and payment_provider
      expect(mockSupabaseUpdate).toHaveBeenCalledWith({
        access_type: 'book',
        has_book_access: true,
      });
    });

    it('should NOT include book_purchased_at, payment_id, or payment_provider in profile update', async () => {
      /**
       * BUG DEMONSTRATION:
       * The current code updates profiles with columns that belong in the
       * purchases table, not in profiles. This causes silent failures when
       * those columns don't exist on the profiles table.
       */
      mockPaymentGet.mockResolvedValue({
        id: 99999,
        status: 'approved',
        external_reference: 'user@test.com',
        payer: { email: 'user@test.com' },
      });

      mockSupabaseProfileSelectResult.mockResolvedValue({ data: [{ id: 'profile-1' }], error: null });

      const { POST } = await import('../route');

      const request = new NextRequest('http://localhost:3000/api/webhooks/mercadopago', {
        method: 'POST',
        body: JSON.stringify({
          type: 'payment',
          action: 'payment.updated',
          data: { id: '99999' },
        }),
      });

      await POST(request);

      // Get the actual update payload
      const updatePayload = mockSupabaseUpdate.mock.calls[0]?.[0];

      // ASSERTION: These columns should NOT be in the profile update
      // This will FAIL because the current code includes them
      expect(updatePayload).not.toHaveProperty('book_purchased_at');
      expect(updatePayload).not.toHaveProperty('payment_id');
      expect(updatePayload).not.toHaveProperty('payment_provider');
    });
  });

  describe('Case B: Approved payment with NO profile — no fallback log (Bug 1.2)', () => {
    it('should log a clear message when profile update affects 0 rows', async () => {
      /**
       * BUG DEMONSTRATION:
       * When a profile doesn't exist, the UPDATE affects 0 rows but
       * the webhook logs "Profile updated to book access" regardless.
       * There's no check for rows affected and no log indicating
       * that access will be picked up on account creation.
       *
       * EXPECTED: Log "[Webhook] Profile not found for buyer@new.com — access
       *           will be picked up on account creation via purchases table"
       * ACTUAL: Logs "Profile updated to book access" even when 0 rows affected
       */
      mockPaymentGet.mockResolvedValue({
        id: 77777,
        status: 'approved',
        external_reference: 'buyer@new.com',
        payer: { email: 'buyer@new.com' },
      });

      // Simulate: update "succeeds" but affects 0 rows (profile doesn't exist)
      // Supabase returns no error but the update matched nothing
      mockSupabaseProfileSelectResult.mockResolvedValue({ error: null, data: [] });

      const { POST } = await import('../route');

      const request = new NextRequest('http://localhost:3000/api/webhooks/mercadopago', {
        method: 'POST',
        body: JSON.stringify({
          type: 'payment',
          action: 'payment.created',
          data: { id: '77777' },
        }),
      });

      await POST(request);

      // ASSERTION: Should log that profile was NOT found and access is deferred
      // This will FAIL because the current code doesn't check row count
      const allLogs = [...consoleLogs, ...consoleErrors].join('\n');
      expect(allLogs).toContain('Profile not found');
      expect(allLogs).toContain('buyer@new.com');
    });

    it('should NOT log "Profile updated" when profile does not exist', async () => {
      /**
       * BUG DEMONSTRATION:
       * The current code logs "Profile updated to book access" whenever
       * the Supabase update call returns without an error — even if
       * no rows were actually affected (profile doesn't exist).
       */
      mockPaymentGet.mockResolvedValue({
        id: 88888,
        status: 'approved',
        external_reference: 'nobody@example.com',
        payer: { email: 'nobody@example.com' },
      });

      // No error returned, but 0 rows affected (profile doesn't exist)
      mockSupabaseProfileSelectResult.mockResolvedValue({ error: null, data: [] });

      const { POST } = await import('../route');

      const request = new NextRequest('http://localhost:3000/api/webhooks/mercadopago', {
        method: 'POST',
        body: JSON.stringify({
          type: 'payment',
          action: 'payment.created',
          data: { id: '88888' },
        }),
      });

      await POST(request);

      // ASSERTION: Should NOT claim profile was updated when it doesn't exist
      // This will FAIL because the current code always logs success when no error
      const successLogs = consoleLogs.filter(
        (log) => log.includes('Profile updated to book access')
      );
      expect(successLogs).toHaveLength(0);
    });
  });
});

/**
 * ==========================================================================
 * FLUTTER BUG CONDITIONS (documented, not executable in Vitest)
 * ==========================================================================
 *
 * Bug 1.3 — ThankYouScreen forces navigation to /criar-acesso:
 *   The current ThankYouScreen (thank_you_screen.dart) renders a static
 *   "criar meu acesso" button that navigates to a separate route.
 *   Expected: All account creation happens inline on /obrigado.
 *   To test: Widget test that verifies ThankYouScreen contains email field,
 *   nome field, senha field, and submit button — all inline.
 *
 * Bug 1.4 — ThankYouScreen doesn't extract external_reference from URL:
 *   The current ThankYouScreen constructor doesn't accept an email parameter.
 *   GoRouter passes state.uri.queryParameters['external_reference'] but the
 *   screen never reads it. When navigating to /obrigado?external_reference=x@y.com,
 *   the email field remains empty.
 *   To test: Widget test that navigates to /obrigado?external_reference=test@email.com
 *   and asserts the email TextEditingController.text == 'test@email.com'.
 *
 * Bug 1.5 — CreateAccessScreen._handleCreateAccess is a noop:
 *   The current implementation is:
 *     await Future.delayed(const Duration(milliseconds: 1500));
 *     if (mounted) context.go('/home');
 *   No call to Supabase.instance.client.auth.signUp().
 *   No call to ProfileService.ensureProfileExists().
 *   No setting of has_book_access = true.
 *   To test: Unit test that mocks Supabase auth client and verifies
 *   signUp is called — test will fail because signUp is never invoked.
 *
 * ==========================================================================
 */
