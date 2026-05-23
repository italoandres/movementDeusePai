# Task 15 Implementation: Content Parser and Validator

## Overview

Implemented a comprehensive content parser and validator module for chapter content stored as JSONB in the database. The module provides parsing, validation, formatting, and message extraction functions with descriptive Portuguese error messages.

## Implementation Details

### Files Created

1. **`lib/parsers/contentParser.ts`** - Main parser module with 4 core functions
2. **`lib/parsers/__tests__/contentParser.test.ts`** - Unit tests (44 tests)
3. **`lib/parsers/__tests__/contentParser.integration.test.ts`** - Integration tests (16 tests)
4. **`lib/parsers/README.md`** - Documentation and usage guide

### Files Modified

1. **`lib/services/chapterService.ts`** - Updated to use new parser functions
2. **`scripts/validate-chapter-structure.ts`** - Updated to use new validator

## Core Functions

### 1. `parseChapter(rawContent: unknown): ChapterContent`

Parses and validates chapter content from raw JSONB data.

**Features:**
- Validates all required fields (id, content, order)
- Validates optional fields (delay, metadata)
- Checks for duplicate IDs and orders
- Throws descriptive Portuguese errors
- Type-safe parsing with TypeScript

**Example:**
```typescript
const parsed = parseChapter(rawContent);
// Returns: { messages: [...], metadata?: {...} }
```

### 2. `validateChapterStructure(rawContent: unknown): ValidationResult`

Validates chapter content without throwing exceptions.

**Features:**
- Returns all validation errors at once
- Provides field-level error details
- Includes received values in error objects
- Non-throwing validation for batch processing

**Example:**
```typescript
const result = validateChapterStructure(rawContent);
if (!result.valid) {
  result.errors.forEach(error => {
    console.error(`${error.field}: ${error.message}`);
  });
}
```

### 3. `formatChapter(parsed: ChapterContent): Record<string, unknown>`

Formats parsed content back to JSONB structure.

**Features:**
- Inverse of parseChapter
- Preserves all data including optional fields
- Omits empty metadata objects
- Ensures round-trip property

**Example:**
```typescript
const formatted = formatChapter(parsedContent);
// Store in database
```

### 4. `extractMessages(parsed: ChapterContent): ChapterMessage[]`

Extracts and sorts messages from parsed content.

**Features:**
- Returns messages sorted by order field
- Does not mutate original array
- Type-safe message extraction

**Example:**
```typescript
const messages = extractMessages(parsedContent);
// Returns messages in correct order
```

## Validation Rules

### Required Fields
- ✅ `messages` - Non-empty array
- ✅ `messages[].id` - Non-empty string, unique
- ✅ `messages[].content` - Non-empty string
- ✅ `messages[].order` - Non-negative integer, unique

### Optional Fields
- ✅ `messages[].delay` - Non-negative integer (if present)
- ✅ `metadata.theme` - String (if present)
- ✅ `metadata.estimatedReadTime` - Non-negative integer (if present)

### Data Integrity
- ✅ No duplicate message IDs
- ✅ No duplicate message orders
- ✅ All numbers are integers where specified
- ✅ No negative values for order or delay

## Error Messages (Portuguese)

All error messages are in Portuguese to match the application language:

- `"Conteúdo do capítulo deve ser um objeto válido"`
- `"Conteúdo do capítulo deve conter um array de mensagens"`
- `"O campo 'messages' deve ser um array"`
- `"Capítulo deve conter pelo menos uma mensagem"`
- `"Mensagem na posição X deve ter um campo 'id' do tipo string"`
- `"ID duplicado encontrado: 'msg1'"`
- `"Ordem duplicada encontrada: 0"`
- And more...

## Round-Trip Property

The parser guarantees data integrity through parse → format → parse cycles:

```typescript
const parsed1 = parseChapter(rawContent);
const formatted = formatChapter(parsed1);
const parsed2 = parseChapter(formatted);

// parsed2 equals parsed1 ✅
```

This ensures:
- No data loss during transformations
- Consistent data structure
- Safe database round-trips

## Integration

### Chapter Service

Updated `lib/services/chapterService.ts` to use the new parser:

```typescript
import { parseChapter, extractMessages } from '@/lib/parsers/contentParser';

// In getChapterMessages function
const parsedContent = parseChapter(chapter.content);
const messages = extractMessages(parsedContent);
```

