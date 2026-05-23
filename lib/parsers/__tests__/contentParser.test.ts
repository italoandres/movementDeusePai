/**
 * Content Parser Tests
 * 
 * Unit tests for content parser and validator functions.
 * Tests parsing, validation, formatting, and message extraction.
 * 
 * **Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.6**
 */

import { describe, it, expect } from 'vitest';
import {
  parseChapter,
  validateChapterStructure,
  formatChapter,
  extractMessages,
} from '../contentParser';
import type { ChapterContent } from '@/lib/types/domain.types';

describe('parseChapter', () => {
  it('should parse valid chapter content with messages only', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
        { id: 'msg2', content: 'World', order: 1 },
      ],
    };

    const result = parseChapter(rawContent);

    expect(result).toEqual({
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
        { id: 'msg2', content: 'World', order: 1 },
      ],
    });
  });

  it('should parse valid chapter content with messages and metadata', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: 1000 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 5,
      },
    };

    const result = parseChapter(rawContent);

    expect(result).toEqual({
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: 1000 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 5,
      },
    });
  });

  it('should parse chapter with optional delay field', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0, delay: 500 },
        { id: 'msg2', content: 'Second', order: 1 },
      ],
    };

    const result = parseChapter(rawContent);

    expect(result.messages[0]).toHaveProperty('delay', 500);
    expect(result.messages[1]).not.toHaveProperty('delay');
  });

  it('should throw error for non-object content', () => {
    expect(() => parseChapter(null)).toThrow('Conteúdo do capítulo deve ser um objeto válido');
    expect(() => parseChapter('string')).toThrow('Conteúdo do capítulo deve ser um objeto válido');
    expect(() => parseChapter(123)).toThrow('Conteúdo do capítulo deve ser um objeto válido');
  });

  it('should throw error for missing messages array', () => {
    expect(() => parseChapter({})).toThrow('Conteúdo do capítulo deve conter um array de mensagens');
  });

  it('should throw error for non-array messages', () => {
    expect(() => parseChapter({ messages: 'not-array' })).toThrow('O campo "messages" deve ser um array');
  });

  it('should throw error for empty messages array', () => {
    expect(() => parseChapter({ messages: [] })).toThrow('Capítulo deve conter pelo menos uma mensagem');
  });

  it('should throw error for message without id', () => {
    const rawContent = {
      messages: [
        { content: 'Hello', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "id" do tipo string');
  });

  it('should throw error for message with non-string id', () => {
    const rawContent = {
      messages: [
        { id: 123, content: 'Hello', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "id" do tipo string');
  });

  it('should throw error for message with empty id', () => {
    const rawContent = {
      messages: [
        { id: '', content: 'Hello', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "id" do tipo string');
  });

  it('should throw error for message without content', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "content" do tipo string não vazio');
  });

  it('should throw error for message with empty content', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: '', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "content" do tipo string não vazio');
  });

  it('should throw error for message without order', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello' },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "order" do tipo número');
  });

  it('should throw error for message with non-number order', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: '0' },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um campo "order" do tipo número');
  });

  it('should throw error for message with negative order', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: -1 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um "order" que seja um número inteiro não negativo');
  });

  it('should throw error for message with non-integer order', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 1.5 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um "order" que seja um número inteiro não negativo');
  });

  it('should throw error for duplicate message IDs', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0 },
        { id: 'msg1', content: 'Second', order: 1 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('ID duplicado encontrado: "msg1"');
  });

  it('should throw error for duplicate message orders', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0 },
        { id: 'msg2', content: 'Second', order: 0 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('Ordem duplicada encontrada: 0');
  });

  it('should throw error for invalid delay type', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: '1000' },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('tem um campo "delay" inválido (deve ser número)');
  });

  it('should throw error for negative delay', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: -100 },
      ],
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ter um "delay" que seja um número inteiro não negativo');
  });

  it('should throw error for non-object metadata', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: 'invalid',
    };

    expect(() => parseChapter(rawContent)).toThrow('O campo "metadata" deve ser um objeto');
  });

  it('should throw error for invalid metadata.theme type', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {
        theme: 123,
      },
    };

    expect(() => parseChapter(rawContent)).toThrow('O campo "metadata.theme" deve ser uma string');
  });

  it('should throw error for invalid metadata.estimatedReadTime type', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {
        estimatedReadTime: '5',
      },
    };

    expect(() => parseChapter(rawContent)).toThrow('O campo "metadata.estimatedReadTime" deve ser um número');
  });

  it('should throw error for negative metadata.estimatedReadTime', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {
        estimatedReadTime: -5,
      },
    };

    expect(() => parseChapter(rawContent)).toThrow('deve ser um número inteiro não negativo');
  });
});

