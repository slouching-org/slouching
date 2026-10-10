# Chamadas e captura

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** chamadas não implementadas. O painel enumera dispositivos de áudio
via CPAL e permite pré-seleção em memória. Uma ação explícita abre o microfone
selecionado para medir nível RMS local; samples não são salvos nem enviados, e
o fluxo fecha ao sair da tela/aba. A seleção não é consumida por uma chamada.
Vídeo e tela permanecem como prévias visuais.

Uma chamada tem grupo MLS separado contendo somente seus participantes.
Áudio/vídeo usam chaves derivadas desse grupo; membros da conversa que não
entraram não recebem chaves de mídia. Dois peers tentam rota direta. Mesh
atende grupos pequenos dentro de limites medidos; SFU operado por membro é
opcional. Captura de microfone, câmera, tela e áudio de sistema respeita
permissões do SO.

Hoje a tela de chamada no repositório de frontend usa cenas JPEG e controles
**demonstrativos**. Não abre
dispositivos nem conecta peers. Exibe essa limitação no cabeçalho, no rodapé
e nos estados de ação.

Ver [spec detalhada](../architecture/backend.md#7-calls-files-and-temporary-room-chat).
