# Entrega e réplicas

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** o cliente nativo persiste eventos MLS cifrados na outbox e inbox
locais, entrega diretamente por LAN e mantém ACKs duráveis por dispositivo.
Fan-out direto para membros com rotas salvas, opt-in visível e persistência
SQLCipher de cópia delegada com grant assinado, quota e expiração já existem.
QUIC v8 aceita cópias assinadas e permite que o destinatário busque até 16
eventos por conexão; o ACK do helper segue a persistência e o ACK do destinatário
segue a aplicação MLS. A ação de fan-out tenta um membro com rota alcançável
quando o destinatário falha. A confirmação do helper não fecha o ACK do
destinatário, e retenção permanece best-effort.
O listener helper opt-in aceita autor e destinatário em sessões autenticadas
separadas, serialmente. Quadros comuns continuam sujeitos ao pin manual. Cada
sessão ainda exige rota alcançável até o helper; NAT traversal e relay público
não estão implementados, e VPN entre redes ainda não foi validada.

O chat de texto direto por Iroh/QUIC mantém um histórico local separado por chave
pública fixada. O destinatário salva a mensagem no SQLCipher antes do ACK; o
remetente salva após receber o ACK. Esse transcript local não usa o event
journal MLS, não sincroniza entre dispositivos e não oferece entrega offline.

Cada app manterá outbox e inbox persistentes em SQLite criptografado,
IDs estáveis de evento,
deduplicação e recibos distintos para salvo localmente, guardado por outro
peer, recebido por dispositivo, lido, expirado ou falhou. Amigos podem aceitar
cópias de **ciphertext** com quota e prazo explícitos. Um helper opcional
oferece a mesma função por mais tempo e pode usar SQLite. Postgres é uma
opção operacional para um helper maior; a entrega entre peers não depende dele.

Mensagens de grupo são cifradas pelo OpenMLS antes de entrar na outbox local.
O registro guarda ID, autor, grupo, época, digest e prazo; o envio usa a sessão
QUIC autenticada pelo pin do dispositivo. O destinatário valida os metadados,
persiste o estado MLS, ciphertext e transcript na mesma transação e então envia
ACK. IDs iguais com bytes ou metadados divergentes são rejeitados.

A inbox e a outbox listam páginas limitadas com cursor estável. Fan-out MLS
registra separadamente o ACK de cada membro da fotografia de destinatários; o
evento global só fecha quando todos confirmam. O consentimento local do helper
já pode ser ativado ou desativado em Settings; estados de cópia delegada,
expiração visível e falha ainda não aparecem como recibos completos de produto.

Uma cópia em helper não prova entrega ao destinatário. Nenhum membro ganha
histórico anterior automaticamente ao ingressar no grupo. A conversa
persistente e o chat temporário da chamada têm retenções diferentes.

Ver [spec detalhada](../architecture/backend.md#5-delivery-and-replication).