**Benefits:**
- Consistent validation across the application
- Better error messages for debugging
- Type-safe content handling
- Automatic message sorting

### Validation Script

Updated `scripts/validate-chapter-structure.ts` to use the new validator:

```typescript
import { validateChapterStructure as validateContent } from '../lib/parsers/contentParser';

// Use parser for content validation
const contentValidation = validateContent(chapter.content);
```

**Benefits:**
- Reuses validation logic
- Consistent error messages
- Reduced code duplication

## Testing

### Unit Tests (44 tests)

**Coverage:**
- ✅ Valid content parsing
- ✅ Invalid content detection
- ✅ Error message validation
- ✅ Edge cases (empty strings, negative numbers, etc.)
- ✅ Optional field handling
- ✅ Duplicate detection
- ✅ Round-trip property

**Run:**
```bash
npm test -- lib/parsers/__tests__/contentParser.test.ts --run
```

### Integration Tests (16 tests)

**Coverage:**
- ✅ Real chapter data parsing
- ✅ Out-of-order message handling
- ✅ Portuguese error messages
- ✅ Edge cases (long content, special characters)
- ✅ Round-trip with real data

**Run:**
```bash
npm test -- lib/parsers/__tests__/contentParser.integration.test.ts --run
```

### Validation Script Test

**Run:**
```bash
npm run validate:chapters
```

**Output:**
```
✓ VALIDATION PASSED - No errors found
Total Chapters: 5
Total Messages: 47
Avg Messages/Chapter: 9.40
```

## Requirements Validation

**Task 15 validates the following requirements:**

- ✅ **13.1** - Parse chapter content from structured format
- ✅ **13.2** - Extract individual message blocks
- ✅ **13.3** - Validate chapter content structure
- ✅ **13.4** - Return descriptive error messages (in Portuguese)
- ✅ **13.6** - Round-trip property (parse → format → parse)

## Usage Examples

### Basic Parsing

```typescript
import { parseChapter } from '@/lib/parsers/contentParser';

try {
  const parsed = parseChapter(rawContent);
  console.log(`Parsed ${parsed.messages.length} messages`);
} catch (error) {
  console.error('Invalid content:', error.message);
}
```

### Validation Without Throwing

```typescript
import { validateChapterStructure } from '@/lib/parsers/contentParser';

const result = validateChapterStructure(rawContent);

if (!result.valid) {
  console.log('Validation errors:');
  result.errors.forEach(error => {
    console.log(`  ${error.field}: ${error.message}`);
  });
}
```

### Message Extraction

```typescript
import { parseChapter, extractMessages } from '@/lib/parsers/contentParser';

const parsed = parseChapter(rawContent);
const messages = extractMessages(parsed);

messages.forEach(msg => {
  console.log(`${msg.order}: ${msg.content}`);
});
```

### Formatting for Database

```typescript
import { formatChapter } from '@/lib/parsers/contentParser';

const formatted = formatChapter(parsedContent);
// Store formatted content in database
await supabase
  .from('chapters')
  .update({ content: formatted })
  .eq('id', chapterId);
```

## Benefits

1. **Type Safety** - Full TypeScript support with proper types
2. **Validation** - Comprehensive validation with descriptive errors
3. **Consistency** - Single source of truth for content validation
4. **Maintainability** - Well-tested, documented, and reusable
5. **Localization** - Error messages in Portuguese
6. **Data Integrity** - Round-trip property ensures no data loss
7. **Developer Experience** - Clear error messages and documentation

## Test Results

All tests passing:

```
✅ Unit Tests: 44/44 passed
✅ Integration Tests: 16/16 passed
✅ Validation Script: PASSED
✅ Total: 60/60 tests passed
```

## Documentation

Comprehensive documentation provided in:
- `lib/parsers/README.md` - Module documentation
- Inline JSDoc comments in source code
- Test files as usage examples

## Conclusion

Task 15 is complete with:
- ✅ All 4 required functions implemented
- ✅ Comprehensive validation with Portuguese error messages
- ✅ 60 tests passing (44 unit + 16 integration)
- ✅ Integration with existing services
- ✅ Full documentation
- ✅ Round-trip property verified
- ✅ All requirements validated (13.1, 13.2, 13.3, 13.4, 13.6)