describe('validateChapterStructure', () => {
  it('should return valid for correct chapter content', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
        { id: 'msg2', content: 'World', order: 1 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 5,
      },
    };

    const result = validateChapterStructure(rawContent);

    expect(result.valid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('should return errors for non-object content', () => {
    const result = validateChapterStructure(null);

    expect(result.valid).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0]).toMatchObject({
      field: 'content',
      message: 'Conteúdo do capítulo deve ser um objeto válido',
    });
  });

  it('should return errors for missing messages', () => {
    const result = validateChapterStructure({});

    expect(result.valid).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0]).toMatchObject({
      field: 'messages',
      message: 'Conteúdo do capítulo deve conter um array de mensagens',
    });
  });

  it('should return errors for non-array messages', () => {
    const result = validateChapterStructure({ messages: 'not-array' });

    expect(result.valid).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0]).toMatchObject({
      field: 'messages',
      message: 'O campo "messages" deve ser um array',
    });
  });

  it('should return errors for empty messages array', () => {
    const result = validateChapterStructure({ messages: [] });

    expect(result.valid).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0]).toMatchObject({
      field: 'messages',
      message: 'Capítulo deve conter pelo menos uma mensagem',
    });
  });

  it('should return multiple errors for invalid messages', () => {
    const rawContent = {
      messages: [
        { content: 'Missing id', order: 0 },
        { id: 'msg2', order: 1 }, // Missing content
      ],
    };

    const result = validateChapterStructure(rawContent);

    expect(result.valid).toBe(false);
    expect(result.errors.length).toBeGreaterThan(1);
    expect(result.errors.some(e => e.field === 'messages[0].id')).toBe(true);
    expect(result.errors.some(e => e.field === 'messages[1].content')).toBe(true);
  });

  it('should return errors for duplicate IDs', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0 },
        { id: 'msg1', content: 'Second', order: 1 },
      ],
    };

    const result = validateChapterStructure(rawContent);

    expect(result.valid).toBe(false);
    expect(result.errors.some(e => e.message.includes('ID duplicado'))).toBe(true);
  });

  it('should return errors for duplicate orders', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0 },
        { id: 'msg2', content: 'Second', order: 0 },
      ],
    };

    const result = validateChapterStructure(rawContent);

    expect(result.valid).toBe(false);
    expect(result.errors.some(e => e.message.includes('Ordem duplicada'))).toBe(true);
  });

  it('should return errors for invalid metadata', () => {
    const rawContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {
        theme: 123,
        estimatedReadTime: 'invalid',
      },
    };

    const result = validateChapterStructure(rawContent);

    expect(result.valid).toBe(false);
    expect(result.errors.some(e => e.field === 'metadata.theme')).toBe(true);
    expect(result.errors.some(e => e.field === 'metadata.estimatedReadTime')).toBe(true);
  });
});

