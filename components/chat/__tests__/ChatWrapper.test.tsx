import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ChatWrapper } from '../ChatWrapper';
import type { DisplayMessage } from '@/lib/types/domain.types';

// Mock the message service
vi.mock('@/lib/services/messageService.client', () => ({
  createMessage: vi.fn(),
}));

// Mock the SealChecker component
vi.mock('@/components/seal/SealChecker', () => ({
  default: () => null,
}));

// Mock the ChatContainer component
vi.mock('../ChatContainer', () => ({
  ChatContainer: ({ onSendMessage, initialMessages }: { onSendMessage: (content: string, chapterId: string, userId: string) => Promise<void>; initialMessages: DisplayMessage[] }) => (
    <div data-testid="chat-container">
      <div data-testid="message-count">{initialMessages.length}</div>
      <button
        data-testid="mock-send-button"
        onClick={async () => {
          try {
            await onSendMessage('Test message', 'chapter-1', 'user-1');
          } catch {
            // Error is handled by ChatWrapper, just catch it here to prevent unhandled rejection
          }
        }}
      >
        Send
      </button>
    </div>
  ),
}));

describe('ChatWrapper Component', () => {
  const mockMessages: DisplayMessage[] = [
    {
      type: 'content',
      id: 'msg-1',
      content: 'Welcome message',
      order: 1,
    },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should render ChatContainer with initial messages', () => {
    render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    expect(screen.getByTestId('chat-container')).toBeDefined();
    expect(screen.getByTestId('message-count').textContent).toBe('1');
  });

  it('should handle successful message submission', async () => {
    const { createMessage } = await import('@/lib/services/messageService.client');
    vi.mocked(createMessage).mockResolvedValue({
      success: true,
      message: {
        id: 'new-msg',
        user_id: 'user-1',
        chapter_id: 'chapter-1',
        content: 'Test message',
        created_at: new Date().toISOString(),
      },
    });

    const user = userEvent.setup();
    render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    const sendButton = screen.getByTestId('mock-send-button');
    await user.click(sendButton);

    await waitFor(() => {
      expect(createMessage).toHaveBeenCalledWith('user-1', 'chapter-1', 'Test message');
    });

    // Should not show error
    expect(screen.queryByText(/erro/i)).toBeNull();
  });

  it('should display error message when submission fails', async () => {
    const { createMessage } = await import('@/lib/services/messageService.client');
    vi.mocked(createMessage).mockResolvedValue({
      success: false,
      error: 'Erro ao salvar mensagem. Tente novamente.',
    });

    const user = userEvent.setup();
    render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    const sendButton = screen.getByTestId('mock-send-button');
    await user.click(sendButton);

    await waitFor(() => {
      expect(screen.getByText(/erro ao salvar mensagem/i)).toBeDefined();
    });
  });

  it('should allow dismissing error message', async () => {
    const { createMessage } = await import('@/lib/services/messageService.client');
    vi.mocked(createMessage).mockResolvedValue({
      success: false,
      error: 'Erro ao salvar mensagem.',
    });

    const user = userEvent.setup();
    render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    // Trigger error
    const sendButton = screen.getByTestId('mock-send-button');
    await user.click(sendButton);

    await waitFor(() => {
      expect(screen.getByText(/erro ao salvar mensagem/i)).toBeDefined();
    });

    // Dismiss error
    const closeButton = screen.getByRole('button', { name: /fechar/i });
    await user.click(closeButton);

    await waitFor(() => {
      expect(screen.queryByText(/erro ao salvar mensagem/i)).toBeNull();
    });
  });

  it('should handle network errors with appropriate message', async () => {
    const { createMessage } = await import('@/lib/services/messageService.client');
    vi.mocked(createMessage).mockResolvedValue({
      success: false,
      error: 'Problema de conexão. Verifique sua internet e tente novamente.',
    });

    const user = userEvent.setup();
    render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    const sendButton = screen.getByTestId('mock-send-button');
    await user.click(sendButton);

    await waitFor(() => {
      expect(screen.getByText(/problema de conexão/i)).toBeDefined();
    });
  });

  it('should pass canSendMessage prop to ChatContainer', () => {
    const { rerender } = render(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={false}
      />
    );

    expect(screen.getByTestId('chat-container')).toBeDefined();

    rerender(
      <ChatWrapper
        initialMessages={mockMessages}
        currentChapterId="chapter-1"
        userId="user-1"
        canSendMessage={true}
      />
    );

    expect(screen.getByTestId('chat-container')).toBeDefined();
  });
});
