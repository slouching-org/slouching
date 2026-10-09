# Rotas entre pares

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** endereço direto por IP manual implementado para um teste de texto
de uma mensagem na LAN; descoberta, pareamento de contatos, relay e travessia
de NAT continuam não implementados.

Na mesma rede local, dois clientes Rust podem trocar chaves públicas, usar o
IP/porta manual do receptor e se autenticar diretamente pela chave fixada.
Na internet, rota direta depende de endereçamento,
NAT e firewall. Um membro pode manter um endpoint público ou um relay/SFU em
PC ou VPS. Nenhum serviço de terceiro deve ser habilitado silenciosamente.

TURN/relay transporta bytes; SFU encaminha mídia de grupo. A interface
distingue rota direta, relay, SFU e indisponível, com medições reais. Sem rota
permitida, mostra erro em vez de conexão fictícia.

Ver [spec detalhada](../architecture/backend.md#4-connection-modes).
