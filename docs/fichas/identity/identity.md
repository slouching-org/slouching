# Identidade local

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** especificada; não implementada.

O dispositivo criará sua própria identidade de assinatura e folha MLS. Não há
conta ou email obrigatório. Nome e familiar são escolhas de perfil, diferentes
da identidade criptográfica. A comparação de fingerprint/QR com outro membro
é o ato que permite rotulá-lo como verificado.

A tela nativa Rust/Iced mantém nome e familiar apenas em memória para
prévia visual. O protótipo web histórico usa `localStorage`. Nenhuma dessas
telas cria chaves ou identidade autenticada. A identidade e o estado MLS
ficarão no dispositivo; histórico, inbox e outbox usarão SQLite criptografado.
SQLCipher e proteção das chaves ainda precisam de implementação.

Pendências de segurança: formato e proteção da chave local, múltiplos
dispositivos, recuperação, política de troca de chave e derivação exata da
comparação visual. Ver [modelo de confiança](../architecture/backend.md#3-trust-and-security-model).
