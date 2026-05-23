import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { NextRequest } from 'next/server';

/**
 * Preservation Property Tests — Non-Purchase Webhook and Existing Access Behavior
 *
 * **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
 *
 * These tests verify EXISTING CORRECT behaviors that must NOT break during the fix.
 * They should PASS on the current (unfixed) code because the tested behaviors
 * are already working correctly.
 *
 * Property 3: Preservation - Non-Payment Webhook Behavior
 * _For any_ webhook notification that is NOT an approved payment (non-payment types,
 * pending/rejected status, or duplicate payment_id), the webhook SHALL produce exactly
 * the same behavior as the original — returning 200, ignoring non-payments, saving
 * without releasing access for non-approved, and skipping duplicates.
 */

// --- Mocks ---

const mockPaymentGet = vi.fn();
vi.mock('@/lib/mercadopago/client', () => ({
  paymentClient: {
    get: (...args: unknown[]) => mockPaymentGet(...args),
  },
}));

const mockSupabaseUpdate = vi.fn();
const mockSupabaseInsert = vi.fn();
const mockSupabaseMaybeSingle = vi.fn();
const mockSupabaseProfileSelectResult = vi.fn();

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

// Helper to create webhook request
function createWebhookRequest(
  body: Record<string, unknown>,
  queryParams?: Record<string, string>
): NextRequest {
  let url = 'http://localhost:3000/api/webhooks/mercadopago';
  if (queryParams) {
    const params = new URLSearchParams(queryParams);
    url += `?${params.toString()}`;
  }
  return new NextRequest(url, {
    method: 'POST',
    body: JSON.stringify(body),
  });
}

