# ADR 0001 — Núcleo em cada dispositivo

> **Decisão vigente:** [ADR 0005](adr-0005-elixir-server-core.md) define
> Elixir como backend e Rust como cliente. [ADR 0006](adr-0006-local-storage-optional-helper.md)
> reafirma armazenamento local em SQLite e helper opcional; a escolha de
> linguagem não exige servidor hospedado ou Postgres.

**Estado:** aceita pelo dono do produto em 2026-10-07.

## Contexto

O PDF inicial sugeria entrega central com Elixir/PostgreSQL. O requisito
esclarecido é que amigos conectados possam usar Slouching sem depender de um
servidor operado por terceiros.

## Decisão

Cada dispositivo executa o core e guarda suas próprias chaves, estado MLS,
histórico e fila local em SQLite criptografado. Postgres não é dependência
de inicialização do aplicativo. Pares se conectam diretamente quando possível. Um
membro pode operar voluntariamente um helper em seu PC ou VPS, com funções
limitadas de rendezvous, mailbox, relay ou SFU. Nenhum helper guarda segredos
de membros nem decide o estado criptográfico do grupo.

## Consequências

Sem rota direta ou helper autorizado, alguns pares não conseguem se conectar.
Sem cópia online, mensagens aguardam. Perda de dados quando todos os
detentores saem pode ser aceitável. A UI deve mostrar essas condições.

Detalhes: [backend.md](backend.md).
