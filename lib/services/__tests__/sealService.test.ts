import { describe, it, expect, vi, beforeEach } from 'vitest';
import { hasSeal, awardSeal, checkSealConditions, getSealInfo } from '../sealService';
import * as messageService from '../messageService';
import * as progressService from '../progressService';

// Mock Supabase client
vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn(() => ({
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          single: vi.fn(),
        })),
      })),
      update: vi.fn(() => ({
        eq: vi.fn(() => ({
          select: vi.fn(),
        })),
      })),
    })),
    auth: {
      getUser: vi.fn(),
    },
  })),
}));

// Mock message and progress services
vi.mock('../messageService', () => ({
  getUserMessageCount: vi.fn(),
}));

vi.mock('../progressService', () => ({
  getProgress: vi.fn(),
}));

describe('Seal Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('hasSeal', () => {
    it('should return true when user has seal', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: true },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await hasSeal('user-123');

      expect(result.data).toBe(true);
      expect(result.error).toBeNull();
    });

    it('should return false when user does not have seal', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: false },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await hasSeal('user-123');

      expect(result.data).toBe(false);
      expect(result.error).toBeNull();
    });

    it('should return error when database query fails', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: null,
              error: { message: 'Database error' },
            }),
          }),
        }),
      } as never);

      const result = await hasSeal('user-123');

      expect(result.data).toBeNull();
      expect(result.error).toBe('Erro ao verificar selo.');
    });

    it('should return error for invalid user ID', async () => {
      const result = await hasSeal('');

      expect(result.data).toBeNull();
      expect(result.error).toBe('ID de usuário inválido.');
    });
  });

  describe('awardSeal', () => {
    it('should award seal successfully', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      // Mock check for existing seal
      vi.mocked(mockSupabase.from).mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: false },
              error: null,
            }),
          }),
        }),
      } as never);

      // Mock update
      vi.mocked(mockSupabase.from).mockReturnValueOnce({
        update: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            error: null,
          }),
        }),
      } as never);

      const result = await awardSeal('user-123', 'journey_complete');

      expect(result.data).toBe(true);
      expect(result.error).toBeNull();
    });

    it('should not award seal if already awarded', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: true },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await awardSeal('user-123', 'journey_complete');

      expect(result.data).toBe(true);
      expect(result.error).toBeNull();
    });

    it('should return error for invalid reason', async () => {
      const result = await awardSeal('user-123', 'invalid_reason' as never);

      expect(result.data).toBeNull();
      expect(result.error).toBe('Motivo de desbloqueio inválido.');
    });
  });

  describe('checkSealConditions', () => {
    it('should return shouldAward true when journey is complete', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      // Mock hasSeal check
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: false },
              error: null,
            }),
          }),
        }),
      } as never);

      // Mock progress service
      vi.mocked(progressService.getProgress).mockResolvedValue({
        data: {
          totalChapters: 5,
          completedChapters: 5,
          currentChapterIndex: 4,
          percentComplete: 100,
          chapters: [],
        },
        error: null,
      });

      // Mock message count
      vi.mocked(messageService.getUserMessageCount).mockResolvedValue({
        data: 3,
        error: null,
      });

      const result = await checkSealConditions('user-123');

      expect(result.data).toEqual({
        journeyComplete: true,
        firstMessageSent: true,
        shouldAward: true,
      });
      expect(result.error).toBeNull();
    });

    it('should return shouldAward false when journey is not complete', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: false },
              error: null,
            }),
          }),
        }),
      } as never);

      vi.mocked(progressService.getProgress).mockResolvedValue({
        data: {
          totalChapters: 5,
          completedChapters: 2,
          currentChapterIndex: 2,
          percentComplete: 40,
          chapters: [],
        },
        error: null,
      });

      vi.mocked(messageService.getUserMessageCount).mockResolvedValue({
        data: 1,
        error: null,
      });

      const result = await checkSealConditions('user-123');

      expect(result.data).toEqual({
        journeyComplete: false,
        firstMessageSent: true,
        shouldAward: false,
      });
      expect(result.error).toBeNull();
    });

    it('should return shouldAward false if seal already awarded', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: { seal_awarded: true },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await checkSealConditions('user-123');

      expect(result.data).toEqual({
        journeyComplete: false,
        firstMessageSent: false,
        shouldAward: false,
      });
      expect(result.error).toBeNull();
    });
  });

  describe('getSealInfo', () => {
    it('should return seal information', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      const mockDate = '2024-01-15T10:00:00Z';
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: {
                seal_awarded: true,
                seal_awarded_at: mockDate,
                seal_unlock_reason: 'journey_complete',
              },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await getSealInfo('user-123');

      expect(result.data).toEqual({
        awarded: true,
        awardedAt: mockDate,
        unlockReason: 'journey_complete',
      });
      expect(result.error).toBeNull();
    });

    it('should return not awarded when seal is not awarded', async () => {
      const { createClient } = await import('@/lib/supabase/server');
      const mockSupabase = await createClient();
      
      vi.mocked(mockSupabase.from).mockReturnValue({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            single: vi.fn().mockResolvedValue({
              data: {
                seal_awarded: false,
                seal_awarded_at: null,
                seal_unlock_reason: null,
              },
              error: null,
            }),
          }),
        }),
      } as never);

      const result = await getSealInfo('user-123');

      expect(result.data).toEqual({
        awarded: false,
        awardedAt: null,
        unlockReason: null,
      });
      expect(result.error).toBeNull();
    });
  });
});
