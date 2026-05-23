# Livro Interativo Espiritual

Uma jornada espiritual interativa através de uma interface de chat.

![CI Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg)
![Deployment](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/deploy.yml/badge.svg)

## Tecnologias

- **Next.js 14** com App Router
- **React 18**
- **TypeScript** (strict mode)
- **TailwindCSS** com tema escuro
- **Supabase** (backend)
- **Vercel** (deployment)
- **GitHub Actions** (CI/CD)

## Estrutura do Projeto

```
├── app/              # Páginas e rotas (Next.js App Router)
├── components/       # Componentes React reutilizáveis
├── lib/              # Utilitários, serviços e tipos
├── .kiro/            # Especificações e documentação do projeto
└── public/           # Arquivos estáticos
```

## Desenvolvimento

```bash
# Instalar dependências
npm install

# Executar servidor de desenvolvimento
npm run dev

# Build de produção
npm run build

# Executar testes
npm test

# Executar testes em modo watch
npm run test:watch

# Executar linter
npm run lint
```

## CI/CD

Este projeto utiliza GitHub Actions para integração contínua e Vercel para deployment.

### Configuração Inicial

```bash
# Executar script de configuração (Linux/Mac)
bash .github/scripts/setup-ci.sh

# Ou no Windows (PowerShell)
.\.github\scripts\setup-ci.ps1
```

### Workflows

- **CI Pipeline**: Executa testes, linting e build em cada push/PR
- **Deploy Pipeline**: Deploy automático para Vercel (preview em PRs, produção no main)

Para mais detalhes, consulte:
- [CI/CD Documentation](.github/README.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Quick Reference](.github/QUICK_REFERENCE.md)

## Configuração

### Ambiente de Desenvolvimento

1. Copie `.env.example` para `.env.local`:
   ```bash
   cp .env.example .env.local
   ```

2. Configure as variáveis de ambiente no `.env.local`:
   - `NEXT_PUBLIC_SUPABASE_URL`: URL do projeto Supabase
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Chave anônima do Supabase

3. Configure o Supabase:
   - Execute o schema: `supabase/schema.sql`
   - Execute o seed: `supabase/seed-chapters.sql`
   - Consulte: `supabase/SETUP_INSTRUCTIONS.md`

### Deployment

Para configurar o deployment em produção:

1. Conecte o repositório ao Vercel
2. Configure as variáveis de ambiente no Vercel
3. Configure os secrets do GitHub Actions
4. Consulte o [Deployment Guide](DEPLOYMENT.md) para instruções detalhadas

O projeto está configurado com:
- TypeScript em modo strict
- TailwindCSS com tema escuro por padrão
- Next.js 14 com App Router
- Estrutura de diretórios: app/, components/, lib/
- CI/CD com GitHub Actions e Vercel

## Próximos Passos

1. ✅ Configurar Supabase
2. ✅ Implementar autenticação
3. ✅ Criar interface de chat
4. ✅ Implementar sistema de progresso
5. ✅ Configurar CI/CD pipeline

## Documentação

- [Requirements](/.kiro/specs/livro-interativo-espiritual/requirements.md) - Requisitos do sistema
- [Design](/.kiro/specs/livro-interativo-espiritual/design.md) - Arquitetura e design
- [Tasks](/.kiro/specs/livro-interativo-espiritual/tasks.md) - Plano de implementação
- [Deployment Guide](DEPLOYMENT.md) - Guia de deployment
- [CI/CD Documentation](.github/README.md) - Documentação do pipeline
- [Quick Reference](.github/QUICK_REFERENCE.md) - Referência rápida de comandos

## Contribuindo

1. Crie uma branch de feature: `git checkout -b feature/minha-feature`
2. Faça suas alterações e commit: `git commit -m "feat: adiciona minha feature"`
3. Push para o GitHub: `git push origin feature/minha-feature`
4. Crie um Pull Request
5. Aguarde os checks do CI passarem
6. Após aprovação, merge para main

## Licença

Este projeto é privado e proprietário.
