import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createMessage } from '../messageService.client';

// Mock Supabase client
const mockInsert = vi.fn();
const mockSelect = vi.fn();
const mockSingle = vi.fn();
const mockFrom = vi.fn(() => ({
  insert: mockInsert,
}));

vi.mock('@/lib/supabase/client', () => ({
  createClient: () => ({
    from: mockFrom,
  }),
}));

describe('Client-Side Message Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockInsert.mockReturnValue({
      select: mockSelect,
    });
    mockSelect.mockReturnValue({
      single: mockSingle,
    });
  });

  describe('createMessage', () => {
    it('should successfully create a message', async () => {
      const mockMessage = {
        id: 'msg-123',
        user_id: 'user-1',
        chapter_id: 'chapter-1',
        content: 'Test message',
        created_at: new Date().toISOString(),
      };

      mockSingle.mockResolvedValue({
        data: mockMessage,
        error: null,
      });

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(true);
      expect(result.message).toEqual(mockMessage);
      expect(result.error).toBeUndefined();

      expect(mockFrom).toHaveBeenCalledWith('messages');
      expect(mockInsert).toHaveBeenCalledWith({
        user_id: 'user-1',
        chapter_id: 'chapter-1',
        content: 'Test message',
      });
    });

    it('should trim whitespace from message content', async () => {
      const mockMessage = {
        id: 'msg-123',
        user_id: 'user-1',
        chapter_id: 'chapter-1',
        content: 'Test message',
        created_at: new Date().toISOString(),
      };

      mockSingle.mockResolvedValue({
        data: mockMessage,
        error: null,
      });

      await createMessage('user-1', 'chapter-1', '  Test message  ');

      expect(mockInsert).toHaveBeenCalledWith({
        user_id: 'user-1',
        chapter_id: 'chapter-1',
        content: 'Test message',
      });
    });

    it('should reject empty messages', async () => {
      const result = await createMessage('user-1', 'chapter-1', '');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Mensagem não pode estar vazia.');
      expect(mockFrom).not.toHaveBeenCalled();
    });

    it('should reject whitespace-only messages', async () => {
      const result = await createMessage('user-1', 'chapter-1', '   ');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Mensagem não pode estar vazia.');
      expect(mockFrom).not.toHaveBeenCalled();
    });

    it('should reject invalid userId', async () => {
      const result = await createMessage('', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Dados inválidos para enviar mensagem.');
      expect(mockFrom).not.toHaveBeenCalled();
    });

    it('should reject invalid chapterId', async () => {
      const result = await createMessage('user-1', '', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Dados inválidos para enviar mensagem.');
      expect(mockFrom).not.toHaveBeenCalled();
    });

    it('should handle database errors', async () => {
      mockSingle.mockResolvedValue({
        data: null,
        error: { message: 'Database error' },
      });

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Erro ao salvar mensagem. Tente novamente.');
    });

    it('should handle network errors', async () => {
      mockSingle.mockResolvedValue({
        data: null,
        error: { message: 'Failed to fetch' },
      });

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Problema de conexão. Verifique sua internet e tente novamente.');
    });

    it('should handle null data response', async () => {
      mockSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Erro ao criar mensagem.');
    });

    it('should handle unexpected exceptions', async () => {
      mockSingle.mockRejectedValue(new Error('Unexpected error'));

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Erro inesperado ao salvar mensagem.');
    });

    it('should handle network exceptions', async () => {
      mockSingle.mockRejectedValue(new Error('Failed to fetch'));

      const result = await createMessage('user-1', 'chapter-1', 'Test message');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Problema de conexão. Verifique sua internet e tente novamente.');
    });
  });
});