describe('formatChapter', () => {
  it('should format chapter content with messages only', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
        { id: 'msg2', content: 'World', order: 1 },
      ],
    };

    const result = formatChapter(parsed);

    expect(result).toEqual({
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
        { id: 'msg2', content: 'World', order: 1 },
      ],
    });
  });

  it('should format chapter content with messages and metadata', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: 1000 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 5,
      },
    };

    const result = formatChapter(parsed);

    expect(result).toEqual({
      messages: [
        { id: 'msg1', content: 'Hello', order: 0, delay: 1000 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 5,
      },
    });
  });

  it('should format chapter with optional delay field', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'First', order: 0, delay: 500 },
        { id: 'msg2', content: 'Second', order: 1 },
      ],
    };

    const result = formatChapter(parsed);

    expect(result.messages[0]).toHaveProperty('delay', 500);
    expect(result.messages[1]).not.toHaveProperty('delay');
  });

  it('should not include metadata if empty', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {},
    };

    const result = formatChapter(parsed);

    expect(result).not.toHaveProperty('metadata');
  });

  it('should include partial metadata', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'Hello', order: 0 },
      ],
      metadata: {
        theme: 'Introduction',
      },
    };

    const result = formatChapter(parsed);

    expect(result.metadata).toEqual({ theme: 'Introduction' });
  });
});

describe('extractMessages', () => {
  it('should extract messages in order', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg2', content: 'Second', order: 1 },
        { id: 'msg1', content: 'First', order: 0 },
        { id: 'msg3', content: 'Third', order: 2 },
      ],
    };

    const result = extractMessages(parsed);

    expect(result).toHaveLength(3);
    expect(result[0].order).toBe(0);
    expect(result[1].order).toBe(1);
    expect(result[2].order).toBe(2);
    expect(result[0].content).toBe('First');
    expect(result[1].content).toBe('Second');
    expect(result[2].content).toBe('Third');
  });

  it('should not mutate original messages array', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg2', content: 'Second', order: 1 },
        { id: 'msg1', content: 'First', order: 0 },
      ],
    };

    const originalOrder = parsed.messages.map(m => m.order);
    extractMessages(parsed);

    expect(parsed.messages.map(m => m.order)).toEqual(originalOrder);
  });

  it('should handle single message', () => {
    const parsed: ChapterContent = {
      messages: [
        { id: 'msg1', content: 'Only', order: 0 },
      ],
    };

    const result = extractMessages(parsed);

    expect(result).toHaveLength(1);
    expect(result[0]).toEqual({ id: 'msg1', content: 'Only', order: 0 });
  });
});

describe('round-trip property', () => {
  it('should maintain data integrity through parse -> format -> parse cycle', () => {
    const original = {
      messages: [
        { id: 'msg1', content: 'First message', order: 0, delay: 1000 },
        { id: 'msg2', content: 'Second message', order: 1 },
        { id: 'msg3', content: 'Third message', order: 2, delay: 500 },
      ],
      metadata: {
        theme: 'Introduction',
        estimatedReadTime: 10,
      },
    };

    // Parse -> Format -> Parse
    const parsed1 = parseChapter(original);
    const formatted = formatChapter(parsed1);
    const parsed2 = parseChapter(formatted);

    expect(parsed2).toEqual(parsed1);
  });

  it('should maintain data integrity for minimal content', () => {
    const original = {
      messages: [
        { id: 'msg1', content: 'Single message', order: 0 },
      ],
    };

    const parsed1 = parseChapter(original);
    const formatted = formatChapter(parsed1);
    const parsed2 = parseChapter(formatted);

    expect(parsed2).toEqual(parsed1);
  });

  it('should maintain data integrity with partial metadata', () => {
    const original = {
      messages: [
        { id: 'msg1', content: 'Message', order: 0 },
      ],
      metadata: {
        theme: 'Test Theme',
      },
    };

    const parsed1 = parseChapter(original);
    const formatted = formatChapter(parsed1);
    const parsed2 = parseChapter(formatted);

    expect(parsed2).toEqual(parsed1);
  });
});
