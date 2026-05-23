# Chat Components

This directory contains the chat interface components for the Interactive Spiritual Book System.

## Components

### ChatContainer

Main chat wrapper component that manages state, message rendering, and auto-scroll behavior.

**Props:**
- `initialMessages: DisplayMessage[]` - Initial messages to display
- `currentChapterId: string` - ID of the current chapter
- `userId: string` - ID of the authenticated user
- `canSendMessage?: boolean` - Whether user can send messages (default: true)
- `onSendMessage: (content, chapterId, userId) => Promise<void>` - Callback for message submission

**Features:**
- Auto-scrolls to bottom when new messages arrive
- Optimistic UI updates for instant feedback
- Handles message submission state
- Responsive layout with max-width container

**Requirements:** 2.1, 2.2

### ContentMessage

Displays content messages (from chapters) with left-aligned styling.

**Props:**
- `message: ContentDisplayMessage` - Content message to display

**Features:**
- Left-aligned message bubble
- Dark gray background (bg-gray-800)
- Rounded corners with small top-left radius
- Fade-in animation
- Responsive width (85% mobile, 75% desktop)

**Requirements:** 2.3, 2.5, 3.2, 3.4

### UserMessage

Displays user-submitted messages with right-aligned styling.

**Props:**
- `message: UserDisplayMessage` - User message to display

**Features:**
- Right-aligned message bubble
- Indigo background (bg-indigo-600)
- Rounded corners with small top-right radius
- Timestamp display
- Fade-in animation
- Responsive width (85% mobile, 75% desktop)

**Requirements:** 2.3, 2.5, 3.2, 3.4

### MessageInput

Text input component with send button for message submission.

**Props:**
- `onSendMessage: (content: string) => Promise<void>` - Callback for message submission
- `disabled?: boolean` - Whether input is disabled
- `placeholder?: string` - Input placeholder text (default: "Escreva sua mensagem...")

**Features:**
- Enter key submission (Shift+Enter for new line)
- Input validation (no empty/whitespace-only messages)
- Disabled state during submission
- Auto-clearing after successful send
- Accessible with ARIA labels
- 44x44px minimum touch target size
- Auto-expanding textarea (up to 3 lines)

**Requirements:** 3.1

## Usage Example

```tsx
import { ChatContainer } from '@/components/chat';
import { DisplayMessage } from '@/lib/types/domain.types';

export default function JourneyPage() {
  const messages: DisplayMessage[] = [
    {
      type: 'content',
      id: '1',
      content: 'Você já se sentiu sozinho?',
      order: 1
    },
    {
      type: 'user',
      id: '2',
      content: 'Sim, muitas vezes.',
      created_at: new Date().toISOString()
    }
  ];

  const handleSendMessage = async (
    content: string, 
    chapterId: string, 
    userId: string
  ) => {
    // Call your message service to persist the message
    await messageService.createMessage(userId, chapterId, content);
  };

  return (
    <div className="h-screen">
      <ChatContainer
        initialMessages={messages}
        currentChapterId="chapter-1"
        userId="user-123"
        onSendMessage={handleSendMessage}
      />
    </div>
  );
}
```

## Styling

All components use:
- **Dark theme**: Black background with gray/indigo accents
- **Minimalist design**: Clean, distraction-free interface
- **Typography**: Base text size with relaxed line height
- **Responsive**: Mobile-first with tablet/desktop breakpoints
- **Animations**: Subtle fade-in for new messages

## Accessibility

- Semantic HTML structure
- ARIA labels on interactive elements
- Keyboard navigation support (Enter to send, Shift+Enter for new line)
- Minimum 44x44px touch targets
- Focus indicators on interactive elements
- Screen reader compatible

## Testing

Unit tests should cover:
- Message rendering (content and user messages)
- Input validation (empty/whitespace rejection)
- Enter key submission
- Disabled state behavior
- Auto-scroll functionality
- Optimistic UI updates

See the design document for property-based test specifications.
