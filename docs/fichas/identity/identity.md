# Identidade local

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** criação e armazenamento local da chave Ed25519 implementados;
pareamento, fingerprint/QR e integração MLS ainda não implementados.

O dispositivo criará sua própria identidade de assinatura e folha MLS. Não há
conta ou email obrigatório. Nome e familiar são escolhas de perfil, diferentes
da identidade criptográfica. A comparação de fingerprint/QR com outro membro
é o ato que permite rotulá-lo como verificado.

A tela nativa salva nome e familiar em SQLite cifrado. Uma ação explícita
cria uma seed Ed25519 de 32 bytes e a guarda no chaveiro do sistema; a tela
mostra a chave pública correspondente como não verificada. A chave não é
criada automaticamente, enviada a um peer ou usada para assinar mensagens.
O protótipo web histórico continua usando `localStorage` e não cria chaves.
O estado MLS, histórico, inbox e outbox ainda não estão implementados.

Pendências de segurança: derivação e formato do fingerprint/QR, verificação
por canal independente, pareamento, múltiplos dispositivos, recuperação e
política de troca de chave. Ver [modelo de confiança](../architecture/backend.md#3-trust-and-security-model).
