# Message Submission Flow

## Architecture Overview

This document describes the complete flow of message submission from user input to database persistence.

## Component Hierarchy

```
app/(protected)/journey/page.tsx (Server Component)
    ↓ (passes initialMessages, userId, chapterId)
ChatWrapper (Client Component)
    ↓ (passes onSendMessage handler)
ChatContainer (Client Component)
    ↓ (passes onSendMessage callback)
MessageInput (Client Component)
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ User Types Message                                              │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ MessageInput Component                                          │
│ - Validates: not empty, not whitespace-only                     │
│ - Handles: Enter key, form submission                           │
│ - State: isSubmitting, message text                             │
└────────────────────────────┬────────────────────────────────────┘
                             ↓ calls onSendMessage(content)
┌─────────────────────────────────────────────────────────────────┐
│ ChatContainer Component                                         │
│ - Creates optimistic message with temp ID                       │
│ - Adds to local state immediately (optimistic update)           │
│ - Calls parent onSendMessage handler                            │
└────────────────────────────┬────────────────────────────────────┘
                             ↓ calls onSendMessage(content, chapterId, userId)
┌─────────────────────────────────────────────────────────────────┐
│ ChatWrapper Component                                           │
│ - Manages error state                                           │
│ - Calls message service                                         │
│ - Displays error banner if submission fails                     │
└────────────────────────────┬────────────────────────────────────┘
                             ↓ calls createMessage(userId, chapterId, content)
┌─────────────────────────────────────────────────────────────────┐
│ messageService.client                                           │
│ - Validates input (trim, check empty, check IDs)                │
│ - Creates Supabase client                                       │
│ - Inserts message to database                                   │
│ - Handles errors (network, database, validation)                │
└────────────────────────────┬────────────────────────────────────┘
                             ↓ INSERT INTO messages
┌─────────────────────────────────────────────────────────────────┐
│ Supabase Database                                               │
│ - messages table                                                │
│ - Row Level Security enforced                                   │
│ - Returns inserted message or error                             │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
                    ┌────────┴────────┐
                    ↓                 ↓
            ┌───────────────┐  ┌──────────────┐
            │   SUCCESS     │  │    ERROR     │
            └───────┬───────┘  └──────┬───────┘
                    ↓                 ↓
        ┌───────────────────┐  ┌──────────────────────┐
        │ Optimistic UI     │  │ Remove optimistic    │
        │ confirmed         │  │ message              │
        │                   │  │ Show error banner    │
        │ Message persisted │  │ User can retry       │
        └───────────────────┘  └──────────────────────┘
```

## Success Path

1. **User Input**: User types message in MessageInput
2. **Client Validation**: MessageInput validates (not empty/whitespace)
3. **Optimistic Update**: ChatContainer adds message to UI immediately
4. **Service Call**: ChatWrapper calls messageService.client.createMessage
5. **Database Insert**: Message inserted into Supabase messages table
6. **Confirmation**: Optimistic message remains in UI (already displayed)
7. **Auto-scroll**: Chat scrolls to show new message

## Error Path

1. **User Input**: User types message in MessageInput
2. **Client Validation**: MessageInput validates (not empty/whitespace)
3. **Optimistic Update**: ChatContainer adds message to UI immediately
4. **Service Call**: ChatWrapper calls messageService.client.createMessage
5. **Error Occurs**: Network error, database error, or validation error
6. **Error Handling**: 
   - messageService returns `{ success: false, error: "message" }`
   - ChatWrapper sets error state and re-throws
   - ChatContainer catches error and removes optimistic message
7. **User Feedback**: Error banner displayed at top of chat
8. **Recovery**: User can dismiss error and try again

## Error Messages

### Validation Errors
- **Empty Message**: "Mensagem não pode estar vazia."
- **Invalid Data**: "Dados inválidos para enviar mensagem."

### Network Errors
- **Connection Issue**: "Problema de conexão. Verifique sua internet e tente novamente."

### Database Errors
- **Insert Failed**: "Erro ao salvar mensagem. Tente novamente."
- **No Data Returned**: "Erro ao criar mensagem."

### Unexpected Errors
- **Unknown Error**: "Erro inesperado ao salvar mensagem."

