# Setup do Schema Unificado no Supabase

Este documento contém as instruções para configurar o banco de dados Supabase com o schema unificado que suporta tanto o livro interativo quanto o app de chat.

## Pré-requisitos

- Projeto Supabase criado: `https://frtwqdpgslykzxeebmtw.supabase.co`
- Acesso ao SQL Editor no dashboard do Supabase

## Passo 1: Executar o Schema Unificado

1. Acesse o Supabase Dashboard: https://supabase.com/dashboard/project/frtwqdpgslykzxeebmtw
2. Vá em **SQL Editor** no menu lateral
3. Clique em **New Query**
4. Cole o conteúdo do arquivo que você me forneceu (o schema unificado completo)
5. Clique em **Run** para executar

## Passo 2: Criar o Trigger de Perfil Automático

Após executar o schema unificado, execute este SQL adicional:

```sql
-- ============================================
-- TRIGGER: Criar perfil automaticamente após signup
-- ============================================

-- Função para criar perfil quando um novo usuário é criado
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, email, perfil_is_complete, senha_is_seted)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', 'Usuário'),
    NEW.email,
    false,
    true
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que executa após inserção na tabela auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## Passo 3: Inserir Dados Iniciais dos Capítulos

Execute este SQL para criar o primeiro capítulo de exemplo:

```sql
-- Inserir capítulo inicial
INSERT INTO public.chapters (
  chapter_number,
  title,
  subtitle,
  content,
  summary,
  required_seals,
  estimated_time,
  difficulty
) VALUES (
  1,
  'Carta de um Órfão',
  'O início da jornada',
  'Bem-vindo à sua jornada espiritual. Este é o primeiro capítulo onde exploramos o sentimento de orfandade espiritual e como podemos encontrar conexão com a paternidade divina.',
  'Introdução ao conceito de orfandade espiritual',
  0,
  10,
  'easy'
);
```

## Passo 4: Verificar a Configuração

Execute este SQL para verificar se tudo está funcionando:

```sql
-- Verificar tabelas criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar se o trigger foi criado
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- Verificar capítulos
SELECT * FROM chapters ORDER BY chapter_number;
```

## Passo 5: Testar Criação de Usuário

1. Acesse a aplicação: http://localhost:3000
2. Clique em "Começar minha jornada"
3. Crie uma conta com email e senha
4. Verifique no Supabase Dashboard se:
   - O usuário foi criado em **Authentication > Users**
   - O perfil foi criado automaticamente em **Table Editor > profiles**

## Estrutura do Schema Unificado

### Tabelas Principais

- **profiles**: Perfis de usuário compartilhados entre livro e app
- **chapters**: Capítulos do livro interativo
- **user_progress**: Progresso do usuário em cada capítulo
- **seals**: Selos/conquistas disponíveis
- **user_seals**: Selos desbloqueados por cada usuário
- **chats**: Chats do app (com requisitos de acesso)
- **chat_participants**: Participantes dos chats
- **messages**: Mensagens dos chats

### Diferenças do Schema Anterior

| Campo Antigo | Campo Novo | Tabela |
|--------------|------------|--------|
| `order_index` | `chapter_number` | chapters |
| `completed` (boolean) | `status` (enum) | user_progress |
| `seal_awarded` | Movido para `user_seals` | profiles |
| `display_name` | `nome` | profiles |

## Troubleshooting

### Erro: "column chapters.order_index does not exist"
✅ **Solução**: O código foi atualizado para usar `chapter_number`

### Erro ao criar conta
✅ **Solução**: Verifique se o trigger `on_auth_user_created` foi criado corretamente

### Capítulos não aparecem
✅ **Solução**: Execute o SQL do Passo 3 para inserir o primeiro capítulo

## Próximos Passos

Após configurar o schema:

1. Reinicie o servidor de desenvolvimento: `npm run dev`
2. Teste o fluxo completo:
   - Criar conta
   - Ver primeiro capítulo
   - Enviar mensagem
   - Completar capítulo
3. Verifique os dados no Supabase Dashboard

## Suporte

Se encontrar problemas, verifique:
- Logs do Supabase no Dashboard
- Console do navegador (F12)
- Terminal onde o `npm run dev` está rodando
