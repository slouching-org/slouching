# Identidade local

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** identidade Ed25519 e chave MLS vinculada à identidade do dispositivo
são persistidas localmente; grupos MLS, histórico, inbox e outbox cifrados têm
fluxo funcional no cliente nativo. O cliente agora permite comparar a chave
Ed25519 completa por um canal independente e registrar localmente essa decisão
no perfil SQLCipher. Pareamento por QR/código e recuperação continuam pendentes.

O dispositivo criará sua própria identidade de assinatura e folha MLS. Não há
conta ou email obrigatório. Nome e familiar são escolhas de perfil, diferentes
da identidade criptográfica. A comparação da chave pública completa com outro
membro por canal independente é o ato que permite marcá-la como verificada.

A tela nativa salva nome e familiar em SQLCipher. A seed Ed25519 do dispositivo
fica no chaveiro do sistema. Uma chave pública de peer só recebe o rótulo
verificada neste dispositivo depois da confirmação manual do usuário. A decisão
é vinculada aos 32 bytes exatos da chave no banco SQLCipher; outra chave não
herda essa confiança.
O cliente cria ou carrega uma chave de assinatura MLS e registra uma vinculação
assinada pela identidade do dispositivo. Essa vinculação acompanha os
KeyPackages e é verificada durante a admissão e o processamento de mensagens;
ela prova autorização da chave MLS pelo dispositivo, não que a pessoa ou o
contato foi verificado. A chave privada MLS e o estado dos grupos ficam no
banco local cifrado. O protótipo web histórico continua usando `localStorage`
e não cria chaves.

Pendências de segurança: formatos QR/código curto, pareamento, múltiplos
dispositivos, backup e recuperação, e política de troca de chave. A verificação
manual exige que os membros comparem a chave completa usando um canal
independente; o app não valida esse canal. O cliente exige Secret Service no
Linux para acessar as credenciais. Ver [modelo de confiança](../architecture/backend.md#3-trust-and-security-model).
