# Identidade local

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** identidade Ed25519 e chave MLS vinculada à identidade do dispositivo
são persistidas localmente; grupos MLS, histórico, inbox e outbox cifrados têm
fluxo funcional no cliente nativo. O cliente agora permite comparar a chave
Ed25519 completa por um canal independente e registrar localmente essa decisão
no perfil SQLCipher. Convites QR assinados agora carregam a chave do dispositivo
e, quando disponíveis, endereços IP/porta com validade de 10 minutos. Importar
um QR PNG preenche a chave e permite escolher o endereço, mas não marca o peer
como verificado automaticamente. Um fingerprint simétrico completo de 256 bits,
derivado das duas chaves públicas, pode ser comparado ao vivo antes de marcar
o peer como verificado.
Ele não implementa rendezvous SPAKE2, descoberta de contatos ou recuperação.
O cliente agora contém uma base criptográfica SPAKE2 experimental, sem fluxo
de interface, rendezvous, limite de tentativas ou troca de identidades. Ela
não marca contatos como verificados. Consulte
[o estado e os limites do protótipo SPAKE2](spake2-prototype.md).

O dispositivo cria sua própria identidade de assinatura e folha MLS. Não há
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

O formato do convite QR assinado v1, seus limites, a assinatura da lista de
endereços e seu limite de confiança estão em
[pairing-invite-v1.md](pairing-invite-v1.md). A assinatura vincula endereços à
chave, mas não autentica quem forneceu a imagem. O usuário só deve marcar a
chave como verificada depois de importar o QR mostrado diretamente pelo contato
ou conferir a chave completa por canal independente.

Pendências de segurança: revisão do fluxo QR, câmera ao vivo, pareamento SPAKE2,
recuperação, múltiplos dispositivos, backup e política de troca de chave. O cliente
exige Secret Service no Linux para acessar as credenciais. Ver [modelo
de confiança](../architecture/backend.md#3-trust-and-security-model).
