import { describe, it, expect, vi, beforeEach } from 'vitest';
import {
  initializeProgress,
  getProgress,
} from '../progressService';

// Mock Supabase server client
const mockFrom = vi.fn();

vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn(() => ({
    from: mockFrom,
  })),
}));

describe('Progress Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('initializeProgress', () => {
    it('should initialize progress for a new user', async () => {
      const userId = 'user-1';
      const mockChapters = [
        { id: 'ch-1', order_index: 1 },
        { id: 'ch-2', order_index: 2 },
        { id: 'ch-3', order_index: 3 },
      ];

      // Mock: Check existing progress (none found)
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: [],
              error: null,
            }),
          }),
        }),
      });

      // Mock: Get all chapters
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: mockChapters,
            error: null,
          }),
        }),
      });

      // Mock: Insert progress records
      mockFrom.mockReturnValueOnce({
        insert: vi.fn().mockResolvedValue({
          data: null,
          error: null,
        }),
      });

      const result = await initializeProgress(userId);

      expect(result.data).toBe(true);
      expect(result.error).toBeNull();
    });

    it('should not reinitialize if progress already exists', async () => {
      const userId = 'user-1';

      // Mock: Check existing progress (found)
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: [{ id: 'progress-1' }],
              error: null,
            }),
          }),
        }),
      });

      const result = await initializeProgress(userId);

      expect(result.data).toBe(true);
      expect(result.error).toBeNull();
    });

    it('should handle error when no chapters exist', async () => {
      const userId = 'user-1';

      // Mock: Check existing progress (none found)
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: [],
              error: null,
            }),
          }),
        }),
      });

      // Mock: Get all chapters (none found)
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: [],
            error: null,
          }),
        }),
      });

      const result = await initializeProgress(userId);

      expect(result.data).toBeNull();
      expect(result.error).toBe('Nenhum capítulo encontrado.');
    });
  });

  describe('getProgress', () => {
    it('should return journey progress with correct unlock status', async () => {
      const userId = 'user-1';
      const mockChapters = [
        { id: 'ch-1', order_index: 1, title: 'Chapter 1', content: { messages: [] } },
        { id: 'ch-2', order_index: 2, title: 'Chapter 2', content: { messages: [] } },
        { id: 'ch-3', order_index: 3, title: 'Chapter 3', content: { messages: [] } },
      ];
      const mockProgress = [
        { chapter_id: 'ch-1', completed: true, completed_at: '2024-01-01' },
        { chapter_id: 'ch-2', completed: false, completed_at: null },
        { chapter_id: 'ch-3', completed: false, completed_at: null },
      ];

      // Mock: Get all chapters
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: mockChapters,
            error: null,
          }),
        }),
      });

      // Mock: Get user progress
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockProgress,
            error: null,
          }),
        }),
      });

      const result = await getProgress(userId);

      expect(result.data).not.toBeNull();
      expect(result.data?.totalChapters).toBe(3);
      expect(result.data?.completedChapters).toBe(1);
      expect(result.data?.currentChapterIndex).toBe(1); // 0-indexed, so chapter 2
      expect(result.data?.percentComplete).toBe(33);
      expect(result.data?.chapters[0].unlocked).toBe(true); // First chapter always unlocked
      expect(result.data?.chapters[0].completed).toBe(true);
      expect(result.data?.chapters[1].unlocked).toBe(true); // Unlocked because ch-1 is completed
      expect(result.data?.chapters[1].completed).toBe(false);
      expect(result.data?.chapters[2].unlocked).toBe(false); // Locked because ch-2 is not completed
      expect(result.error).toBeNull();
    });

    it('should handle completed journey', async () => {
      const userId = 'user-1';
      const mockChapters = [
        { id: 'ch-1', order_index: 1, title: 'Chapter 1', content: { messages: [] } },
        { id: 'ch-2', order_index: 2, title: 'Chapter 2', content: { messages: [] } },
      ];
      const mockProgress = [
        { chapter_id: 'ch-1', completed: true, completed_at: '2024-01-01' },
        { chapter_id: 'ch-2', completed: true, completed_at: '2024-01-02' },
      ];

      // Mock: Get all chapters
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: mockChapters,
            error: null,
          }),
        }),
      });

      // Mock: Get user progress
      mockFrom.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockProgress,
            error: null,
          }),
        }),
      });

      const result = await getProgress(userId);

      expect(result.data?.completedChapters).toBe(2);
      expect(result.data?.percentComplete).toBe(100);
      expect(result.data?.currentChapterIndex).toBe(1); // Last chapter index
    });
  });
});
