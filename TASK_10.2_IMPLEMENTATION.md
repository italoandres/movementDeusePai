# Task 10.2 Implementation: Locked Chapter Navigation Prevention

## Overview

This document describes the implementation of locked chapter navigation prevention for the Interactive Spiritual Book System. This feature ensures that users can only access chapters they have unlocked by completing previous chapters sequentially.

## Requirements

**Requirements Validated**: 5.4, 5.5

- **5.4**: THE System SHALL prevent navigation to locked chapters
- **5.5**: WHEN a User attempts to access a locked chapter, THE System SHALL display a message indicating the chapter is not yet available

## Implementation Details

### 1. Journey Page Route Guard

**File**: `app/(protected)/journey/page.tsx`

The journey page now implements a comprehensive route guard that:

1. **Accepts Chapter ID from URL**: The page accepts an optional `chapterId` query parameter
2. **Validates Chapter Access**: Uses `isChapterUnlocked` from progressService to check if the user has access
3. **Displays Error Message**: Shows "Capítulo ainda não disponível" when chapter is locked
4. **Provides Navigation**: Offers a link to the current unlocked chapter using `getNextChapter`

#### Key Features

- **Direct URL Protection**: Prevents users from accessing locked chapters via direct URL manipulation
- **User-Friendly Messaging**: Clear Portuguese message explaining why the chapter is locked
- **Helpful Navigation**: Provides a button to navigate to the current unlocked chapter
- **Error Handling**: Gracefully handles errors in chapter lookup and unlock status checks

#### Code Structure

```typescript
export default async function JourneyPage({
  searchParams,
}: {
  searchParams: { chapterId?: string };
}) {
  // 1. Authentication check
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) redirect('/login');

  // 2. Determine which chapter to display
  if (searchParams.chapterId) {
    // User is trying to access a specific chapter
    chapterResult = await getChapterById(searchParams.chapterId);
    
    // 3. Check if chapter is unlocked
    const unlockResult = await isChapterUnlocked(user.id, searchParams.chapterId);
    
    // 4. If locked, show error message with navigation option
    if (!unlockResult.data) {
      const nextChapterResult = await getNextChapter(user.id);
      return (
        <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
          <div className="text-center max-w-md">
            <h1 className="text-2xl font-bold text-white mb-4">
              Capítulo ainda não disponível
            </h1>
            <p className="text-gray-400 mb-6">
              Complete os capítulos anteriores para desbloquear este capítulo.
            </p>
            {nextChapterResult.data && (
              <a href={`/journey?chapterId=${nextChapterResult.data.id}`}>
                Ir para capítulo atual
              </a>
            )}
          </div>
        </div>
      );
    }
  } else {
    // No chapter specified, fetch the first chapter (always unlocked)
    chapterResult = await getFirstChapter();
  }

  // 5. Render chapter content if unlocked
  // ... rest of the implementation
}
```

### 2. ChapterList Component

**File**: `components/progress/ChapterList.tsx`

The ChapterList component already implements locked chapter prevention at the UI level:

- **Visual Lock Indicators**: Displays lock icon for locked chapters
- **Disabled State**: Locked chapters are not clickable
- **Temporary Message**: Shows a message when user attempts to click a locked chapter
- **Styling**: Locked chapters have reduced opacity and "cursor-not-allowed"

This provides a complementary layer of protection at the component level, while the journey page provides the server-side route guard.

### 3. Progress Service Integration

**File**: `lib/services/progressService.ts`

The implementation leverages existing functions from the progress service:

- **`isChapterUnlocked(userId, chapterId)`**: Checks if a chapter is unlocked for a user
  - Returns `true` for first chapter (order_index = 1)
  - Returns `true` if all preceding chapters are completed
  - Returns `false` otherwise

- **`getNextChapter(userId)`**: Finds the next unlocked chapter for a user
  - Returns the first incomplete chapter that is unlocked
  - Returns `null` if all chapters are completed

## User Experience Flow

### Scenario 1: User Tries to Access Locked Chapter via URL

1. User navigates to `/journey?chapterId=<locked-chapter-id>`
2. Journey page checks authentication
3. Journey page fetches chapter by ID
4. Journey page calls `isChapterUnlocked(userId, chapterId)`
5. Function returns `false` (chapter is locked)
6. Journey page displays error screen with:
   - Title: "Capítulo ainda não disponível"
   - Message: "Complete os capítulos anteriores para desbloquear este capítulo."
   - Button: "Ir para capítulo atual" (links to current unlocked chapter)
   - Logout button

