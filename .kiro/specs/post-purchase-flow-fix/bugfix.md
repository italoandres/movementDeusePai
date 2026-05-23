# Bugfix Requirements Document

## Introduction

O fluxo pós-compra do ecossistema "Jornada Deus é Pai" está quebrado em 3 pontos críticos que impedem o usuário de acessar o conteúdo após pagamento aprovado. O webhook do Mercado Pago não atualiza o banco corretamente, a página /obrigado exige navegação desnecessária para uma tela separada de criação de acesso, e o email do comprador não é extraído da URL de retorno do Mercado Pago. O resultado é que nenhum comprador consegue completar o fluxo de ativação de acesso de forma autônoma.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN o webhook do Mercado Pago recebe uma notificação de pagamento aprovado E o profile do usuário já existe no banco THEN o sistema retorna 200 mas o campo `access_type` permanece "free" e `has_book_access` permanece false no profile (o update falha silenciosamente porque colunas como `book_purchased_at`, `payment_id`, `payment_provider` podem não existir na tabela profiles)

1.2 WHEN o webhook do Mercado Pago recebe uma notificação de pagamento aprovado E o profile do usuário ainda NÃO existe no banco THEN o sistema não cria o profile e o acesso nunca é liberado (apenas tenta update, não faz upsert/insert)

1.3 WHEN o usuário é redirecionado para a página /obrigado após pagamento aprovado THEN o sistema exibe apenas uma mensagem estática com botão "criar meu acesso" que navega para uma tela separada (/criar-acesso), forçando navegação intermediária

1.4 WHEN o Mercado Pago redireciona o usuário para a URL de sucesso com query params (ex: `?external_reference=email@example.com`) THEN a página /obrigado não extrai o `external_reference` da URL e o campo de email fica vazio

1.5 WHEN o usuário tenta criar acesso na tela /criar-acesso THEN o sistema não executa a criação real do auth user no Supabase (código está com TODO), não marca `has_book_access = true`, e não realiza login automático

### Expected Behavior (Correct)

2.1 WHEN o webhook do Mercado Pago recebe uma notificação de pagamento aprovado E o profile do usuário já existe no banco THEN o sistema SHALL atualizar o profile com `access_type = 'book'` e `has_book_access = true`, registrando a compra na tabela purchases com logs claros de cada etapa (webhook recebido, payment_id, email, status, profile atualizado)

2.2 WHEN o webhook do Mercado Pago recebe uma notificação de pagamento aprovado E o profile do usuário ainda NÃO existe no banco THEN o sistema SHALL salvar a compra na tabela purchases com `access_released = true` para que quando o usuário criar a conta, o acesso seja reconhecido automaticamente

2.3 WHEN o usuário é redirecionado para a página /obrigado após pagamento aprovado THEN o sistema SHALL exibir tudo inline na mesma tela: headline "Seu acesso já está pronto.", subtexto "Agora só falta criar sua senha para entrar no seu espaço diante do Pai.", campos de email (readonly, preenchido), nome e senha, com botão "entrar na caminhada" — sem navegação para tela separada

2.4 WHEN o Mercado Pago redireciona o usuário para a URL de sucesso com query params contendo `external_reference` THEN o sistema SHALL extrair o valor de `external_reference` da URL (que contém o email do comprador) e preencher o campo de email automaticamente como readonly com estilo elegante

2.5 WHEN o usuário preenche nome e senha na tela /obrigado e clica "entrar na caminhada" THEN o sistema SHALL criar o auth user no Supabase, garantir que o profile existe com `has_book_access = true` e `access_type = 'book'`, realizar login automático e redirecionar para a Home da Jornada Deus é Pai — sem necessidade de login manual posterior

### Unchanged Behavior (Regression Prevention)

3.1 WHEN o webhook recebe notificações que NÃO são do tipo payment (ex: merchant_order, chargebacks) THEN o sistema SHALL CONTINUE TO retornar 200 e ignorar sem processar

3.2 WHEN o webhook recebe um pagamento com status diferente de "approved" (pending, rejected, cancelled) THEN o sistema SHALL CONTINUE TO salvar o registro sem liberar acesso e sem atualizar profile

3.3 WHEN o webhook recebe uma notificação de pagamento já processado anteriormente (mesmo payment_id) THEN o sistema SHALL CONTINUE TO ignorar por idempotência sem duplicar registros

3.4 WHEN um usuário que já possui acesso tipo "book" ou "admin" interage com o sistema THEN o sistema SHALL CONTINUE TO manter seu access_type existente sem rebaixar

3.5 WHEN um usuário acessa a landing page de vendas ou a jornada gratuita THEN o sistema SHALL CONTINUE TO funcionar normalmente sem exigir autenticação

3.6 WHEN um usuário com acesso "free" faz login normalmente (sem ter comprado) THEN o sistema SHALL CONTINUE TO mostrar o conteúdo gratuito sem alterar seu access_type
