/**
 * Domain Types for Interactive Spiritual Book System
 * 
 * These types define the core domain models used throughout the application.
 * They are based on the database schema but include additional computed properties
 * and display-specific types.
 */

// ============================================================================
// User Profile (Schema Unificado)
// ============================================================================

export interface Profile {
  id: string;
  nome: string;
  username: string | null;
  email: string;
  avatar_url: string | null;
  bio: string | null;
  perfil_is_complete: boolean;
  senha_is_seted: boolean;
  total_seals: number;
  current_chapter: number;
  created_at: string;
  updated_at: string;
  last_seen: string | null;
}

// ============================================================================
// Chapter (Schema Unificado)
// ============================================================================

export interface Chapter {
  id: string;
  chapter_number: number;
  title: string;
  subtitle: string | null;
  content: string; // TEXT field containing chapter content
  summary: string | null;
  required_seals: number;
  unlock_condition: string | null;
  estimated_time: number | null;
  difficulty: 'easy' | 'medium' | 'hard' | null;
  created_at: string;
  updated_at: string;
}

export interface ChapterContent {
  messages: ChapterMessage[];
  metadata?: ChapterMetadata;
}

export interface ChapterMessage {
  id: string;
  content: string;
  order: number;
  delay?: number; // Optional delay in milliseconds for sequential display
}

export interface ChapterMetadata {
  theme?: string;
  estimatedReadTime?: number; // In minutes
}

// ============================================================================
// User Progress (Schema Unificado)
// ============================================================================

export interface UserProgress {
  id: string;
  user_id: string;
  chapter_id: string;
  status: 'locked' | 'unlocked' | 'in_progress' | 'completed';
  progress_percentage: number;
  time_spent: number; // seconds
  notes: string | null;
  bookmarks: unknown; // JSONB
  started_at: string | null;
  completed_at: string | null;
  last_accessed_at: string;
}

// ============================================================================
// User Message (Schema Unificado - usando tabela messages)
// ============================================================================

export interface Message {
  id: string;
  chat_id: string;
  sender_id: string;
  content: string | null;
  media_url: string | null;
  media_type: 'text' | 'image' | 'video' | 'audio';
  reply_to_id: string | null;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

// ============================================================================
// Seals (Schema Unificado)
// ============================================================================

export interface Seal {
  id: string;
  code: string;
  name: string;
  description: string | null;
  icon_url: string | null;
  category: 'chapter' | 'achievement' | 'special' | 'chat';
  required_chapter: number | null;
  unlock_condition: string | null;
  unlocks_feature: string | null;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  points: number;
  created_at: string;
}

export interface UserSeal {
  id: string;
  user_id: string;
  seal_id: string;
  unlocked_at: string;
  source: string | null;
}

// ============================================================================
// Aggregated Progress View
// ============================================================================

export interface JourneyProgress {
  totalChapters: number;
  completedChapters: number;
  currentChapterIndex: number;
  percentComplete: number;
  chapters: ChapterProgress[];
}

export interface ChapterProgress {
  chapter: Chapter;
  completed: boolean;
  unlocked: boolean;
  completedAt: string | null;
}

// ============================================================================
// Message Display Types
// ============================================================================

export type DisplayMessage = ContentDisplayMessage | UserDisplayMessage;

export interface ContentDisplayMessage {
  type: 'content';
  id: string;
  content: string;
  order: number;
}

export interface UserDisplayMessage {
  type: 'user';
  id: string;
  content: string;
  created_at: string;
}

// ============================================================================
// Content Parser Types
// ============================================================================

export interface ParsedChapter {
  id: string;
  title: string;
  messages: ChapterMessage[];
  metadata: ChapterMetadata;
}

export interface ValidationResult {
  valid: boolean;
  errors: ParseError[];
}

export interface ParseError {
  field: string;
  message: string;
  received?: unknown;
}

// ============================================================================
// Service Response Types
// ============================================================================

export interface ServiceResult<T> {
  data: T | null;
  error: ServiceError | null;
}

export interface ServiceError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// ============================================================================
// Seal Award Types
// ============================================================================

export type SealUnlockReason = 'journey_complete' | 'first_message';

export interface SealConditions {
  journeyComplete: boolean;
  firstMessageSent: boolean;
  shouldAward: boolean;
}
