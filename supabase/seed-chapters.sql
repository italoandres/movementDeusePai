-- ============================================================================
-- Chapter Seed Data - "Carta de um Órfão" Theme
-- ============================================================================
-- This script seeds the chapters table with initial spiritual content
-- following the "Carta de um Órfão" (Letter from an Orphan) theme about
-- discovering God as Father.
--
-- Requirements: 1.1, 1.2
-- Task: 6.3
-- ============================================================================

-- Clear existing chapters (optional - comment out if you want to preserve data)
-- DELETE FROM public.chapters;

-- ============================================================================
-- Chapter 1: O Vazio que Você Sente (The Emptiness You Feel)
-- ============================================================================
INSERT INTO public.chapters (order_index, title, content) VALUES (
  1,
  'O Vazio que Você Sente',
  '{
    "messages": [
      {
        "id": "ch1-msg1",
        "content": "Você já se sentiu sozinho, mesmo cercado de pessoas?",
        "order": 1,
        "delay": 0
      },
      {
        "id": "ch1-msg2",
        "content": "Como se ninguém realmente te conhecesse?",
        "order": 2,
        "delay": 2000
      },
      {
        "id": "ch1-msg3",
        "content": "Essa sensação tem um nome: orfandade espiritual.",
        "order": 3,
        "delay": 3000
      },
      {
        "id": "ch1-msg4",
        "content": "É o vazio de não conhecer o Pai que te criou.",
        "order": 4,
        "delay": 2000
      },
      {
        "id": "ch1-msg5",
        "content": "Mas eu tenho uma notícia para você...",
        "order": 5,
        "delay": 3000
      },
      {
        "id": "ch1-msg6",
        "content": "Você não está sozinho. Nunca esteve.",
        "order": 6,
        "delay": 2500
      },
      {
        "id": "ch1-msg7",
        "content": "Há um Pai que te conhece pelo nome. Que te vê. Que te ama.",
        "order": 7,
        "delay": 3000
      },
      {
        "id": "ch1-msg8",
        "content": "E esta jornada é sobre descobrir quem Ele é.",
        "order": 8,
        "delay": 2500
      }
    ],
    "metadata": {
      "theme": "spiritual_orphanhood",
      "estimatedReadTime": 3
    }
  }'::jsonb
);

-- ============================================================================
-- Chapter 2: A Busca por Pertencimento (The Search for Belonging)
-- ============================================================================
INSERT INTO public.chapters (order_index, title, content) VALUES (
  2,
  'A Busca por Pertencimento',
  '{
    "messages": [
      {
        "id": "ch2-msg1",
        "content": "Quantas vezes você tentou preencher esse vazio?",
        "order": 1,
        "delay": 0
      },
      {
        "id": "ch2-msg2",
        "content": "Com relacionamentos, conquistas, reconhecimento...",
        "order": 2,
        "delay": 2500
      },
      {
        "id": "ch2-msg3",
        "content": "Mas nada parece ser suficiente, não é?",
        "order": 3,
        "delay": 2000
      },
      {
        "id": "ch2-msg4",
        "content": "Porque esse vazio não é sobre o que você faz.",
        "order": 4,
        "delay": 3000
      },
      {
        "id": "ch2-msg5",
        "content": "É sobre quem você é.",
        "order": 5,
        "delay": 2000
      },
      {
        "id": "ch2-msg6",
        "content": "Você foi criado para pertencer a alguém.",
        "order": 6,
        "delay": 3000
      },
      {
        "id": "ch2-msg7",
        "content": "Para ser filho. Para ser filha.",
        "order": 7,
        "delay": 2500
      },
      {
        "id": "ch2-msg8",
        "content": "E há um Pai esperando para te receber de braços abertos.",
        "order": 8,
        "delay": 3500
      },
      {
        "id": "ch2-msg9",
        "content": "Não porque você merece. Mas porque Ele te ama.",
        "order": 9,
        "delay": 3000
      }
    ],
    "metadata": {
      "theme": "belonging_and_identity",
      "estimatedReadTime": 4
    }
  }'::jsonb
);

-- ============================================================================
-- Chapter 3: O Pai que Você Não Conheceu (The Father You Never Knew)
-- ============================================================================
INSERT INTO public.chapters (order_index, title, content) VALUES (
  3,
  'O Pai que Você Não Conheceu',
  '{
    "messages": [
      {
        "id": "ch3-msg1",
        "content": "Talvez a palavra ''Pai'' traga dor para você.",
        "order": 1,
        "delay": 0
      },
      {
        "id": "ch3-msg2",
        "content": "Talvez seu pai terreno tenha falhado. Ou nunca esteve presente.",
        "order": 2,
        "delay": 3000
      },
      {
        "id": "ch3-msg3",
        "content": "E agora é difícil confiar em qualquer figura paterna.",
        "order": 3,
        "delay": 2500
      },
      {
        "id": "ch3-msg4",
        "content": "Eu entendo.",
        "order": 4,
        "delay": 2000
      },
      {
        "id": "ch3-msg5",
        "content": "Mas preciso te contar sobre um Pai diferente.",
        "order": 5,
        "delay": 2500
      },
      {
        "id": "ch3-msg6",
        "content": "Um Pai que nunca falha. Que nunca abandona. Que nunca decepciona.",
        "order": 6,
        "delay": 3500
      },
      {
        "id": "ch3-msg7",
        "content": "Ele não é como os pais imperfeitos que conhecemos.",
        "order": 7,
        "delay": 2500
      },
      {
        "id": "ch3-msg8",
        "content": "Ele é o Pai perfeito que seu coração sempre desejou.",
        "order": 8,
        "delay": 3000
      },
      {
        "id": "ch3-msg9",
        "content": "E Ele está chamando você de volta para casa.",
        "order": 9,
        "delay": 3000
      }
    ],
    "metadata": {
      "theme": "healing_father_wounds",
      "estimatedReadTime": 4
    }
  }'::jsonb
);

