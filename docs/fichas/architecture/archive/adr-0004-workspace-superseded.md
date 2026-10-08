# ADR 0004 — Um workspace para frontend, core e fichas

**Estado:** histórica; substituída em 2026-10-08 pela [ADR 0004 de repositórios separados](../adr-0004-separate-repositories.md).

## Contexto

O desenvolvimento do frontend e backend precisa ocorrer no mesmo repositório
para facilitar evolução conjunta, revisão por IA e contratos entre camadas.
A documentação será futuramente vetorizada.

## Decisão

Manter `frontend/` e `backend/` no mesmo repositório; o backend Rust participa
do workspace Cargo na raiz. Guardar specs, ADRs e notas pequenas em
`docs/fichas/<domínio>/`. Guardar o banco original de imagens em
`docs/design/` separado das fichas textuais. A raiz mantém apenas README,
manifestos e arquivos operacionais.

## Consequências

Mudanças entre UI e core podem ser revisadas num único commit. Cada ficha
precisa declarar se descreve código atual, contrato futuro ou decisão. Assets
grandes não entram no índice vetorial por acidente.
