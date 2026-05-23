# Implementation Plan: Book Home Page

## Overview

Este plano de implementação detalha as tarefas necessárias para criar a página inicial de leitura do livro "Não Ore, Fale com o Pai" em Flutter Web. A implementação segue Clean Architecture com feature-based organization, usando Riverpod para state management e shared_preferences para persistência local.

A abordagem é incremental: começamos com os modelos de domínio, depois a camada de dados, seguida pelo state management, e finalmente a camada de apresentação com todos os widgets. Cada etapa valida a funcionalidade antes de avançar.

## Tasks

- [x] 1. Criar modelos de domínio e estrutura base
  - [x] 1.1 Criar modelo UserProgress com serialização JSON
    - Criar arquivo `lib/features/book/domain/models/user_progress.dart`
    - Implementar classe UserProgress com propriedades: currentChapter, completedChapters, unlockedChapters
    - Implementar métodos toJson() e fromJson() para serialização
    - Implementar método copyWith() para imutabilidade
    - _Requirements: 10.1, 10.2, 10.3, 11.3, 11.4, 11.5_
  
  - [ ]* 1.2 Escrever testes unitários para UserProgress
    - Criar arquivo `test/unit/domain/models/user_progress_test.dart`
    - Testar serialização e deserialização JSON
    - Testar método copyWith()
    - Testar casos extremos (listas vazias, valores nulos)
    - _Requirements: 11.3, 11.4, 11.5_
  
  - [ ]* 1.3 Escrever teste de propriedade para UserProgress
    - **Property 13: Progress Persistence Round-Trip**
    - **Validates: Requirements 11.3, 11.4, 11.5**
    - Gerar UserProgress aleatórios e verificar que serialização + deserialização preserva os dados
    - _Requirements: 11.3, 11.4, 11.5_

- [x] 2. Implementar camada de dados (Data Sources e Repositories)
  - [x] 2.1 Criar ProgressLocalDataSource
    - Criar arquivo `lib/features/book/data/data_sources/progress_local_data_source.dart`
    - Implementar classe ProgressLocalDataSource com SharedPreferences
    - Implementar método getProgress() para ler do Local Storage
    - Implementar método saveProgress() para salvar no Local Storage
    - Implementar método clearProgress() para limpar dados
    - Usar chave de storage: 'user_progress'
    - _Requirements: 11.1, 11.2, 11.6_
  
  - [x] 2.2 Criar interface ProgressRepository
    - Criar arquivo `lib/features/book/domain/repositories/progress_repository.dart`
    - Definir interface abstrata com métodos: getProgress(), saveProgress(), clearProgress()
    - _Requirements: 11.1, 11.2_
  
  - [x] 2.3 Implementar ProgressRepositoryImpl
    - Criar arquivo `lib/features/book/data/repositories/progress_repository_impl.dart`
    - Implementar ProgressRepository usando ProgressLocalDataSource
    - Adicionar tratamento de erros com mensagens descritivas
    - Implementar validação de estado (corrigir valores inválidos automaticamente)
    - _Requirements: 11.1, 11.2, 16.1, 16.2_
  
  - [ ]* 2.4 Escrever testes unitários para ProgressLocalDataSource
    - Criar arquivo `test/unit/data/data_sources/progress_local_data_source_test.dart`
    - Testar leitura e escrita no SharedPreferences
    - Testar comportamento quando storage está vazio
    - Testar tratamento de dados corrompidos
    - _Requirements: 11.2, 11.6_
  
  - [ ]* 2.5 Escrever testes unitários para ProgressRepositoryImpl
    - Criar arquivo `test/unit/data/repositories/progress_repository_impl_test.dart`
    - Testar getProgress() com sucesso e falha
    - Testar saveProgress() com sucesso e falha
    - Testar clearProgress()
    - Testar validação de estado inválido
    - _Requirements: 11.1, 11.2, 16.1, 16.2_

