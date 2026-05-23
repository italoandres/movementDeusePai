# Task 6.3 Implementation: Seed Initial Chapter Content

## Overview

This document describes the implementation of Task 6.3: "Seed initial chapter content in database" from the livro-interativo-espiritual spec.

## Requirements Satisfied

- **Requirement 1.1**: Content organized into discrete chapters ✓
- **Requirement 1.2**: Chapters structured with message arrays ✓
- **Task 6.3**: Seed initial chapter content in database ✓

## Files Created

### 1. `supabase/seed-chapters.sql`

SQL script that inserts 5 chapters with emotionally compelling spiritual content following the "Carta de um Órfão" (Letter from an Orphan) theme about discovering God as Father.

**Structure:**
- Each chapter is stored as JSONB with a `messages` array and `metadata` object
- Messages include `id`, `content`, `order`, and optional `delay` fields
- Metadata includes `theme` and `estimatedReadTime` fields

**Chapters:**

1. **O Vazio que Você Sente** (The Emptiness You Feel)
   - 8 messages
   - Theme: spiritual_orphanhood
   - Introduces the concept of spiritual emptiness

2. **A Busca por Pertencimento** (The Search for Belonging)
   - 9 messages
   - Theme: belonging_and_identity
   - Explores the human need for belonging

3. **O Pai que Você Não Conheceu** (The Father You Never Knew)
   - 9 messages
   - Theme: healing_father_wounds
   - Addresses pain from earthly fathers

4. **O Convite para Casa** (The Invitation Home)
   - 10 messages
   - Theme: prodigal_son_invitation
   - Retells the prodigal son story

5. **Você Faz Parte Agora** (You Belong Now)
   - 11 messages
   - Theme: identity_and_belonging
   - Affirms new identity and belonging

**Total:** 47 messages across 5 chapters

### 2. `supabase/SEED_README.md`

Comprehensive documentation for using the seed script, including:
- Chapter structure explanation
- Usage instructions (Supabase Dashboard, CLI, psql)
- Verification queries
- Customization guidelines

### 3. `supabase/validate-seed.sql`

SQL validation script with 10 comprehensive checks:
1. Chapter count verification
2. Sequential order validation
3. JSONB structure validation
4. Message structure validation
5. Detailed chapter summary
6. Message content preview
7. Duplicate message ID detection
8. Message order continuity check
9. Content statistics
10. Theme distribution

### 4. `scripts/validate-chapter-structure.ts`

TypeScript validation script that validates chapter structure locally without requiring a database connection. Checks:
- Required fields (title, content, messages)
- Message structure (id, content, order, delay)
- Duplicate message IDs
- Order continuity
- Metadata presence

### 5. Updated `package.json`

Added new script:
```json
"validate:chapters": "tsx scripts/validate-chapter-structure.ts"
```

## JSONB Structure

Each chapter follows this structure:

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

### Field Descriptions

- **`messages`**: Array of message objects displayed sequentially
  - **`id`**: Unique identifier (e.g., "ch1-msg1")
  - **`content`**: Text content to display
  - **`order`**: Sequential order (1, 2, 3, ...)
  - **`delay`**: Optional delay in milliseconds for dramatic effect

- **`metadata`**: Additional chapter information
  - **`theme`**: Thematic identifier
  - **`estimatedReadTime`**: Reading time in minutes

## Usage Instructions

### Option 1: Supabase Dashboard

1. Log in to Supabase project dashboard
2. Navigate to SQL Editor
3. Copy contents of `supabase/seed-chapters.sql`
4. Paste and click "Run"

### Option 2: Supabase CLI

```bash
supabase db reset  # Resets database and runs migrations
```

### Option 3: psql

```bash
psql "<connection-string>" -f supabase/seed-chapters.sql
```

## Validation

### Local Validation (No Database Required)

```bash
npm run validate:chapters
```

**Output:**
```
================================================================================
CHAPTER STRUCTURE VALIDATION REPORT
================================================================================

Summary:
  Total Chapters: 5
  Total Messages: 47
  Avg Messages/Chapter: 9.40

✓ VALIDATION PASSED - No errors found

================================================================================
```

### Database Validation (After Seeding)

```bash
psql "<connection-string>" -f supabase/validate-seed.sql
```

This runs 10 comprehensive validation checks on the seeded data.

## Content Theme: "Carta de um Órfão"

The chapters follow a narrative arc about discovering God as Father:

1. **Recognition** - Identifying spiritual emptiness
2. **Understanding** - Recognizing the search for belonging
3. **Healing** - Addressing father wounds
4. **Invitation** - Receiving the call to return home
5. **Identity** - Embracing new identity as a child of God

Each chapter uses emotionally compelling language designed to create an intimate, conversational experience through the chat interface.

## Design Decisions

### Message Delays

Optional `delay` fields (in milliseconds) create dramatic pauses between messages, enhancing the conversational feel:
- Short delays (2000ms): Natural conversation flow
- Medium delays (2500-3000ms): Emphasis and reflection
- Long delays (3500ms): Major emotional beats

### Message Count

Chapters range from 8-11 messages, providing:
- Sufficient content for meaningful engagement
- Manageable reading sessions (3-5 minutes)
- Natural conversation rhythm

### Unique Message IDs

Format: `ch{chapter}-msg{number}` (e.g., "ch1-msg1")
- Ensures uniqueness across all chapters
- Easy to identify and debug
- Consistent naming convention

## Integration with Existing Code

The seed data integrates with:

1. **`lib/types/domain.types.ts`**
   - `Chapter` interface
   - `ChapterContent` interface
   - `ChapterMessage` interface
   - `ChapterMetadata` interface

2. **`lib/services/chapterService.ts`**
   - `getAllChapters()` - Retrieves seeded chapters
   - `getChapterById()` - Retrieves specific chapter
   - `getChapterMessages()` - Parses chapter content

3. **`supabase/schema.sql`**
   - `chapters` table with JSONB content column
   - Indexes for performance
   - RLS policies for access control

## Testing

### Validation Results

✓ All 5 chapters created successfully
✓ All 47 messages structured correctly
✓ No duplicate message IDs
✓ Sequential order maintained
✓ JSONB structure valid
✓ Metadata present and valid

### Manual Testing Checklist

- [ ] Run seed script in Supabase
- [ ] Verify 5 chapters inserted
- [ ] Check message count (47 total)
- [ ] Validate JSONB structure
- [ ] Test chapter retrieval via API
- [ ] Verify messages display in correct order
- [ ] Test delay values (if implementing sequential display)

## Next Steps

After seeding the database:

1. **Task 6.4** (Optional): Write property test for chapter ordering
2. **Task 6.5** (Optional): Write property test for chapter rendering
3. **Task 7**: Build chat interface components
4. **Task 11**: Integrate chapters into journey page

## Notes

- The seed script includes a commented-out `DELETE` statement for clearing existing chapters
- Uncomment with caution as it will delete all chapters and cascade to user progress and messages
- The validation script can be run before seeding to verify structure
- Message delays are optional and can be implemented in the UI layer

## Conclusion

Task 6.3 is complete. The seed script provides 5 emotionally compelling chapters with 47 messages total, structured as JSONB with proper validation and documentation. The content follows the "Carta de um Órfão" theme and is ready to be seeded into the Supabase database.
