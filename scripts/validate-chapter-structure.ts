/**
 * Chapter Structure Validator
 * 
 * This script validates that chapter content follows the expected JSONB structure
 * without requiring a database connection. It can be used during development
 * to verify chapter data before seeding.
 */

import type { ChapterContent, ChapterMessage } from '../lib/types/domain.types';
import { validateChapterStructure as validateContent } from '../lib/parsers/contentParser';

interface ValidationError {
  chapter: number;
  field: string;
  message: string;
}

interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: string[];
  summary: {
    totalChapters: number;
    totalMessages: number;
    avgMessagesPerChapter: number;
  };
}

// Sample chapter data extracted from seed-chapters.sql
const chapters = [
  {
    order_index: 1,
    title: 'O Vazio que Você Sente',
    content: {
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
    },
  },
  {
    order_index: 2,
    title: 'A Busca por Pertencimento',
    content: {
      messages: [
        { id: 'ch2-msg1', content: 'Quantas vezes você tentou preencher esse vazio?', order: 1, delay: 0 },
        { id: 'ch2-msg2', content: 'Com relacionamentos, conquistas, reconhecimento...', order: 2, delay: 2500 },
        { id: 'ch2-msg3', content: 'Mas nada parece ser suficiente, não é?', order: 3, delay: 2000 },
        { id: 'ch2-msg4', content: 'Porque esse vazio não é sobre o que você faz.', order: 4, delay: 3000 },
        { id: 'ch2-msg5', content: 'É sobre quem você é.', order: 5, delay: 2000 },
        { id: 'ch2-msg6', content: 'Você foi criado para pertencer a alguém.', order: 6, delay: 3000 },
        { id: 'ch2-msg7', content: 'Para ser filho. Para ser filha.', order: 7, delay: 2500 },
        { id: 'ch2-msg8', content: 'E há um Pai esperando para te receber de braços abertos.', order: 8, delay: 3500 },
        { id: 'ch2-msg9', content: 'Não porque você merece. Mas porque Ele te ama.', order: 9, delay: 3000 },
      ],
      metadata: { theme: 'belonging_and_identity', estimatedReadTime: 4 },
    },
  },
  {
    order_index: 3,
    title: 'O Pai que Você Não Conheceu',
    content: {
      messages: [
        { id: 'ch3-msg1', content: 'Talvez a palavra "Pai" traga dor para você.', order: 1, delay: 0 },
        { id: 'ch3-msg2', content: 'Talvez seu pai terreno tenha falhado. Ou nunca esteve presente.', order: 2, delay: 3000 },
        { id: 'ch3-msg3', content: 'E agora é difícil confiar em qualquer figura paterna.', order: 3, delay: 2500 },
        { id: 'ch3-msg4', content: 'Eu entendo.', order: 4, delay: 2000 },
        { id: 'ch3-msg5', content: 'Mas preciso te contar sobre um Pai diferente.', order: 5, delay: 2500 },
        { id: 'ch3-msg6', content: 'Um Pai que nunca falha. Que nunca abandona. Que nunca decepciona.', order: 6, delay: 3500 },
        { id: 'ch3-msg7', content: 'Ele não é como os pais imperfeitos que conhecemos.', order: 7, delay: 2500 },
        { id: 'ch3-msg8', content: 'Ele é o Pai perfeito que seu coração sempre desejou.', order: 8, delay: 3000 },
        { id: 'ch3-msg9', content: 'E Ele está chamando você de volta para casa.', order: 9, delay: 3000 },
      ],
      metadata: { theme: 'healing_father_wounds', estimatedReadTime: 4 },
    },
  },
  {
    order_index: 4,
    title: 'O Convite para Casa',
    content: {
      messages: [
        { id: 'ch4-msg1', content: 'Há uma história antiga sobre um filho que se perdeu.', order: 1, delay: 0 },
        { id: 'ch4-msg2', content: 'Ele pegou sua herança e foi embora. Desperdiçou tudo.', order: 2, delay: 2500 },
        { id: 'ch4-msg3', content: 'Quando não tinha mais nada, ele decidiu voltar para casa.', order: 3, delay: 3000 },
        { id: 'ch4-msg4', content: 'Envergonhado. Com medo. Preparado para ser rejeitado.', order: 4, delay: 2500 },
        { id: 'ch4-msg5', content: 'Mas sabe o que aconteceu?', order: 5, delay: 2000 },
        { id: 'ch4-msg6', content: 'O pai viu o filho de longe. E correu.', order: 6, delay: 3000 },
        { id: 'ch4-msg7', content: 'Correu para abraçá-lo. Para restaurá-lo. Para celebrá-lo.', order: 7, delay: 3000 },
        { id: 'ch4-msg8', content: 'Essa história é sobre você.', order: 8, delay: 2500 },
        { id: 'ch4-msg9', content: 'Não importa o quão longe você foi. Deus está esperando você voltar.', order: 9, delay: 3500 },
        { id: 'ch4-msg10', content: 'E quando você der o primeiro passo, Ele correrá ao seu encontro.', order: 10, delay: 3500 },
      ],
      metadata: { theme: 'prodigal_son_invitation', estimatedReadTime: 5 },
    },
  },
  {
    order_index: 5,
    title: 'Você Faz Parte Agora',
    content: {
      messages: [
        { id: 'ch5-msg1', content: 'Se você chegou até aqui, algo mudou em você.', order: 1, delay: 0 },
        { id: 'ch5-msg2', content: 'Você não é mais um órfão espiritual.', order: 2, delay: 2500 },
        { id: 'ch5-msg3', content: 'Você é filho. Você é filha.', order: 3, delay: 2000 },
        { id: 'ch5-msg4', content: 'Você tem um Pai que te conhece, te ama, te escolheu.', order: 4, delay: 3000 },
        { id: 'ch5-msg5', content: 'E agora você faz parte de algo maior.', order: 5, delay: 2500 },
        { id: 'ch5-msg6', content: 'Um movimento de pessoas que descobriram essa verdade.', order: 6, delay: 3000 },
        { id: 'ch5-msg7', content: 'Pessoas que podem dizer com confiança:', order: 7, delay: 2500 },
        { id: 'ch5-msg8', content: '"Deus é Pai."', order: 8, delay: 2000 },
        { id: 'ch5-msg9', content: 'Não apenas uma ideia. Mas uma realidade vivida.', order: 9, delay: 3000 },
        { id: 'ch5-msg10', content: 'Bem-vindo à família.', order: 10, delay: 2500 },
        { id: 'ch5-msg11', content: 'Você não está mais sozinho.', order: 11, delay: 3000 },
      ],
      metadata: { theme: 'identity_and_belonging', estimatedReadTime: 5 },
    },
  },
];