- [x] 3. Implementar State Management (Riverpod Providers e Notifiers)
  - [x] 3.1 Criar ProgressState
    - Criar arquivo `lib/features/book/presentation/state/progress_state.dart`
    - Implementar classe ProgressState com propriedades: currentChapter, completedChapters, unlockedChapters, isLoading, error
    - Implementar factory ProgressState.initial() com valores padrão
    - Implementar método copyWith() para atualizações imutáveis
    - _Requirements: 10.1, 10.2, 10.3, 15.1, 15.2_
  
  - [x] 3.2 Criar ProgressNotifier
    - Criar arquivo `lib/features/book/presentation/state/progress_notifier.dart`
    - Implementar StateNotifier<ProgressState>
    - Implementar método loadProgress() para carregar do repository
    - Implementar método completeChapter() para marcar capítulo como completo
    - Implementar lógica de desbloqueio: ao completar capítulo N, desbloquear N+1
    - Implementar método _saveProgress() privado para persistir mudanças
    - Adicionar tratamento de erros em todos os métodos
    - _Requirements: 7.2, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 11.1_
  
  - [x] 3.3 Criar Riverpod Providers
    - Criar arquivo `lib/features/book/presentation/providers/progress_providers.dart`
    - Criar progressLocalDataSourceProvider (Provider)
    - Criar progressRepositoryProvider (Provider)
    - Criar progressNotifierProvider (StateNotifierProvider)
    - Criar currentChapterProvider (Provider derivado)
    - Criar unlockedChaptersProvider (Provider derivado)
    - Criar completedChaptersProvider (Provider derivado)
    - Criar chaptersProvider (Provider derivado que combina chapters com unlock state)
    - _Requirements: 10.1, 10.2, 10.3, 10.6_
  
  - [ ]* 3.4 Escrever testes unitários para ProgressNotifier
    - Criar arquivo `test/unit/presentation/state/progress_notifier_test.dart`
    - Testar loadProgress() com sucesso e falha
    - Testar completeChapter() atualiza estado corretamente
    - Testar que completeChapter() desbloqueia próximo capítulo
    - Testar que completeChapter() chama saveProgress()
    - Testar notificação de listeners em mudanças de estado
    - _Requirements: 7.2, 10.4, 10.5, 10.6, 11.1_
  
  - [ ]* 3.5 Escrever testes de propriedade para lógica de unlock
    - **Property 4: Chapter Unlock Progression**
    - **Validates: Requirements 7.2, 10.5**
    - Gerar números de capítulos aleatórios e verificar que completar N desbloqueia N+1
    - _Requirements: 7.2, 10.5_
  
  - [ ]* 3.6 Escrever teste de propriedade para persistência de unlock state
    - **Property 7: Unlock State Persistence Round-Trip**
    - **Validates: Requirements 7.5**
    - Gerar conjuntos aleatórios de capítulos desbloqueados e verificar que salvar + carregar preserva o estado
    - _Requirements: 7.5_
  
  - [ ]* 3.7 Escrever teste de propriedade para notificação de mudanças
    - **Property 11: State Change Notification**
    - **Validates: Requirements 10.6**
    - Verificar que qualquer mudança no estado notifica todos os listeners
    - _Requirements: 10.6_
  
  - [ ]* 3.8 Escrever teste de propriedade para save on change
    - **Property 12: Progress Save on Change**
    - **Validates: Requirements 11.1**
    - Verificar que qualquer mudança no progresso chama o método save
    - _Requirements: 11.1_

- [x] 4. Checkpoint - Validar camada de dados e state management
  - Executar todos os testes unitários e de propriedade criados até agora
  - Verificar que não há erros de compilação
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implementar widgets de animação e utilitários
  - [x] 5.1 Criar FadeInWidget
    - Criar arquivo `lib/features/book/presentation/widgets/fade_in_widget.dart`
    - Implementar StatefulWidget com AnimationController
    - Suportar propriedades: child, delay, duration
    - Usar FadeTransition para performance (GPU-accelerated)
    - Implementar dispose() para limpar controller
    - Usar Curves.easeIn para animação suave
    - _Requirements: 4.1, 4.3, 4.4_
  
  - [ ]* 5.2 Escrever testes de widget para FadeInWidget
    - Criar arquivo `test/widget/presentation/widgets/fade_in_widget_test.dart`
    - Testar que widget renderiza sem erros
    - Testar que animação inicia após delay
    - Testar que opacity vai de 0.0 a 1.0
    - Testar que controller é disposed corretamente
    - _Requirements: 4.1, 4.3, 4.4_