## State Management

### MessageInput State
```typescript
{
  message: string;           // Current input text
  isSubmitting: boolean;     // Submission in progress
}
```

### ChatContainer State
```typescript
{
  messages: DisplayMessage[];  // All messages (content + user)
  isSubmitting: boolean;       // Submission in progress
}
```

### ChatWrapper State
```typescript
{
  error: string | null;        // Current error message
}
```

## Optimistic UI Updates

### Why Optimistic Updates?
- Provides immediate feedback to user
- Makes the app feel fast and responsive
- User doesn't wait for network round-trip

### How It Works
1. Message added to UI immediately with temporary ID
2. Database operation happens in background
3. On success: Keep the optimistic message (already displayed)
4. On error: Remove the optimistic message and show error

### Temporary ID Format
```typescript
`temp-${Date.now()}`  // e.g., "temp-1704067200000"
```

## Database Schema

### messages Table
```sql
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Row Level Security
```sql
-- Users can only insert their own messages
CREATE POLICY "Users can insert own messages"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only view their own messages
CREATE POLICY "Users can view own messages"
  ON public.messages FOR SELECT
  USING (auth.uid() = user_id);
```

## Type Definitions

### DisplayMessage (Union Type)
```typescript
type DisplayMessage = ContentDisplayMessage | UserDisplayMessage;

interface ContentDisplayMessage {
  type: 'content';
  id: string;
  content: string;
  order: number;
}

interface UserDisplayMessage {
  type: 'user';
  id: string;
  content: string;
  created_at: string;
}
```

### Message (Database Type)
```typescript
interface Message {
  id: string;
  user_id: string;
  chapter_id: string;
  content: string;
  created_at: string;
}
```

### MessageResult (Service Response)
```typescript
interface MessageResult {
  success: boolean;
  message?: Message;
  error?: string;
}
```

## Security Considerations

1. **Row Level Security**: Enforced at database level
   - Users can only insert messages with their own user_id
   - Users can only read their own messages

2. **Input Validation**: Multiple layers
   - Client-side: MessageInput validates before submission
   - Service layer: messageService validates before database call
   - Database: NOT NULL constraints and foreign key constraints

3. **Authentication**: Required for all operations
   - Middleware checks authentication before page loads
   - Supabase client uses authenticated session
   - Database policies check auth.uid()

4. **Content Sanitization**: 
   - Whitespace trimmed before storage
   - React automatically escapes content when rendering
   - No HTML allowed in message content

## Performance Considerations

1. **Optimistic Updates**: Immediate UI feedback without waiting for server
2. **Auto-scroll**: Smooth scroll to new messages
3. **Minimal Re-renders**: State updates only affect necessary components
4. **Database Indexes**: Messages indexed by user_id and chapter_id

## Future Enhancements

Potential improvements for future tasks:

1. **Real-time Updates**: Use Supabase subscriptions for live message updates
2. **Message Editing**: Allow users to edit their messages
3. **Message Deletion**: Allow users to delete their messages
4. **Character Limits**: Enforce maximum message length
5. **Rate Limiting**: Prevent spam by limiting messages per minute
6. **Offline Support**: Queue messages when offline, sync when online
7. **Rich Text**: Support for formatting (bold, italic, links)
8. **Attachments**: Support for images or files
9. **Reactions**: Allow users to react to messages
10. **Read Receipts**: Track when messages are read

## Testing Strategy

### Unit Tests
- MessageInput: Input validation, submission handling
- ChatContainer: Optimistic updates, error handling
- ChatWrapper: Error state management, service integration
- messageService.client: All error cases, validation logic

### Integration Tests
- Full message submission flow
- Error recovery scenarios
- Database persistence verification
- RLS policy enforcement

### E2E Tests
- User types and sends message
- Message appears in chat
- Message persists after page refresh
- Error handling with network issues

## Conclusion

The message submission flow is fully implemented with:
- ✅ Proper separation of concerns
- ✅ Optimistic UI updates for responsiveness
- ✅ Comprehensive error handling
- ✅ User-friendly error messages
- ✅ Security through RLS policies
- ✅ Type safety with TypeScript
- ✅ Clean architecture following established patterns