function validateChapterStructure(chapters: any[]): ValidationResult {
  const errors: ValidationError[] = [];
  const warnings: string[] = [];
  let totalMessages = 0;

  // Track message IDs for duplicate detection across all chapters
  const allMessageIds = new Set<string>();

  chapters.forEach((chapter, index) => {
    const chapterNum = chapter.order_index;

    // Validate required fields
    if (!chapter.title || typeof chapter.title !== 'string') {
      errors.push({
        chapter: chapterNum,
        field: 'title',
        message: 'Title is required and must be a string',
      });
    }

    if (!chapter.content) {
      errors.push({
        chapter: chapterNum,
        field: 'content',
        message: 'Content is required',
      });
      return;
    }

    // Use the content parser to validate chapter structure
    const contentValidation = validateContent(chapter.content);
    
    if (!contentValidation.valid) {
      // Convert parser errors to validation errors
      contentValidation.errors.forEach(parseError => {
        errors.push({
          chapter: chapterNum,
          field: parseError.field,
          message: parseError.message,
        });
      });
    }

    const content = chapter.content as ChapterContent;

    // Additional validations beyond basic structure
    if (Array.isArray(content.messages)) {
      totalMessages += content.messages.length;

      // Check for duplicate message IDs across all chapters
      content.messages.forEach((msg: ChapterMessage, msgIndex: number) => {
        if (msg.id) {
          if (allMessageIds.has(msg.id)) {
            errors.push({
              chapter: chapterNum,
              field: `content.messages[${msgIndex}].id`,
              message: `Duplicate message ID across chapters: ${msg.id}`,
            });
          }
          allMessageIds.add(msg.id);
        }

        // Check order continuity (warning only)
        if (msg.order !== msgIndex + 1) {
          warnings.push(
            `Chapter ${chapterNum}, message ${msgIndex + 1}: order field (${msg.order}) doesn't match position (${msgIndex + 1})`
          );
        }
      });
    }

    // Validate metadata (warnings only)
    if (!content.metadata) {
      warnings.push(`Chapter ${chapterNum}: metadata is missing (optional but recommended)`);
    } else {
      if (!content.metadata.theme) {
        warnings.push(`Chapter ${chapterNum}: metadata.theme is missing`);
      }
      if (!content.metadata.estimatedReadTime) {
        warnings.push(`Chapter ${chapterNum}: metadata.estimatedReadTime is missing`);
      }
    }

    // Check order_index continuity
    if (chapter.order_index !== index + 1) {
      errors.push({
        chapter: chapterNum,
        field: 'order_index',
        message: `order_index (${chapter.order_index}) doesn't match expected position (${index + 1})`,
      });
    }
  });

  return {
    valid: errors.length === 0,
    errors,
    warnings,
    summary: {
      totalChapters: chapters.length,
      totalMessages,
      avgMessagesPerChapter: totalMessages / chapters.length,
    },
  };
}

// Run validation
const result = validateChapterStructure(chapters);

console.log('='.repeat(80));
console.log('CHAPTER STRUCTURE VALIDATION REPORT');
console.log('='.repeat(80));
console.log();

console.log('Summary:');
console.log(`  Total Chapters: ${result.summary.totalChapters}`);
console.log(`  Total Messages: ${result.summary.totalMessages}`);
console.log(`  Avg Messages/Chapter: ${result.summary.avgMessagesPerChapter.toFixed(2)}`);
console.log();

if (result.valid) {
  console.log('✓ VALIDATION PASSED - No errors found');
} else {
  console.log('✗ VALIDATION FAILED - Errors found:');
  console.log();
  result.errors.forEach((error) => {
    console.log(`  Chapter ${error.chapter} - ${error.field}:`);
    console.log(`    ${error.message}`);
  });
}

if (result.warnings.length > 0) {
  console.log();
  console.log('Warnings:');
  result.warnings.forEach((warning) => {
    console.log(`  ⚠ ${warning}`);
  });
}

console.log();
console.log('='.repeat(80));

// Exit with error code if validation failed
process.exit(result.valid ? 0 : 1);
