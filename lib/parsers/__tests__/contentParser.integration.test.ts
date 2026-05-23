/**
 * Content Parser Integration Tests
 * 
 * Tests integration between content parser and chapter service.
 * Verifies that the parser correctly handles real chapter data.
 * 
 * **Validates: Requirements 13.1, 13.2, 13.3, 13.6**
 */

import { describe, it, expect } from 'vitest';
import {
  parseChapter,
  validateChapterStructure,
  formatChapter,
  extractMessages,
} from '../contentParser';

describe('Content Parser Integration', () => {
  // Sample chapter data from seed-chapters.sql
  const sampleChapterContent = {
    messages: [
      { id: 'ch1-msg1', content: 'Você já se sentiu sozinho, mesmo cercado de pessoas?', order: 1, delay: 0 },
      { id: 'ch1-msg2', content: 'Como se ninguém realmente te conhecesse?', order: 2, delay: 2000 },
      { id: 'ch1-msg3', content: 'Essa sensação tem um nome: orfandade espiritual.', order: 3, delay: 3000 },
      { id: 'ch1-msg4', content: 'É o vazio de não conhecer o Pai que te criou.', order: 4, delay: 2000 },
      { id: 'ch1-msg5', content: 'Mas eu tenho uma notícia para você...', order: 5, delay: 3000 },
      { id: 'ch1-msg6', content: 'Você não está sozinho. Nunca esteve.', order: 6, delay: 2500 },
      { id: 'ch1-msg7', content: 'Há um Pai que te conhece pelo nome. Que te vê. Que te ama.', order: 7, delay: 3000 },
      { id: 'ch1-msg8', content: 'E esta jornada é sobre descobrir quem Ele é.', order: 8, delay: 2500 },
    ],
    metadata: { theme: 'spiritual_orphanhood', estimatedReadTime: 3 },
  };

  describe('parseChapter with real data', () => {
    it('should parse sample chapter content successfully', () => {
      const result = parseChapter(sampleChapterContent);

      expect(result.messages).toHaveLength(8);
      expect(result.metadata).toEqual({
        theme: 'spiritual_orphanhood',
        estimatedReadTime: 3,
      });
    });

    it('should preserve all message properties', () => {
      const result = parseChapter(sampleChapterContent);

      expect(result.messages[0]).toEqual({
        id: 'ch1-msg1',
        content: 'Você já se sentiu sozinho, mesmo cercado de pessoas?',
        order: 1,
        delay: 0,
      });

      expect(result.messages[1]).toEqual({
        id: 'ch1-msg2',
        content: 'Como se ninguém realmente te conhecesse?',
        order: 2,
        delay: 2000,
      });
    });
  });

  describe('validateChapterStructure with real data', () => {
    it('should validate sample chapter content as valid', () => {
      const result = validateChapterStructure(sampleChapterContent);

      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should detect invalid chapter content', () => {
      const invalidContent = {
        messages: [
          { id: 'msg1', content: 'Valid message', order: 1 },
          { id: 'msg1', content: 'Duplicate ID', order: 2 }, // Duplicate ID
        ],
      };

      const result = validateChapterStructure(invalidContent);

      expect(result.valid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
      expect(result.errors.some(e => e.message.includes('duplicado'))).toBe(true);
    });
  });

  describe('extractMessages with real data', () => {
    it('should extract messages in correct order', () => {
      const parsed = parseChapter(sampleChapterContent);
      const messages = extractMessages(parsed);

      expect(messages).toHaveLength(8);
      expect(messages[0].order).toBe(1);
      expect(messages[7].order).toBe(8);
    });

    it('should handle out-of-order messages', () => {
      const unorderedContent = {
        messages: [
          { id: 'msg3', content: 'Third', order: 3 },
          { id: 'msg1', content: 'First', order: 1 },
          { id: 'msg2', content: 'Second', order: 2 },
        ],
      };

      const parsed = parseChapter(unorderedContent);
      const messages = extractMessages(parsed);

      expect(messages[0].content).toBe('First');
      expect(messages[1].content).toBe('Second');
      expect(messages[2].content).toBe('Third');
    });
  });

  describe('round-trip with real data', () => {
    it('should maintain data integrity through parse -> format -> parse', () => {
      const parsed1 = parseChapter(sampleChapterContent);
      const formatted = formatChapter(parsed1);
      const parsed2 = parseChapter(formatted);

      expect(parsed2).toEqual(parsed1);
    });

    it('should handle chapter without metadata', () => {
      const contentWithoutMetadata = {
        messages: [
          { id: 'msg1', content: 'Single message', order: 1 },
        ],
      };

      const parsed1 = parseChapter(contentWithoutMetadata);
      const formatted = formatChapter(parsed1);
      const parsed2 = parseChapter(formatted);

      expect(parsed2).toEqual(parsed1);
    });
  });

  describe('error messages in Portuguese', () => {
    it('should provide Portuguese error for missing messages', () => {
      expect(() => parseChapter({})).toThrow('Conteúdo do capítulo deve conter um array de mensagens');
    });

    it('should provide Portuguese error for empty messages', () => {
      expect(() => parseChapter({ messages: [] })).toThrow('Capítulo deve conter pelo menos uma mensagem');
    });

    it('should provide Portuguese error for invalid message structure', () => {
      const invalidContent = {
        messages: [
          { content: 'Missing id', order: 1 },
        ],
      };

      expect(() => parseChapter(invalidContent)).toThrow('deve ter um campo "id" do tipo string');
    });

    it('should provide Portuguese error for duplicate IDs', () => {
      const invalidContent = {
        messages: [
          { id: 'msg1', content: 'First', order: 1 },
          { id: 'msg1', content: 'Duplicate', order: 2 },
        ],
      };

      expect(() => parseChapter(invalidContent)).toThrow('ID duplicado encontrado: "msg1"');
    });
  });

  describe('edge cases', () => {
    it('should handle messages with zero delay', () => {
      const content = {
        messages: [
          { id: 'msg1', content: 'Immediate', order: 1, delay: 0 },
        ],
      };

      const result = parseChapter(content);
      expect(result.messages[0].delay).toBe(0);
    });

    it('should handle large order numbers', () => {
      const content = {
        messages: [
          { id: 'msg1', content: 'Message', order: 1000 },
        ],
      };

      const result = parseChapter(content);
      expect(result.messages[0].order).toBe(1000);
    });

    it('should handle long message content', () => {
      const longContent = 'A'.repeat(1000);
      const content = {
        messages: [
          { id: 'msg1', content: longContent, order: 1 },
        ],
      };

      const result = parseChapter(content);
      expect(result.messages[0].content).toBe(longContent);
    });

    it('should handle special characters in content', () => {
      const content = {
        messages: [
          { id: 'msg1', content: 'Olá! Como você está? 😊 "Bem"', order: 1 },
        ],
      };

      const result = parseChapter(content);
      expect(result.messages[0].content).toBe('Olá! Como você está? 😊 "Bem"');
    });
  });
});
