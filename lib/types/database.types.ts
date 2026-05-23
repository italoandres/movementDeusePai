/**
 * Supabase Database Types
 * 
 * This file contains TypeScript types generated from the Supabase database schema.
 * 
 * To generate these types, run:
 * npx supabase gen types typescript --project-id <your-project-id> > lib/types/database.types.ts
 * 
 * Or if using local Supabase:
 * npx supabase gen types typescript --local > lib/types/database.types.ts
 * 
 * For now, we define the types manually based on the schema.
 */

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          created_at: string
          updated_at: string
          display_name: string | null
          seal_awarded: boolean
          seal_awarded_at: string | null
          seal_unlock_reason: 'journey_complete' | 'first_message' | null
        }
        Insert: {
          id: string
          created_at?: string
          updated_at?: string
          display_name?: string | null
          seal_awarded?: boolean
          seal_awarded_at?: string | null
          seal_unlock_reason?: 'journey_complete' | 'first_message' | null
        }
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          display_name?: string | null
          seal_awarded?: boolean
          seal_awarded_at?: string | null
          seal_unlock_reason?: 'journey_complete' | 'first_message' | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_id_fkey"
            columns: ["id"]
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      chapters: {
        Row: {
          id: string
          order_index: number
          title: string
          content: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          order_index: number
          title: string
          content: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          order_index?: number
          title?: string
          content?: Json
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_progress: {
        Row: {
          id: string
          user_id: string
          chapter_id: string
          completed: boolean
          completed_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          chapter_id: string
          completed?: boolean
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          chapter_id?: string
          completed?: boolean
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_progress_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_progress_chapter_id_fkey"
            columns: ["chapter_id"]
            referencedRelation: "chapters"
            referencedColumns: ["id"]
          }
        ]
      }
      messages: {
        Row: {
          id: string
          user_id: string
          chapter_id: string
          content: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          chapter_id: string
          content: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          chapter_id?: string
          content?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "messages_chapter_id_fkey"
            columns: ["chapter_id"]
            referencedRelation: "chapters"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

// Type helpers for easier access
export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row']
export type Inserts<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Insert']
export type Updates<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Update']

// Specific table types
export type Profile = Tables<'profiles'>
export type Chapter = Tables<'chapters'>
export type UserProgress = Tables<'user_progress'>
export type Message = Tables<'messages'>
