# Chapter Seed Data

## Overview

This directory contains the seed script for populating the `chapters` table with initial spiritual content following the "Carta de um Órfão" (Letter from an Orphan) theme.

## Files

- **`seed-chapters.sql`**: SQL script that inserts 5 chapters with emotionally compelling spiritual content

## Chapter Structure

Each chapter is stored as JSONB with the following structure:

```json
{
  "messages": [
    {
      "id": "unique-message-id",
      "content": "Message text content",
      "order": 1,
      "delay": 0
    }
  ],
  "metadata": {
    "theme": "chapter_theme",
    "estimatedReadTime": 5
  }
}
```

### Fields

- **`messages`**: Array of message objects that will be displayed sequentially in the chat interface
  - **`id`**: Unique identifier for the message
  - **`content`**: The text content to display
  - **`order`**: Sequential order for display (1, 2, 3, ...)
  - **`delay`**: Optional delay in milliseconds before displaying (for dramatic effect)

- **`metadata`**: Additional information about the chapter
  - **`theme`**: Thematic identifier for the chapter
  - **`estimatedReadTime`**: Estimated reading time in minutes

## Chapters Included

### 1. O Vazio que Você Sente (The Emptiness You Feel)
- **Theme**: Spiritual orphanhood
- **Messages**: 8
- **Focus**: Introducing the concept of spiritual emptiness and God as Father

### 2. A Busca por Pertencimento (The Search for Belonging)
- **Theme**: Belonging and identity
- **Messages**: 9
- **Focus**: Exploring the human need for belonging and identity as a child of God

### 3. O Pai que Você Não Conheceu (The Father You Never Knew)
- **Theme**: Healing father wounds
- **Messages**: 9
- **Focus**: Addressing pain from earthly fathers and introducing God as the perfect Father

### 4. O Convite para Casa (The Invitation Home)
- **Theme**: Prodigal son invitation
- **Messages**: 10
- **Focus**: Retelling the prodigal son story as a personal invitation to return to God

### 5. Você Faz Parte Agora (You Belong Now)
- **Theme**: Identity and belonging
- **Messages**: 11
- **Focus**: Affirming the reader's new identity and welcoming them to the movement

## How to Use

### Option 1: Using Supabase Dashboard

1. Log in to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `seed-chapters.sql`
4. Paste into the SQL Editor
5. Click "Run" to execute the script

### Option 2: Using Supabase CLI

```bash
# Make sure you're in the project root directory
supabase db reset  # This will reset the database and run migrations

# Or to run just the seed script:
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/seed-chapters.sql
```

### Option 3: Using psql with Connection String

```bash
psql "<your-supabase-connection-string>" -f supabase/seed-chapters.sql
```

## Verification

After running the seed script, you can verify the chapters were inserted correctly:

```sql
SELECT 
  order_index,
  title,
  jsonb_array_length(content->'messages') as message_count,
  content->'metadata'->>'theme' as theme,
  content->'metadata'->>'estimatedReadTime' as read_time
FROM public.chapters
ORDER BY order_index;
```

Expected output:

| order_index | title | message_count | theme | read_time |
|-------------|-------|---------------|-------|-----------|
| 1 | O Vazio que Você Sente | 8 | spiritual_orphanhood | 3 |
| 2 | A Busca por Pertencimento | 9 | belonging_and_identity | 4 |
| 3 | O Pai que Você Não Conheceu | 9 | healing_father_wounds | 4 |
| 4 | O Convite para Casa | 10 | prodigal_son_invitation | 5 |
| 5 | Você Faz Parte Agora | 11 | identity_and_belonging | 5 |

## Clearing Existing Data

If you need to clear existing chapters before seeding, uncomment this line in the seed script:

```sql
DELETE FROM public.chapters;
```

**Warning**: This will permanently delete all existing chapters and any associated user progress and messages due to CASCADE constraints.

## Customization

To add more chapters or modify existing ones:

1. Follow the same JSONB structure
2. Ensure `order_index` is unique and sequential
3. Keep message IDs unique across all chapters
4. Maintain the `order` field in messages for proper sequencing
5. Use `delay` values to create dramatic pauses between messages (optional)

## Requirements Satisfied

- **Requirement 1.1**: Content organized into discrete chapters ✓
- **Requirement 1.2**: Chapters structured with message arrays ✓
- **Task 6.3**: Seed initial chapter content in database ✓

## Related Files

- `schema.sql`: Database schema definition
- `validate-schema.sql`: Schema validation queries
- `lib/types/domain.types.ts`: TypeScript type definitions for chapters
- `lib/services/chapterService.ts`: Service layer for chapter operations