- [x] 6. Implementar widgets de apresentação (header e quotes)
  - [x] 6.1 Criar BookHeader widget
    - Criar arquivo `lib/features/book/presentation/widgets/book_header.dart`
    - Implementar StatelessWidget que exibe título e subtítulo
    - Usar BookContent.bookTitle e BookContent.bookSubtitle
    - Envolver em FadeInWidget com delay de 100ms
    - Aplicar estilos de tipografia responsivos (mobile vs desktop)
    - _Requirements: 2.1, 2.2, 2.3, 13.1, 13.2_
  
  - [x] 6.2 Criar ReflectionQuotesSection widget
    - Criar arquivo `lib/features/book/presentation/widgets/reflection_quotes_section.dart`
    - Implementar StatelessWidget que exibe lista de quotes
    - Usar BookContent.reflectionQuotes
    - Aplicar FadeInWidget com delays escalonados (300ms + index * 100ms)
    - Adicionar espaçamento vertical generoso entre quotes
    - Aplicar estilos de tipografia responsivos
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_
  
  - [ ]* 6.3 Escrever testes de widget para BookHeader
    - Criar arquivo `test/widget/presentation/widgets/book_header_test.dart`
    - Testar que título e subtítulo são exibidos
    - Testar que FadeInWidget está presente
    - Testar estilos responsivos (mobile vs desktop)
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [ ]* 6.4 Escrever testes de widget para ReflectionQuotesSection
    - Criar arquivo `test/widget/presentation/widgets/reflection_quotes_section_test.dart`
    - Testar que todos os quotes são exibidos
    - Testar que FadeInWidget está presente para cada quote
    - Testar delays escalonados
    - Testar espaçamento entre quotes
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 7. Implementar widgets de progresso e capítulos
  - [x] 7.1 Criar ProgressDisplay widget
    - Criar arquivo `lib/features/book/presentation/widgets/progress_display.dart`
    - Implementar ConsumerWidget que lê currentChapterProvider
    - Exibir "Seu progresso na jornada"
    - Formatar como "Capítulo X de Y"
    - Envolver em FadeInWidget com delay de 600ms
    - Aplicar estilos de tipografia responsivos
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  
  - [x] 7.2 Criar ChapterListItem widget
    - Criar arquivo `lib/features/book/presentation/widgets/chapter_list_item.dart`
    - Implementar StatefulWidget para gerenciar hover state
    - Exibir número e título do capítulo
    - Exibir ícone de cadeado (🔒) se capítulo bloqueado
    - Aplicar opacidade reduzida (0.4) se bloqueado
    - Implementar hover feedback para capítulos desbloqueados
    - Implementar navegação ao clicar (apenas se desbloqueado)
    - Adicionar Semantics para acessibilidade
    - _Requirements: 6.2, 6.4, 6.5, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4, 14.5_
  
  - [x] 7.3 Criar ChapterList widget
    - Criar arquivo `lib/features/book/presentation/widgets/chapter_list.dart`
    - Implementar ConsumerWidget que lê chaptersProvider
    - Renderizar lista de ChapterListItem
    - Envolver em FadeInWidget com delay de 700ms
    - Aplicar espaçamento vertical entre items
    - _Requirements: 6.1, 6.3, 6.6_
  
  - [ ]* 7.4 Escrever testes de widget para ProgressDisplay
    - Criar arquivo `test/widget/presentation/widgets/progress_display_test.dart`
    - Testar que texto de progresso é exibido corretamente
    - Testar formato "Capítulo X de Y"
    - Testar com diferentes valores de currentChapter
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [ ]* 7.5 Escrever teste de propriedade para formato de progresso
    - **Property 1: Progress Format Consistency**
    - **Validates: Requirements 5.3**
    - Gerar números aleatórios de capítulo atual e total, verificar formato "Capítulo X de Y"
    - _Requirements: 5.3_
  
  - [ ]* 7.6 Escrever testes de widget para ChapterListItem
    - Criar arquivo `test/widget/presentation/widgets/chapter_list_item_test.dart`
    - Testar que número e título são exibidos
    - Testar que ícone de cadeado aparece para capítulos bloqueados
    - Testar opacidade reduzida para capítulos bloqueados
    - Testar hover feedback para capítulos desbloqueados
    - Testar que clique em capítulo bloqueado não navega
    - Testar que clique em capítulo desbloqueado navega
    - Testar semantic labels para acessibilidade
    - _Requirements: 6.2, 6.4, 6.5, 7.3, 7.4, 8.1, 8.2, 8.3, 14.5_
  
  - [ ]* 7.7 Escrever testes de propriedade para ChapterListItem
    - **Property 2: Chapter Display Completeness**
    - **Validates: Requirements 6.2, 6.4, 6.5**
    - Gerar capítulos aleatórios e verificar que número, título e lock icon são exibidos corretamente
    - **Property 5: Locked Chapter Navigation Prevention**
    - **Validates: Requirements 7.3, 8.2**
    - Verificar que clicar em capítulo bloqueado não navega
    - **Property 6: Unlocked Chapter Navigation**
    - **Validates: Requirements 7.4, 8.1, 8.4**
    - Verificar que clicar em capítulo desbloqueado navega com ID correto
    - **Property 8: Hover Feedback for Unlocked Chapters**
    - **Validates: Requirements 8.3**
    - Verificar que hover em capítulo desbloqueado muda estado visual
    - **Property 14: Locked Chapter Accessibility Label**
    - **Validates: Requirements 14.5**
    - Verificar que semantic label inclui informação de bloqueio
    - _Requirements: 6.2, 6.4, 6.5, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4, 14.5_
  
  - [ ]* 7.8 Escrever testes de widget para ChapterList
    - Criar arquivo `test/widget/presentation/widgets/chapter_list_test.dart`
    - Testar que todos os capítulos são renderizados
    - Testar ordem sequencial dos capítulos
    - Testar que FadeInWidget está presente
    - _Requirements: 6.1, 6.3, 6.6_
  
  - [ ]* 7.9 Escrever teste de propriedade para ordem de capítulos
    - **Property 3: Sequential Chapter Ordering**
    - **Validates: Requirements 6.6**
    - Verificar que capítulos são sempre exibidos em ordem sequencial por ID
    - _Requirements: 6.6_

