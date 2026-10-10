# Rotas entre pares

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** endereço direto por IP manual implementado para sessões de texto
persistentes nos dois sentidos na LAN. A tela de conexão agora pode procurar
listeners ativos com mDNS e preencher uma rota no chat; o anúncio leva um ID
efêmero, porta e endereços, nunca a chave pública. Esses dados são dicas sem
confiança e mDNS não atravessa VPN. O protocolo também transporta sinalização
limitada de chamada (oferta, resposta, ICE e encerramento) em sessão pinada; o
controlador WebRTC aceita ofertas após validar o grupo MLS e aguarda decisão
explícita do usuário antes de abrir o microfone. O cliente também aceita um
relay Iroh 1.3 operado por membro, configurado explicitamente por HTTPS e token; uma
troca autenticada de mensagem/ACK foi testada com servidor local. Descoberta de
contatos por diretório remoto e hole-punching continuam pendentes. Pareamento
via QR e código de uso único está disponível em caráter experimental. Em uma
sessão QUIC direta autenticada, cada dispositivo salva o endereço IP ativo que
Iroh observou para a chave pinada do peer; uma sessão via relay não é salva como
rota IP. Esse endereço é apenas uma rota aprendida, pode ficar obsoleta e não
substitui a verificação de identidade. VPN entre máquinas e relay remoto ainda
precisam de validação.

Na mesma rede local ou VPN, dois clientes Rust podem trocar chaves públicas,
usar o IP/porta manual do receptor e se autenticar diretamente pela chave
fixada. A VPN precisa transportar UDP; a conexão entre máquinas em VPN ainda
não foi validada. Na internet, rota direta depende de endereçamento, NAT e
firewall. Um membro pode manter um endpoint público ou um relay/SFU em PC ou
VPS. O relay do cliente pode servir como fallback quando o usuário configura
URL HTTPS e token; nenhum serviço de terceiro é habilitado silenciosamente.

TURN/Iroh relay transporta dados cifrados; SFU encaminha mídia de grupo. A interface
distingue rota direta, relay, SFU e indisponível, com medições reais. Sem rota
permitida, mostra erro em vez de conexão fictícia.

Ver [spec detalhada](../architecture/backend.md#4-connection-modes).
