# ADR 0003 — Prévia visual com estado explícito

**Estado:** adotada para a primeira fatia em 2026-10-07.

## Contexto

O banco contém telas de chamada, status de conexão, MLS e valores ilustrativos,
mas ainda não há protocolo de rede, armazenamento seguro nem captura de mídia.

## Decisão

Construir componentes reais e navegáveis sobre os assets originais. Rotular
fluxos incompletos como prévia e expor no core um status com funcionalidades
pendentes. Nunca atribuir P2P, criptografia, latência ou presença a uma cena
estática. Convites e mensagens não são enviados nesta etapa.

## Consequências

A UI pode ser revisada e iterada desde já sem criar uma falsa garantia de
segurança ou uma chamada fictícia. Recursos reais entram por contratos
verificados com o core, tela por tela.