- [x] 8. Implementar CTA Button e página principal
  - [x] 8.1 Criar CTAButton widget
    - Criar arquivo `lib/features/book/presentation/widgets/cta_button.dart`
    - Implementar ConsumerWidget que lê currentChapterProvider
    - Exibir "Começar leitura" se currentChapter == 1
    - Exibir "Continuar leitura" se currentChapter > 1
    - Navegar para /book/chapter/{currentChapter} ao clicar
    - Envolver em FadeInWidget com delay de 800ms
    - Aplicar estilo visual proeminente (gold background)
    - Aplicar estilos responsivos (full-width mobile, auto desktop)
    - Adicionar Semantics para acessibilidade
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 13.1, 13.2_
  
  - [x] 8.2 Criar BookHomePage
    - Criar arquivo `lib/features/book/presentation/pages/book_home_page.dart`
    - Implementar ConsumerStatefulWidget
    - Carregar progresso no initState usando progressNotifierProvider
    - Implementar layout responsivo com MediaQuery
    - Compor todos os widgets: BookHeader, ReflectionQuotesSection, ProgressDisplay, ChapterList, CTAButton
    - Implementar SingleChildScrollView para scroll
    - Aplicar background preto e espaçamento adequado
    - Implementar estados de loading e error
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 12.1, 12.2, 12.3, 12.4, 12.5, 13.1, 13.2, 13.3, 13.4, 15.1, 15.2, 15.3, 15.4, 16.1, 16.2, 16.3, 16.4_
  
  - [ ]* 8.3 Escrever testes de widget para CTAButton
    - Criar arquivo `test/widget/presentation/widgets/cta_button_test.dart`
    - Testar que "Começar leitura" é exibido quando currentChapter == 1
    - Testar que "Continuar leitura" é exibido quando currentChapter > 1
    - Testar navegação ao clicar
    - Testar estilos responsivos
    - Testar semantic labels
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  
  - [ ]* 8.4 Escrever teste de propriedade para navegação do CTA
    - **Property 9: CTA Navigation to Current Chapter**
    - **Validates: Requirements 9.4**
    - Gerar números aleatórios de currentChapter > 1 e verificar que CTA navega para esse capítulo
    - _Requirements: 9.4_
  
  - [ ]* 8.5 Escrever testes de widget para BookHomePage
    - Criar arquivo `test/widget/presentation/pages/book_home_page_test.dart`
    - Testar que página renderiza sem erros
    - Testar que todos os widgets filhos estão presentes
    - Testar estado de loading
    - Testar estado de error
    - Testar layout responsivo (mobile vs desktop)
    - Testar que loadProgress é chamado no initState
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 13.1, 13.2, 15.1, 15.2_

