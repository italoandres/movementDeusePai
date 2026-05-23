# Content Parser Module

This module provides parsing, validation, and formatting functions for chapter content stored as JSONB in the database.

## Overview

Chapter content is stored in the database as JSONB with the following structure:

```typescript
{
  messages: [
    {
      id: string,
      content: string,
      order: number,
      delay?: number  // Optional delay in milliseconds
    }
  ],
  metadata?: {
    theme?: string,
    estimatedReadTime?: number  // In minutes
  }
}
```

## Functions

### `parseChapter(rawContent: unknown): ChapterContent`

Parses and validates chapter content from raw JSONB data.

**Parameters:**
- `rawContent` - Raw content object from database JSONB field

**Returns:**
- Parsed and validated `ChapterContent` object

**Throws:**
- `Error` with descriptive Portuguese message if content is invalid

**Example:**
```typescript
import { parseChapter } from '@/lib/parsers/contentParser';

try {
  const parsed = parseChapter(rawContent);
  console.log(`Parsed ${parsed.messages.length} messages`);
} catch (error) {
  console.error('Invalid content:', error.message);
}
```

### `validateChapterStructure(rawContent: unknown): ValidationResult`

Validates chapter content structure without throwing exceptions.

**Parameters:**
- `rawContent` - Raw content object to validate

**Returns:**
- `ValidationResult` object with:
  - `valid: boolean` - Whether the content is valid
  - `errors: ParseError[]` - Array of validation errors

**Example:**
```typescript
import { validateChapterStructure } from '@/lib/parsers/contentParser';

const result = validateChapterStructure(rawContent);

if (!result.valid) {
  result.errors.forEach(error => {
    console.error(`${error.field}: ${error.message}`);
  });
}
```

### `formatChapter(parsed: ChapterContent): Record<string, unknown>`

Formats parsed chapter content back to JSONB structure for database storage.

**Parameters:**
- `parsed` - Parsed `ChapterContent` object

**Returns:**
- Raw content object suitable for JSONB storage

**Example:**
```typescript
import { formatChapter } from '@/lib/parsers/contentParser';

const formatted = formatChapter(parsedContent);
// Store formatted content in database
```

### `extractMessages(parsed: ChapterContent): ChapterMessage[]`

Extracts and sorts message blocks from parsed chapter content.

**Parameters:**
- `parsed` - Parsed `ChapterContent` object

**Returns:**
- Array of `ChapterMessage` objects sorted by order field

**Example:**
```typescript
import { extractMessages } from '@/lib/parsers/contentParser';

const messages = extractMessages(parsedContent);
messages.forEach(msg => {
  console.log(`${msg.order}: ${msg.content}`);
});
```

## Validation Rules

The parser validates the following:

### Required Fields
- `messages` - Must be a non-empty array
- `messages[].id` - Must be a non-empty string
- `messages[].content` - Must be a non-empty string
- `messages[].order` - Must be a non-negative integer

### Optional Fields
- `messages[].delay` - If present, must be a non-negative integer
- `metadata.theme` - If present, must be a string
- `metadata.estimatedReadTime` - If present, must be a non-negative integer

### Uniqueness
- Message IDs must be unique within a chapter
- Message orders must be unique within a chapter

### Data Types
- All fields must match their expected types
- Numbers must be integers where specified
- No negative values for order or delay

## Error Messages

All error messages are in Portuguese to match the application's language:

- `"Conteúdo do capítulo deve ser um objeto válido"` - Content must be a valid object
- `"Conteúdo do capítulo deve conter um array de mensagens"` - Content must contain messages array
- `"Capítulo deve conter pelo menos uma mensagem"` - Chapter must have at least one message
- `"ID duplicado encontrado: \"msg1\""` - Duplicate ID found
- `"Ordem duplicada encontrada: 0"` - Duplicate order found
- And more...

## Round-Trip Property

The parser guarantees that parsing, formatting, and parsing again produces equivalent data:

```typescript
const parsed1 = parseChapter(rawContent);
const formatted = formatChapter(parsed1);
const parsed2 = parseChapter(formatted);

// parsed2 equals parsed1
```

This ensures data integrity when reading from and writing to the database.

## Integration with Chapter Service

The chapter service uses the content parser to validate and extract messages:

```typescript
import { parseChapter, extractMessages } from '@/lib/parsers/contentParser';

// In getChapterMessages function
const parsedContent = parseChapter(chapter.content);
const messages = extractMessages(parsedContent);
```

This provides:
- Consistent validation across the application
- Descriptive error messages in Portuguese
- Type-safe parsing with TypeScript
- Automatic message sorting by order

## Testing

The module includes comprehensive tests:

- **Unit tests** (`contentParser.test.ts`) - Test individual functions with various inputs
- **Integration tests** (`contentParser.integration.test.ts`) - Test with real chapter data

Run tests:
```bash
npm test -- lib/parsers/__tests__/contentParser.test.ts --run
npm test -- lib/parsers/__tests__/contentParser.integration.test.ts --run
```

## Requirements

**Validates Requirements:**
- 13.1 - Parse chapter content from structured format
- 13.2 - Extract individual message blocks
- 13.3 - Validate chapter content structure
- 13.4 - Return descriptive error messages
- 13.5 - Format parsed content into displayable blocks
- 13.6 - Round-trip property (parse → format → parse)
