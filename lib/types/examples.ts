/* eslint-disable @typescript-eslint/no-unused-vars */
/**
 * Type Usage Examples
 * 
 * This file demonstrates how to use the domain and database types
 * in various scenarios throughout the application.
 * 
 * Note: This file is for documentation purposes and is not imported
 * in the application code.
 */

import type {
  Chapter,
  ChapterContent,
  ChapterMessage,
  Message,
  UserProgress,
  Profile,
  JourneyProgress,
  DisplayMessage,
  ParsedChapter,
  ValidationResult,
  ServiceResult,
  SealConditions,
} from './domain.types';

import type { Database, Tables, Inserts, Updates } from './database.types';

// ============================================================================
// Example 1: Creating a Chapter
// ============================================================================

const exampleChapter: Chapter = {
  id: '550e8400-e29b-41d4-a716-446655440000',
  order_index: 1,
  title: 'Capítulo 1: A Orfandade Espiritual',
  content: {
    messages: [
      {
        id: 'msg-1',
        content: 'Você já se sentiu sozinho, mesmo cercado de pessoas?',
        order: 1,
        delay: 0,
      },
      {
        id: 'msg-2',
        content: 'Como se ninguém realmente te conhecesse?',
        order: 2,
        delay: 2000,
      },
      {
        id: 'msg-3',
        content: 'Essa sensação tem um nome: orfandade espiritual.',
        order: 3,
        delay: 3000,
      },
    ],
    metadata: {
      theme: 'spiritual_orphanhood',
      estimatedReadTime: 5,
    },
  },
  created_at: '2025-01-01T00:00:00Z',
  updated_at: '2025-01-01T00:00:00Z',
};

// ============================================================================
// Example 2: User Message
// ============================================================================

const exampleUserMessage: Message = {
  id: '660e8400-e29b-41d4-a716-446655440001',
  user_id: '770e8400-e29b-41d4-a716-446655440002',
  chapter_id: '550e8400-e29b-41d4-a716-446655440000',
  content: 'Sim, eu me identifico muito com essa sensação.',
  created_at: '2025-01-01T12:00:00Z',
};

// ============================================================================
// Example 3: Display Messages (Union Type)
// ============================================================================

const displayMessages: DisplayMessage[] = [
  {
    type: 'content',
    id: 'msg-1',
    content: 'Você já se sentiu sozinho?',
    order: 1,
  },
  {
    type: 'user',
    id: '660e8400-e29b-41d4-a716-446655440001',
    content: 'Sim, eu me identifico muito com essa sensação.',
    created_at: '2025-01-01T12:00:00Z',
  },
  {
    type: 'content',
    id: 'msg-2',
    content: 'Como se ninguém realmente te conhecesse?',
    order: 2,
  },
];

// ============================================================================
// Example 4: Journey Progress
// ============================================================================

const exampleJourneyProgress: JourneyProgress = {
  totalChapters: 10,
  completedChapters: 3,
  currentChapterIndex: 3,
  percentComplete: 30,
  chapters: [
    {
      chapter: exampleChapter,
      completed: true,
      unlocked: true,
      completedAt: '2025-01-01T12:00:00Z',
    },
    // ... more chapters
  ],
};

// ============================================================================
// Example 5: Service Function with ServiceResult
// ============================================================================

async function getChapterById(id: string): Promise<ServiceResult<Chapter>> {
  try {
    // Simulated database call
    const chapter = exampleChapter;
    
    if (!chapter) {
      return {
        data: null,
        error: {
          code: 'NOT_FOUND',
          message: 'Chapter not found',
          details: { chapterId: id },
        },
      };
    }
    
    return { data: chapter, error: null };
  } catch (err) {
    return {
      data: null,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to fetch chapter',
        details: { error: err },
      },
    };
  }
}

// ============================================================================
// Example 6: Content Validation
// ============================================================================

function validateChapterContent(content: unknown): ValidationResult {
  const errors: ValidationResult['errors'] = [];
  
  if (!content || typeof content !== 'object') {
    errors.push({
      field: 'content',
      message: 'Chapter content must be an object',
      received: typeof content,
    });
    return { valid: false, errors };
  }
  
  const chapterContent = content as Partial<ChapterContent>;
  
  if (!Array.isArray(chapterContent.messages)) {
    errors.push({
      field: 'messages',
      message: 'Chapter must contain a messages array',
      received: typeof chapterContent.messages,
    });
  }
  
  return {
    valid: errors.length === 0,
    errors,
  };
}

// ============================================================================
// Example 7: Database Insert Types
// ============================================================================

// Using Inserts type for creating new records
const newMessageInsert: Inserts<'messages'> = {
  user_id: '770e8400-e29b-41d4-a716-446655440002',
  chapter_id: '550e8400-e29b-41d4-a716-446655440000',
  content: 'This is a new message',
  // id and created_at are optional (have defaults)
};

// Using Updates type for updating records
const profileUpdate: Updates<'profiles'> = {
  seal_awarded: true,
  seal_awarded_at: new Date().toISOString(),
  seal_unlock_reason: 'first_message',
  // All fields are optional in Updates
};

// ============================================================================
// Example 8: Seal Conditions Check
// ============================================================================

async function checkSealConditions(userId: string): Promise<SealConditions> {
  // Simulated checks
  const completedAllChapters = false;
  const sentFirstMessage = true;
  
  return {
    journeyComplete: completedAllChapters,
    firstMessageSent: sentFirstMessage,
    shouldAward: completedAllChapters || sentFirstMessage,
  };
}

// ============================================================================
// Example 9: Type Guards
// ============================================================================

function isContentMessage(msg: DisplayMessage): msg is DisplayMessage & { type: 'content' } {
  return msg.type === 'content';
}

function isUserMessage(msg: DisplayMessage): msg is DisplayMessage & { type: 'user' } {
  return msg.type === 'user';
}

// Usage
displayMessages.forEach((msg) => {
  if (isContentMessage(msg)) {
    console.log(`Content message (order ${msg.order}): ${msg.content}`);
  } else if (isUserMessage(msg)) {
    console.log(`User message (${msg.created_at}): ${msg.content}`);
  }
});

// ============================================================================
// Example 10: Supabase Client with Types
// ============================================================================

// Example of how to use Database type with Supabase client
// (This would be in actual Supabase client code)

/*
import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Now all queries are fully typed
const { data, error } = await supabase
  .from('chapters')
  .select('*')
  .eq('order_index', 1)
  .single();

// data is typed as Tables<'chapters'> | null
*/

export {};
