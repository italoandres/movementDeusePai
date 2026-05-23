/**
 * Content Parser and Validator
 * 
 * Provides parsing, validation, and formatting functions for chapter content.
 * Chapter content is stored as JSONB in the database with structure:
 * { messages: [...], metadata: {...} }
 * 
 * Requirements: 13.1, 13.2, 13.3, 13.4, 13.6
 */

import type {
  ChapterContent,
  ChapterMessage,
  ChapterMetadata,
  ValidationResult,
  ParseError,
} from '@/lib/types/domain.types';

/**
 * Parse chapter content from raw JSONB data
 * 
 * Parses and validates chapter content structure. Returns parsed content
 * if valid, or throws an error with descriptive message if invalid.
 * 
 * @param rawContent - Raw content object from database JSONB field
 * @returns Parsed and validated ChapterContent
 * @throws Error with descriptive Portuguese message if content is invalid
 * 
 * **Validates: Requirements 13.1, 13.2**
 */
export function parseChapter(rawContent: unknown): ChapterContent {
  // Validate that rawContent is an object
  if (!rawContent || typeof rawContent !== 'object') {
    throw new Error('Conteúdo do capítulo deve ser um objeto válido');
  }

  const content = rawContent as Record<string, unknown>;

  // Validate messages array exists
  if (!('messages' in content)) {
    throw new Error('Conteúdo do capítulo deve conter um array de mensagens');
  }

  if (!Array.isArray(content.messages)) {
    throw new Error('O campo "messages" deve ser um array');
  }

  // Parse and validate each message
  const messages: ChapterMessage[] = [];
  const seenIds = new Set<string>();
  const seenOrders = new Set<number>();

  for (let i = 0; i < content.messages.length; i++) {
    const msg = content.messages[i];

    if (!msg || typeof msg !== 'object') {
      throw new Error(`Mensagem na posição ${i} deve ser um objeto válido`);
    }

    const message = msg as Record<string, unknown>;

    // Validate required fields
    if (!('id' in message) || typeof message.id !== 'string' || !message.id) {
      throw new Error(`Mensagem na posição ${i} deve ter um campo "id" do tipo string`);
    }

    if (!('content' in message) || typeof message.content !== 'string' || !message.content) {
      throw new Error(`Mensagem na posição ${i} deve ter um campo "content" do tipo string não vazio`);
    }

    if (!('order' in message) || typeof message.order !== 'number') {
      throw new Error(`Mensagem na posição ${i} deve ter um campo "order" do tipo número`);
    }

    // Validate order is a positive integer
    if (!Number.isInteger(message.order) || message.order < 0) {
      throw new Error(`Mensagem na posição ${i} deve ter um "order" que seja um número inteiro não negativo`);
    }

    // Check for duplicate IDs
    if (seenIds.has(message.id)) {
      throw new Error(`ID duplicado encontrado: "${message.id}"`);
    }
    seenIds.add(message.id);

    // Check for duplicate orders
    if (seenOrders.has(message.order)) {
      throw new Error(`Ordem duplicada encontrada: ${message.order}`);
    }
    seenOrders.add(message.order);

    // Validate optional delay field
    let delay: number | undefined;
    if ('delay' in message) {
      if (typeof message.delay !== 'number') {
        throw new Error(`Mensagem na posição ${i} tem um campo "delay" inválido (deve ser número)`);
      }
      if (!Number.isInteger(message.delay) || message.delay < 0) {
        throw new Error(`Mensagem na posição ${i} deve ter um "delay" que seja um número inteiro não negativo`);
      }
      delay = message.delay;
    }

    messages.push({
      id: message.id,
      content: message.content,
      order: message.order,
      ...(delay !== undefined && { delay }),
    });
  }

  // Validate at least one message exists
  if (messages.length === 0) {
    throw new Error('Capítulo deve conter pelo menos uma mensagem');
  }

  // Parse optional metadata
  let metadata: ChapterMetadata | undefined;
  if ('metadata' in content && content.metadata) {
    if (typeof content.metadata !== 'object') {
      throw new Error('O campo "metadata" deve ser um objeto');
    }

    const meta = content.metadata as Record<string, unknown>;
    metadata = {};

    if ('theme' in meta) {
      if (typeof meta.theme !== 'string') {
        throw new Error('O campo "metadata.theme" deve ser uma string');
      }
      metadata.theme = meta.theme;
    }

    if ('estimatedReadTime' in meta) {
      if (typeof meta.estimatedReadTime !== 'number') {
        throw new Error('O campo "metadata.estimatedReadTime" deve ser um número');
      }
      if (!Number.isInteger(meta.estimatedReadTime) || meta.estimatedReadTime < 0) {
        throw new Error('O campo "metadata.estimatedReadTime" deve ser um número inteiro não negativo');
      }
      metadata.estimatedReadTime = meta.estimatedReadTime;
    }
  }

  return {
    messages,
    ...(metadata && { metadata }),
  };
}

