# Identidade local

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** identidade Ed25519 e chave MLS vinculada à identidade do dispositivo
são persistidas localmente; grupos MLS, histórico, inbox e outbox cifrados têm
fluxo funcional no cliente nativo. Verificação humana e recuperação ainda estão
pendentes.

O dispositivo criará sua própria identidade de assinatura e folha MLS. Não há
conta ou email obrigatório. Nome e familiar são escolhas de perfil, diferentes
da identidade criptográfica. A comparação de fingerprint/QR com outro membro
é o ato que permite rotulá-lo como verificado.

A tela nativa salva nome e familiar em SQLCipher. A seed Ed25519 do dispositivo
fica no chaveiro do sistema e a chave pública é mostrada como não verificada.
O cliente cria ou carrega uma chave de assinatura MLS e registra uma vinculação
assinada pela identidade do dispositivo. Essa vinculação acompanha os
KeyPackages e é verificada durante a admissão e o processamento de mensagens;
ela prova autorização da chave MLS pelo dispositivo, não que a pessoa ou o
contato foi verificado. A chave privada MLS e o estado dos grupos ficam no
banco local cifrado. O protótipo web histórico continua usando `localStorage`
e não cria chaves.

Pendências de segurança: derivação e formato do fingerprint/QR, verificação
por canal independente, pareamento, múltiplos dispositivos, backup e
recuperação, e política de troca de chave. O cliente exige Secret Service no
Linux para acessar as credenciais. Ver [modelo de confiança](../architecture/backend.md#3-trust-and-security-model).