-- ============================================================================
-- Chapter 4: O Convite para Casa (The Invitation Home)
-- ============================================================================
INSERT INTO public.chapters (order_index, title, content) VALUES (
  4,
  'O Convite para Casa',
  '{
    "messages": [
      {
        "id": "ch4-msg1",
        "content": "Há uma história antiga sobre um filho que se perdeu.",
        "order": 1,
        "delay": 0
      },
      {
        "id": "ch4-msg2",
        "content": "Ele pegou sua herança e foi embora. Desperdiçou tudo.",
        "order": 2,
        "delay": 2500
      },
      {
        "id": "ch4-msg3",
        "content": "Quando não tinha mais nada, ele decidiu voltar para casa.",
        "order": 3,
        "delay": 3000
      },
      {
        "id": "ch4-msg4",
        "content": "Envergonhado. Com medo. Preparado para ser rejeitado.",
        "order": 4,
        "delay": 2500
      },
      {
        "id": "ch4-msg5",
        "content": "Mas sabe o que aconteceu?",
        "order": 5,
        "delay": 2000
      },
      {
        "id": "ch4-msg6",
        "content": "O pai viu o filho de longe. E correu.",
        "order": 6,
        "delay": 3000
      },
      {
        "id": "ch4-msg7",
        "content": "Correu para abraçá-lo. Para restaurá-lo. Para celebrá-lo.",
        "order": 7,
        "delay": 3000
      },
      {
        "id": "ch4-msg8",
        "content": "Essa história é sobre você.",
        "order": 8,
        "delay": 2500
      },
      {
        "id": "ch4-msg9",
        "content": "Não importa o quão longe você foi. Deus está esperando você voltar.",
        "order": 9,
        "delay": 3500
      },
      {
        "id": "ch4-msg10",
        "content": "E quando você der o primeiro passo, Ele correrá ao seu encontro.",
        "order": 10,
        "delay": 3500
      }
    ],
    "metadata": {
      "theme": "prodigal_son_invitation",
      "estimatedReadTime": 5
    }
  }'::jsonb
);

-- ============================================================================
-- Chapter 5: Você Faz Parte Agora (You Belong Now)
-- ============================================================================
INSERT INTO public.chapters (order_index, title, content) VALUES (
  5,
  'Você Faz Parte Agora',
  '{
    "messages": [
      {
        "id": "ch5-msg1",
        "content": "Se você chegou até aqui, algo mudou em você.",
        "order": 1,
        "delay": 0
      },
      {
        "id": "ch5-msg2",
        "content": "Você não é mais um órfão espiritual.",
        "order": 2,
        "delay": 2500
      },
      {
        "id": "ch5-msg3",
        "content": "Você é filho. Você é filha.",
        "order": 3,
        "delay": 2000
      },
      {
        "id": "ch5-msg4",
        "content": "Você tem um Pai que te conhece, te ama, te escolheu.",
        "order": 4,
        "delay": 3000
      },
      {
        "id": "ch5-msg5",
        "content": "E agora você faz parte de algo maior.",
        "order": 5,
        "delay": 2500
      },
      {
        "id": "ch5-msg6",
        "content": "Um movimento de pessoas que descobriram essa verdade.",
        "order": 6,
        "delay": 3000
      },
      {
        "id": "ch5-msg7",
        "content": "Pessoas que podem dizer com confiança:",
        "order": 7,
        "delay": 2500
      },
      {
        "id": "ch5-msg8",
        "content": "''Deus é Pai.''",
        "order": 8,
        "delay": 2000
      },
      {
        "id": "ch5-msg9",
        "content": "Não apenas uma ideia. Mas uma realidade vivida.",
        "order": 9,
        "delay": 3000
      },
      {
        "id": "ch5-msg10",
        "content": "Bem-vindo à família.",
        "order": 10,
        "delay": 2500
      },
      {
        "id": "ch5-msg11",
        "content": "Você não está mais sozinho.",
        "order": 11,
        "delay": 3000
      }
    ],
    "metadata": {
      "theme": "identity_and_belonging",
      "estimatedReadTime": 5
    }
  }'::jsonb
);

-- ============================================================================
-- Verification Query
-- ============================================================================
-- Uncomment to verify the chapters were inserted correctly:

-- SELECT 
--   order_index,
--   title,
--   jsonb_array_length(content->'messages') as message_count,
--   content->'metadata'->>'theme' as theme,
--   content->'metadata'->>'estimatedReadTime' as read_time
-- FROM public.chapters
-- ORDER BY order_index;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
