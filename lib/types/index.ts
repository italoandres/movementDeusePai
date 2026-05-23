/**
 * Type Exports
 * 
 * Central export point for all type definitions used in the application.
 */

// Domain types
export type {
  Profile,
  Chapter,
  ChapterContent,
  ChapterMessage,
  ChapterMetadata,
  UserProgress,
  Message,
  JourneyProgress,
  ChapterProgress,
  DisplayMessage,
  ContentDisplayMessage,
  UserDisplayMessage,
  ParsedChapter,
  ValidationResult,
  ParseError,
  ServiceResult,
  ServiceError,
  SealUnlockReason,
  SealConditions,
} from './domain.types';

// Database types
export type {
  Database,
  Json,
  Tables,
  Inserts,
  Updates,
} from './database.types';

// Re-export specific database table types with DB prefix to avoid conflicts
export type {
  Profile as DBProfile,
  Chapter as DBChapter,
  UserProgress as DBUserProgress,
  Message as DBMessage,
} from './database.types';