- [x] 9. Checkpoint - Validar camada de apresentação
  - Executar todos os testes de widget e propriedade
  - Verificar que não há erros de compilação
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Configurar rotas e integração
  - [x] 10.1 Adicionar rota /book no router
    - Editar arquivo de configuração do go_router (provavelmente em `lib/app.dart` ou `lib/router.dart`)
    - Adicionar rota GoRoute(path: '/book', builder: (context, state) => BookHomePage())
    - Verificar que rota /book/chapter/:id já existe (mencionada no contexto)
    - _Requirements: 8.1, 8.4, 9.3, 9.4_
  
  - [x] 10.2 Adicionar dependências ao pubspec.yaml
    - Verificar que flutter_riverpod ^2.5.0 está presente
    - Verificar que go_router ^13.0.0 está presente
    - Verificar que shared_preferences ^2.2.0 está presente
    - Adicionar dependências se necessário
    - Executar `flutter pub get`
    - _Requirements: 11.1, 11.2_

- [x] 11. Implementar testes de integração
  - [ ]* 11.1 Escrever teste de integração para fluxo completo
    - Criar arquivo `test/integration/book_home_page_flow_test.dart`
    - Testar carregamento da página com Local Storage vazio
    - Testar que capítulo 1 está desbloqueado inicialmente
    - Testar clique no CTA button e navegação
    - Testar que progresso é salvo no Local Storage
    - Testar recarregamento da página e restauração do progresso
    - _Requirements: 7.1, 7.5, 11.1, 11.2, 11.6_
  
  - [ ]* 11.2 Escrever teste de integração para fluxo de erro
    - Criar arquivo `test/integration/book_home_page_error_flow_test.dart`
    - Testar comportamento quando Local Storage não está disponível
    - Testar comportamento quando dados estão corrompidos
    - Testar recuperação de erros
    - _Requirements: 15.4, 16.1, 16.2, 16.3, 16.4_

- [x] 12. Validação de acessibilidade e responsividade
  - [x] 12.1 Validar acessibilidade
    - Testar navegação por teclado (Tab, Enter, Space)
    - Verificar que todos os elementos interativos têm focus indicators
    - Verificar contraste de cores (white on black = 21:1, gold on black = 9.5:1)
    - Testar com text scaling (1.0x, 1.5x, 2.0x)
    - Verificar que semantic labels estão corretos
    - Documentar resultados em comentário no código
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_
  
  - [x] 12.2 Validar responsividade
    - Testar em viewport mobile (< 600px)
    - Testar em viewport desktop (≥ 600px)
    - Verificar que layout se adapta corretamente
    - Verificar que tipografia escala adequadamente
    - Verificar que espaçamentos são apropriados
    - Documentar resultados em comentário no código
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [x] 13. Checkpoint final - Validação completa
  - Executar todos os testes (unit, widget, property, integration)
  - Executar `flutter analyze` para verificar warnings
  - Executar `flutter build web --release` para verificar build de produção
  - Testar manualmente a página no navegador
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tarefas marcadas com `*` são opcionais e podem ser puladas para um MVP mais rápido
- Cada tarefa referencia requisitos específicos para rastreabilidade
- Checkpoints garantem validação incremental
- Testes de propriedade validam propriedades universais de correção
- Testes unitários validam exemplos específicos e casos extremos
- A implementação usa Dart/Flutter conforme especificado no design
- A arquitetura segue Clean Architecture com separação clara de camadas
- O state management usa Riverpod para reatividade
- A persistência usa shared_preferences (Local Storage)
- Todos os widgets seguem princípios de acessibilidade (WCAG 2.1 AA)
- O design é responsivo para mobile e desktop
