# Entrega e réplicas

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** contrato especificado; o cliente tem agora esquema e operações
iniciais para persistir eventos criptografados opacos localmente. MLS,
integração com inbox/outbox, transporte, ACKs e replicação ainda não estão
implementados.

Cada app manterá outbox e inbox persistentes em SQLite criptografado,
IDs estáveis de evento,
deduplicação e recibos distintos para salvo localmente, guardado por outro
peer, recebido por dispositivo, lido, expirado ou falhou. Amigos podem aceitar
cópias de **ciphertext** com quota e prazo explícitos. Um helper opcional
oferece a mesma função por mais tempo e pode usar SQLite. Postgres é uma
opção operacional para um helper maior; a entrega entre peers não depende dele.

A primeira base no cliente armazena ciphertext já produzido por uma camada
criptográfica, com ID, autor, grupo, época, checkpoint, digest BLAKE3 e prazo.
Ela deduplica IDs idênticos e rejeita conteúdo ou metadados divergentes. Ainda
não cria ciphertext, conversa, ACK ou rota de entrega.

Uma cópia em helper não prova entrega ao destinatário. Nenhum membro ganha
histórico anterior automaticamente ao ingressar no grupo. A conversa
persistente e o chat temporário da chamada têm retenções diferentes.

Ver [spec detalhada](../architecture/backend.md#5-delivery-and-replication).