/**
 * Validate chapter content structure
 * 
 * Validates chapter content and returns a detailed validation result
 * with all errors found. Does not throw exceptions.
 * 
 * @param rawContent - Raw content object to validate
 * @returns ValidationResult with valid flag and array of errors
 * 
 * **Validates: Requirements 13.3, 13.4**
 */
export function validateChapterStructure(rawContent: unknown): ValidationResult {
  const errors: ParseError[] = [];

  // Validate that rawContent is an object
  if (!rawContent || typeof rawContent !== 'object') {
    errors.push({
      field: 'content',
      message: 'Conteúdo do capítulo deve ser um objeto válido',
      received: typeof rawContent,
    });
    return { valid: false, errors };
  }

  const content = rawContent as Record<string, unknown>;

  // Validate messages array exists
  if (!('messages' in content)) {
    errors.push({
      field: 'messages',
      message: 'Conteúdo do capítulo deve conter um array de mensagens',
      received: undefined,
    });
    return { valid: false, errors };
  }

  if (!Array.isArray(content.messages)) {
    errors.push({
      field: 'messages',
      message: 'O campo "messages" deve ser um array',
      received: typeof content.messages,
    });
    return { valid: false, errors };
  }

  // Validate at least one message exists
  if (content.messages.length === 0) {
    errors.push({
      field: 'messages',
      message: 'Capítulo deve conter pelo menos uma mensagem',
      received: 0,
    });
  }

  // Validate each message
  const seenIds = new Set<string>();
  const seenOrders = new Set<number>();

  for (let i = 0; i < content.messages.length; i++) {
    const msg = content.messages[i];

    if (!msg || typeof msg !== 'object') {
      errors.push({
        field: `messages[${i}]`,
        message: `Mensagem na posição ${i} deve ser um objeto válido`,
        received: typeof msg,
      });
      continue;
    }

    const message = msg as Record<string, unknown>;

    // Validate id field
    if (!('id' in message)) {
      errors.push({
        field: `messages[${i}].id`,
        message: `Mensagem na posição ${i} deve ter um campo "id"`,
        received: undefined,
      });
    } else if (typeof message.id !== 'string') {
      errors.push({
        field: `messages[${i}].id`,
        message: `Mensagem na posição ${i} deve ter um campo "id" do tipo string`,
        received: typeof message.id,
      });
    } else if (!message.id) {
      errors.push({
        field: `messages[${i}].id`,
        message: `Mensagem na posição ${i} deve ter um "id" não vazio`,
        received: message.id,
      });
    } else {
      // Check for duplicate IDs
      if (seenIds.has(message.id)) {
        errors.push({
          field: `messages[${i}].id`,
          message: `ID duplicado encontrado: "${message.id}"`,
          received: message.id,
        });
      }
      seenIds.add(message.id);
    }

    // Validate content field
    if (!('content' in message)) {
      errors.push({
        field: `messages[${i}].content`,
        message: `Mensagem na posição ${i} deve ter um campo "content"`,
        received: undefined,
      });
    } else if (typeof message.content !== 'string') {
      errors.push({
        field: `messages[${i}].content`,
        message: `Mensagem na posição ${i} deve ter um campo "content" do tipo string`,
        received: typeof message.content,
      });
    } else if (!message.content) {
      errors.push({
        field: `messages[${i}].content`,
        message: `Mensagem na posição ${i} deve ter um "content" não vazio`,
        received: message.content,
      });
    }

    // Validate order field
    if (!('order' in message)) {
      errors.push({
        field: `messages[${i}].order`,
        message: `Mensagem na posição ${i} deve ter um campo "order"`,
        received: undefined,
      });
    } else if (typeof message.order !== 'number') {
      errors.push({
        field: `messages[${i}].order`,
        message: `Mensagem na posição ${i} deve ter um campo "order" do tipo número`,
        received: typeof message.order,
      });
    } else if (!Number.isInteger(message.order) || message.order < 0) {
      errors.push({
        field: `messages[${i}].order`,
        message: `Mensagem na posição ${i} deve ter um "order" que seja um número inteiro não negativo`,
        received: message.order,
      });
    } else {
      // Check for duplicate orders
      if (seenOrders.has(message.order)) {
        errors.push({
          field: `messages[${i}].order`,
          message: `Ordem duplicada encontrada: ${message.order}`,
          received: message.order,
        });
      }
      seenOrders.add(message.order);
    }

    // Validate optional delay field
    if ('delay' in message) {
      if (typeof message.delay !== 'number') {
        errors.push({
          field: `messages[${i}].delay`,
          message: `Mensagem na posição ${i} tem um campo "delay" inválido (deve ser número)`,
          received: typeof message.delay,
        });
      } else if (!Number.isInteger(message.delay) || message.delay < 0) {
        errors.push({
          field: `messages[${i}].delay`,
          message: `Mensagem na posição ${i} deve ter um "delay" que seja um número inteiro não negativo`,
          received: message.delay,
        });
      }
    }
  }

  // Validate optional metadata
  if ('metadata' in content && content.metadata !== undefined) {
    if (typeof content.metadata !== 'object' || content.metadata === null) {
      errors.push({
        field: 'metadata',
        message: 'O campo "metadata" deve ser um objeto',
        received: typeof content.metadata,
      });
    } else {
      const meta = content.metadata as Record<string, unknown>;

      if ('theme' in meta && typeof meta.theme !== 'string') {
        errors.push({
          field: 'metadata.theme',
          message: 'O campo "metadata.theme" deve ser uma string',
          received: typeof meta.theme,
        });
      }

      if ('estimatedReadTime' in meta) {
        if (typeof meta.estimatedReadTime !== 'number') {
          errors.push({
            field: 'metadata.estimatedReadTime',
            message: 'O campo "metadata.estimatedReadTime" deve ser um número',
            received: typeof meta.estimatedReadTime,
          });
        } else if (!Number.isInteger(meta.estimatedReadTime) || meta.estimatedReadTime < 0) {
          errors.push({
            field: 'metadata.estimatedReadTime',
            message: 'O campo "metadata.estimatedReadTime" deve ser um número inteiro não negativo',
            received: meta.estimatedReadTime,
          });
        }
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Format parsed chapter content back to JSONB structure
 * 
 * Converts parsed ChapterContent back to the raw JSONB format
 * for storage in the database. This function is the inverse of parseChapter.
 * 
 * Round-trip property: formatChapter(parseChapter(x)) should equal x
 * 
 * @param parsed - Parsed ChapterContent object
 * @returns Raw content object suitable for JSONB storage
 * 
 * **Validates: Requirements 13.5, 13.6**
 */
export function formatChapter(parsed: ChapterContent): Record<string, unknown> {
  const formatted: Record<string, unknown> = {
    messages: parsed.messages.map(msg => {
      const formattedMsg: Record<string, unknown> = {
        id: msg.id,
        content: msg.content,
        order: msg.order,
      };

      if (msg.delay !== undefined) {
        formattedMsg.delay = msg.delay;
      }

      return formattedMsg;
    }),
  };

  if (parsed.metadata) {
    const formattedMeta: Record<string, unknown> = {};

    if (parsed.metadata.theme !== undefined) {
      formattedMeta.theme = parsed.metadata.theme;
    }

    if (parsed.metadata.estimatedReadTime !== undefined) {
      formattedMeta.estimatedReadTime = parsed.metadata.estimatedReadTime;
    }

    // Only include metadata if it has properties
    if (Object.keys(formattedMeta).length > 0) {
      formatted.metadata = formattedMeta;
    }
  }

  return formatted;
}

/**
 * Extract message blocks from parsed chapter content
 * 
 * Extracts and returns the messages array from parsed chapter content,
 * sorted by order field.
 * 
 * @param parsed - Parsed ChapterContent object
 * @returns Array of ChapterMessage objects sorted by order
 * 
 * **Validates: Requirements 13.2**
 */
export function extractMessages(parsed: ChapterContent): ChapterMessage[] {
  return [...parsed.messages].sort((a, b) => a.order - b.order);
}