describe('Preservation: Non-Payment Webhook Behavior (Property 3)', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(console, 'log').mockImplementation(() => {});
    vi.spyOn(console, 'error').mockImplementation(() => {});

    // Default mocks
    mockSupabaseMaybeSingle.mockResolvedValue({ data: null, error: null });
    mockSupabaseInsert.mockResolvedValue({ error: null });
    mockSupabaseProfileSelectResult.mockResolvedValue({ data: [], error: null });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('Preservation 3.1: Non-payment webhook types are ignored', () => {
    /**
     * **Validates: Requirements 3.1**
     *
     * _For any_ webhook with type != 'payment' (merchant_order, chargebacks, unknown),
     * the handler returns { received: true } and performs NO database writes.
     */

    const nonPaymentTypes = [
      'merchant_order',
      'chargeback',
      'plan',
      'subscription',
      'invoice',
      'point_integration_wh',
    ];

    for (const webhookType of nonPaymentTypes) {
      it(`should ignore webhook type "${webhookType}" with no DB changes`, async () => {
        const { POST } = await import('../route');

        const request = createWebhookRequest({
          type: webhookType,
          action: `${webhookType}.created`,
          data: { id: '12345' },
        });

        const response = await POST(request);
        const json = await response.json();

        // Returns { received: true }
        expect(json.received).toBe(true);
        // No payment API call
        expect(mockPaymentGet).not.toHaveBeenCalled();
        // No purchases insert
        expect(mockSupabaseInsert).not.toHaveBeenCalled();
        // No profiles update
        expect(mockSupabaseUpdate).not.toHaveBeenCalled();
      });
    }

    it('should ignore webhook with empty type and non-payment action', async () => {
      const { POST } = await import('../route');

      const request = createWebhookRequest({
        type: 'merchant_order',
        action: 'merchant_order.updated',
        data: { id: '55555' },
      });

      const response = await POST(request);
      const json = await response.json();

      expect(json.received).toBe(true);
      expect(mockPaymentGet).not.toHaveBeenCalled();
      expect(mockSupabaseInsert).not.toHaveBeenCalled();
      expect(mockSupabaseUpdate).not.toHaveBeenCalled();
    });
  });

  describe('Preservation 3.2: Non-approved payments saved without releasing access', () => {
    /**
     * **Validates: Requirements 3.2**
     *
     * _For any_ payment with status != 'approved' (pending, rejected, cancelled, in_process),
     * the handler returns 200 without inserting a purchase or updating a profile.
     * The current code fetches the payment and then returns early if status != 'approved'.
     */

    const nonApprovedStatuses = ['pending', 'rejected', 'cancelled', 'in_process', 'refunded'];

    for (const status of nonApprovedStatuses) {
      it(`should NOT release access for payment status "${status}"`, async () => {
        mockPaymentGet.mockResolvedValue({
          id: 33333,
          status,
          external_reference: 'user@example.com',
          payer: { email: 'user@example.com' },
        });

        const { POST } = await import('../route');

        const request = createWebhookRequest({
          type: 'payment',
          action: 'payment.updated',
          data: { id: '33333' },
        });

        const response = await POST(request);
        const json = await response.json();

        // Returns received: true with the status
        expect(json.received).toBe(true);
        expect(json.status).toBe(status);
        // No purchase record inserted (access not released)
        expect(mockSupabaseInsert).not.toHaveBeenCalled();
        // No profile update
        expect(mockSupabaseUpdate).not.toHaveBeenCalled();
      });
    }
  });

  describe('Preservation 3.3: Duplicate payment_id is skipped (idempotency)', () => {
    /**
     * **Validates: Requirements 3.3**
     *
     * _For any_ payment_id that already exists in the purchases table,
     * the handler returns { received: true, message: 'Already processed' }
     * without re-inserting or re-updating.
     */

    it('should return "Already processed" for duplicate payment_id', async () => {
      mockPaymentGet.mockResolvedValue({
        id: 44444,
        status: 'approved',
        external_reference: 'duplicate@example.com',
        payer: { email: 'duplicate@example.com' },
      });

      // Simulate: payment already exists in purchases table
      mockSupabaseMaybeSingle.mockResolvedValue({
        data: { id: 'existing-purchase-id' },
        error: null,
      });

      const { POST } = await import('../route');

      const request = createWebhookRequest({
        type: 'payment',
        action: 'payment.created',
        data: { id: '44444' },
      });

      const response = await POST(request);
      const json = await response.json();

      // Returns already processed message
      expect(json.received).toBe(true);
      expect(json.message).toBe('Already processed');
      // No duplicate insert
      expect(mockSupabaseInsert).not.toHaveBeenCalled();
      // No profile update on duplicate
      expect(mockSupabaseUpdate).not.toHaveBeenCalled();
    });

    it('should not re-process even if called multiple times with same payment_id', async () => {
      mockPaymentGet.mockResolvedValue({
        id: 55555,
        status: 'approved',
        external_reference: 'retry@example.com',
        payer: { email: 'retry@example.com' },
      });

      // First call — already in DB
      mockSupabaseMaybeSingle.mockResolvedValue({
        data: { id: 'existing-id' },
        error: null,
      });

      const { POST } = await import('../route');

      const request1 = createWebhookRequest({
        type: 'payment',
        action: 'payment.created',
        data: { id: '55555' },
      });

      const response1 = await POST(request1);
      const json1 = await response1.json();

      expect(json1.message).toBe('Already processed');

      // Second call — still in DB
      const request2 = createWebhookRequest({
        type: 'payment',
        action: 'payment.created',
        data: { id: '55555' },
      });

      const response2 = await POST(request2);
      const json2 = await response2.json();

      expect(json2.message).toBe('Already processed');
      // Zero inserts and zero updates across both calls
      expect(mockSupabaseInsert).not.toHaveBeenCalled();
      expect(mockSupabaseUpdate).not.toHaveBeenCalled();
    });
  });

  describe('Preservation: Payments without payment ID are ignored', () => {
    /**
     * _For any_ webhook notification with type 'payment' but no data.id
     * and no query param data.id, the handler returns { received: true }
     * without attempting any payment fetch or DB operation.
     */

    it('should return { received: true } when no payment ID is present in body or query', async () => {
      const { POST } = await import('../route');

      const request = createWebhookRequest({
        type: 'payment',
        action: 'payment.created',
        data: {},
      });

      const response = await POST(request);
      const json = await response.json();

      expect(json.received).toBe(true);
      // No payment fetch attempted
      expect(mockPaymentGet).not.toHaveBeenCalled();
      // No DB operations
      expect(mockSupabaseInsert).not.toHaveBeenCalled();
      expect(mockSupabaseUpdate).not.toHaveBeenCalled();
    });

    it('should return { received: true } when data field is missing entirely', async () => {
      const { POST } = await import('../route');

      const request = createWebhookRequest({
        type: 'payment',
        action: 'payment.created',
      });

      const response = await POST(request);
      const json = await response.json();

      expect(json.received).toBe(true);
      expect(mockPaymentGet).not.toHaveBeenCalled();
      expect(mockSupabaseInsert).not.toHaveBeenCalled();
      expect(mockSupabaseUpdate).not.toHaveBeenCalled();
    });
  });
});
