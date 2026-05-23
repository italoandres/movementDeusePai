# Type Definitions

This directory contains TypeScript type definitions for the Interactive Spiritual Book System.

## Files

### `domain.types.ts`
Application-level domain types that represent business logic entities. These types include:

- **Profile**: User profile with seal award information
- **Chapter**: Chapter content structure with messages
- **UserProgress**: User's progress through chapters
- **Message**: User-submitted messages
- **JourneyProgress**: Aggregated view of user's journey
- **DisplayMessage**: Union type for content and user messages
- **ParsedChapter**: Parsed chapter structure
- **ValidationResult**: Content validation results

### `database.types.ts`
Supabase database types generated from the database schema. These types match the actual database tables and are used for database operations.

### `index.ts`
Central export point for all types. Import types from here in your application code.

## Usage

### Importing Types

```typescript
// Import domain types
import type { Chapter, Message, JourneyProgress } from '@/lib/types';

// Import database types
import type { Database, Tables } from '@/lib/types';

// Import specific database table types
import type { DBProfile, DBChapter } from '@/lib/types';
```

### Domain Types vs Database Types

- **Domain Types** (`domain.types.ts`): Use these in your application logic, components, and services. They include computed properties and display-specific fields.

- **Database Types** (`database.types.ts`): Use these when interacting directly with Supabase. They match the exact database schema.

Example:
```typescript
// Service layer - use domain types
export async function getChapterById(id: string): Promise<Chapter | null> {
  // Database query returns database type
  const { data, error } = await supabase
    .from('chapters')
    .select('*')
    .eq('id', id)
    .single();
  
  if (error || !data) return null;
  
  // Transform to domain type
  return {
    ...data,
    content: data.content as ChapterContent, // Type assertion for JSONB
  };
}
```

## Generating Database Types

The database types in `database.types.ts` should be regenerated whenever the database schema changes.

### Using Local Supabase

If you're running Supabase locally:

```bash
npm run types:generate
```

This runs: `npx supabase gen types typescript --local > lib/types/database.types.ts`

### Using Remote Supabase

If you're using a remote Supabase project:

```bash
npx supabase gen types typescript --project-id <your-project-id> > lib/types/database.types.ts
```

Replace `<your-project-id>` with your actual Supabase project ID.

### Prerequisites

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase (for remote projects):
   ```bash
   supabase login
   ```

3. Link your project (for remote projects):
   ```bash
   supabase link --project-ref <your-project-id>
   ```

## Type Safety Best Practices

1. **Always use types for function parameters and return values**
   ```typescript
   async function createMessage(
     userId: string,
     chapterId: string,
     content: string
   ): Promise<Message> {
     // Implementation
   }
   ```

2. **Use type guards for runtime validation**
   ```typescript
   function isChapterContent(value: unknown): value is ChapterContent {
     return (
       typeof value === 'object' &&
       value !== null &&
       'messages' in value &&
       Array.isArray((value as ChapterContent).messages)
     );
   }
   ```

3. **Prefer domain types in application code**
   ```typescript
   // Good
   function renderChapter(chapter: Chapter) { }
   
   // Avoid (unless directly interacting with database)
   function renderChapter(chapter: Tables<'chapters'>) { }
   ```

4. **Use ServiceResult for error handling**
   ```typescript
   async function fetchData(): Promise<ServiceResult<Chapter>> {
     try {
       const data = await getChapter();
       return { data, error: null };
     } catch (err) {
       return {
         data: null,
         error: {
           code: 'FETCH_ERROR',
           message: 'Failed to fetch chapter',
         },
       };
     }
   }
   ```

## Related Documentation

- [Database Schema](../../supabase/schema.sql)
- [Design Document](.kiro/specs/livro-interativo-espiritual/design.md)
- [Requirements Document](.kiro/specs/livro-interativo-espiritual/requirements.md)