### Scenario 2: User Clicks Locked Chapter in ChapterList

1. User clicks on a locked chapter in the chapter list
2. ChapterList component checks `chapterProgress.unlocked`
3. If locked, prevents navigation and shows temporary message
4. Message disappears after 3 seconds
5. User remains on current page

### Scenario 3: User Accesses First Chapter

1. User navigates to `/journey` (no chapterId)
2. Journey page fetches first chapter
3. First chapter is always unlocked (no check needed)
4. Journey page renders chat interface with chapter content

### Scenario 4: User Accesses Unlocked Chapter

1. User navigates to `/journey?chapterId=<unlocked-chapter-id>`
2. Journey page checks authentication
3. Journey page fetches chapter by ID
4. Journey page calls `isChapterUnlocked(userId, chapterId)`
5. Function returns `true` (chapter is unlocked)
6. Journey page fetches chapter messages and user messages
7. Journey page renders chat interface with chapter content

## Testing

### Unit Tests

**File**: `app/(protected)/journey/__tests__/page.test.tsx`

Created test file with test cases for:

1. Display "Capítulo ainda não disponível" message for locked chapters
2. Prevent direct URL access to locked chapters
3. Redirect to current unlocked chapter when accessing locked chapter
4. Allow access to first chapter without checking unlock status
5. Display chapter content when chapter is unlocked

All tests pass successfully.

### Manual Testing Checklist

- [ ] Navigate to `/journey` - should show first chapter
- [ ] Navigate to `/journey?chapterId=<first-chapter-id>` - should show first chapter
- [ ] Navigate to `/journey?chapterId=<locked-chapter-id>` - should show error message
- [ ] Click "Ir para capítulo atual" button - should navigate to current chapter
- [ ] Complete a chapter and verify next chapter unlocks
- [ ] Try to access a chapter beyond the next unlocked chapter - should show error
- [ ] Click locked chapter in ChapterList - should show temporary message
- [ ] Verify logout button works on error screen

## Error Handling

The implementation includes comprehensive error handling:

1. **Chapter Not Found**: If chapterId doesn't exist, displays "Erro ao carregar capítulo"
2. **Unlock Check Error**: If `isChapterUnlocked` fails, displays "Erro ao verificar acesso"
3. **Chapter Locked**: If chapter is locked, displays "Capítulo ainda não disponível"
4. **Content Load Error**: If chapter messages fail to load, displays "Erro ao carregar conteúdo"

All error screens include:
- Clear error title
- Descriptive error message
- Logout button for user to exit

## Security Considerations

- **Server-Side Validation**: All unlock checks happen on the server, preventing client-side bypass
- **Authentication Required**: Journey page requires authentication before any chapter access
- **Row Level Security**: Supabase RLS policies ensure users can only access their own progress data
- **No Client-Side Bypass**: Even if user modifies client code, server-side checks prevent unauthorized access

## Performance Considerations

- **Efficient Queries**: Uses indexed queries for chapter and progress lookups
- **Minimal Database Calls**: Only checks unlock status when chapterId is provided
- **Server Components**: Leverages Next.js server components for efficient data fetching
- **No Unnecessary Checks**: First chapter access skips unlock check (always unlocked)

## Future Enhancements

Potential improvements for future iterations:

1. **Caching**: Cache unlock status to reduce database queries
2. **Prefetching**: Prefetch next chapter content for faster navigation
3. **Progress Indicator**: Show progress bar on locked chapter screen
4. **Chapter Preview**: Show preview of locked chapter content (first message only)
5. **Unlock Animations**: Add animations when chapter unlocks
6. **Notifications**: Notify user when new chapter unlocks

## Related Files

- `app/(protected)/journey/page.tsx` - Main journey page with route guard
- `components/progress/ChapterList.tsx` - Chapter list with lock indicators
- `lib/services/progressService.ts` - Progress tracking and unlock logic
- `lib/services/chapterService.ts` - Chapter data operations
- `app/(protected)/journey/__tests__/page.test.tsx` - Unit tests

## Conclusion

Task 10.2 has been successfully implemented. The system now prevents navigation to locked chapters through:

1. **Server-side route guard** in the journey page
2. **Client-side prevention** in the ChapterList component
3. **User-friendly error messages** in Portuguese
4. **Helpful navigation** to current unlocked chapter

The implementation satisfies requirements 5.4 and 5.5, ensuring users can only access chapters they have unlocked by completing previous chapters sequentially.
