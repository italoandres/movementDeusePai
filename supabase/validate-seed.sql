-- ============================================================================
-- Seed Data Validation Script
-- ============================================================================
-- This script validates that the chapter seed data was inserted correctly
-- and conforms to the expected structure.
--
-- Run this after executing seed-chapters.sql to verify the data.
-- ============================================================================

-- ============================================================================
-- 1. Check Chapter Count
-- ============================================================================
SELECT 
  'Chapter Count Check' as test_name,
  COUNT(*) as actual_count,
  5 as expected_count,
  CASE 
    WHEN COUNT(*) = 5 THEN '✓ PASS'
    ELSE '✗ FAIL'
  END as status
FROM public.chapters;

-- ============================================================================
-- 2. Check Sequential Order
-- ============================================================================
SELECT 
  'Sequential Order Check' as test_name,
  COUNT(*) as chapters_with_correct_order,
  5 as expected_count,
  CASE 
    WHEN COUNT(*) = 5 THEN '✓ PASS'
    ELSE '✗ FAIL'
  END as status
FROM (
  SELECT 
    order_index,
    ROW_NUMBER() OVER (ORDER BY order_index) as expected_index
  FROM public.chapters
) subquery
WHERE order_index = expected_index;

-- ============================================================================
-- 3. Check JSONB Structure
-- ============================================================================
SELECT 
  'JSONB Structure Check' as test_name,
  COUNT(*) as chapters_with_valid_structure,
  5 as expected_count,
  CASE 
    WHEN COUNT(*) = 5 THEN '✓ PASS'
    ELSE '✗ FAIL'
  END as status
FROM public.chapters
WHERE 
  content ? 'messages' 
  AND content ? 'metadata'
  AND jsonb_typeof(content->'messages') = 'array'
  AND jsonb_typeof(content->'metadata') = 'object';

-- ============================================================================
-- 4. Check Message Structure
-- ============================================================================
SELECT 
  'Message Structure Check' as test_name,
  COUNT(*) as valid_messages,
  (SELECT SUM(jsonb_array_length(content->'messages')) FROM public.chapters) as total_messages,
  CASE 
    WHEN COUNT(*) = (SELECT SUM(jsonb_array_length(content->'messages')) FROM public.chapters) 
    THEN '✓ PASS'
    ELSE '✗ FAIL'
  END as status
FROM public.chapters,
  jsonb_array_elements(content->'messages') as msg
WHERE 
  msg ? 'id'
  AND msg ? 'content'
  AND msg ? 'order'
  AND jsonb_typeof(msg->'id') = 'string'
  AND jsonb_typeof(msg->'content') = 'string'
  AND jsonb_typeof(msg->'order') = 'number';

-- ============================================================================
-- 5. Detailed Chapter Summary
-- ============================================================================
SELECT 
  order_index,
  title,
  jsonb_array_length(content->'messages') as message_count,
  content->'metadata'->>'theme' as theme,
  content->'metadata'->>'estimatedReadTime' as estimated_read_time_minutes,
  LENGTH(title) as title_length,
  CASE 
    WHEN jsonb_array_length(content->'messages') >= 8 THEN '✓'
    ELSE '✗'
  END as has_sufficient_messages
FROM public.chapters
ORDER BY order_index;

-- ============================================================================
-- 6. Message Content Preview
-- ============================================================================
SELECT 
  c.order_index as chapter,
  c.title as chapter_title,
  (msg->>'order')::int as message_order,
  LEFT(msg->>'content', 60) || '...' as content_preview,
  COALESCE((msg->>'delay')::int, 0) as delay_ms
FROM public.chapters c,
  jsonb_array_elements(c.content->'messages') as msg
WHERE c.order_index <= 2  -- Show first 2 chapters as sample
ORDER BY c.order_index, (msg->>'order')::int;

-- ============================================================================
-- 7. Check for Duplicate Message IDs
-- ============================================================================
SELECT 
  'Duplicate Message ID Check' as test_name,
  COUNT(DISTINCT msg_id) as unique_ids,
  COUNT(msg_id) as total_ids,
  CASE 
    WHEN COUNT(DISTINCT msg_id) = COUNT(msg_id) THEN '✓ PASS - No duplicates'
    ELSE '✗ FAIL - Duplicates found'
  END as status
FROM (
  SELECT msg->>'id' as msg_id
  FROM public.chapters,
    jsonb_array_elements(content->'messages') as msg
) subquery;

-- ============================================================================
-- 8. Check Message Order Continuity
-- ============================================================================
SELECT 
  'Message Order Continuity Check' as test_name,
  c.order_index as chapter,
  c.title,
  CASE 
    WHEN (
      SELECT COUNT(*) 
      FROM jsonb_array_elements(c.content->'messages') WITH ORDINALITY as msg(data, idx)
      WHERE (msg.data->>'order')::int = msg.idx
    ) = jsonb_array_length(c.content->'messages')
    THEN '✓ PASS'
    ELSE '✗ FAIL'
  END as status
FROM public.chapters c
ORDER BY c.order_index;

-- ============================================================================
-- 9. Content Statistics
-- ============================================================================
SELECT 
  'Content Statistics' as summary,
  COUNT(*) as total_chapters,
  SUM(jsonb_array_length(content->'messages')) as total_messages,
  ROUND(AVG(jsonb_array_length(content->'messages')), 2) as avg_messages_per_chapter,
  MIN(jsonb_array_length(content->'messages')) as min_messages,
  MAX(jsonb_array_length(content->'messages')) as max_messages,
  SUM((content->'metadata'->>'estimatedReadTime')::int) as total_read_time_minutes
FROM public.chapters;

-- ============================================================================
-- 10. Theme Distribution
-- ============================================================================
SELECT 
  content->'metadata'->>'theme' as theme,
  COUNT(*) as chapter_count
FROM public.chapters
GROUP BY content->'metadata'->>'theme'
ORDER BY chapter_count DESC;

-- ============================================================================
-- END OF VALIDATION
-- ============================================================================
