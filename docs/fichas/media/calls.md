# Chamadas e captura

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** sinalização WebRTC já está conectada à tela de chamada e à sessão
QUIC pinada. A oferta/resposta valida grupo, época MLS e identidade do membro;
ICE local usa candidatos host reunidos no SDP. Testes cobrem ICE/DTLS em loopback
e a troca de quadros de sinalização QUIC. Ainda não há chamada de áudio/vídeo
utilizável entre dispositivos nem teste por VPN.

O cliente agora também tem um codec de voz isolado: Opus mono a 48 kHz em quadros
de 20 ms, seguido de proteção/autenticação SFrame com a chave do grupo MLS.
Testes locais cobrem codificar, proteger, decifrar, decodificar e rejeitar replay,
além do tamanho e dos valores inválidos de entrada. Este codec ainda não está
ligado à captura CPAL, a tracks WebRTC ou à reprodução de áudio.

O painel enumera dispositivos via CPAL e permite pré-seleção em memória. Uma
ação explícita abre o microfone selecionado para medir nível RMS local; samples
não são salvos nem enviados, e o fluxo fecha ao sair da tela/aba. A seleção
ainda não é consumida pelo pipeline da chamada. Vídeo e tela permanecem como
prévias visuais.

O cliente agora contém um módulo isolado de proteção SFrame para quadros de
mídia codificados, com chave por membro/época, limite de tamanho e rejeição de
replay. A persistência MLS diferencia grupos de chamada e conversa, transporta
essa finalidade no Welcome autenticado e expõe um exportador de chave de mídia
que rejeita grupos de conversa e grupos em quarentena. O remetente SFrame usa o
índice da folha MLS local autenticada; o receptor resolve a chave pública do
dispositivo remetente para o índice atual do grupo. Um teste com dois perfis
confirma índices distintos e cifra/decifra um quadro usando a chave exportada
compartilhada. A tela de chamada pode criar um grupo isolado, copiar seu ID e
abrir o fluxo MLS existente para convidar participantes. O pipeline Opus/SFrame
é um limite de codec testado, mas ainda não envia quadros SFrame por RTP/WebRTC;
captura e reprodução também permanecem pendentes.

Uma chamada tem grupo MLS separado contendo somente seus participantes.
Áudio/vídeo usam chaves derivadas desse grupo; membros da conversa que não
entraram não recebem chaves de mídia. Dois peers tentam rota direta. Mesh
atende grupos pequenos dentro de limites medidos; SFU operado por membro é
opcional. Captura de microfone, câmera, tela e áudio de sistema respeita
permissões do SO.

Hoje a tela de chamada ainda usa cenas JPEG e controles demonstrativos para
microfone/câmera/tela. A ação **Negociar WebRTC** inicia apenas a negociação
direta depois de conectar ao peer pinado e convidá-lo ao grupo MLS. A tela deixa
claro que mídia ainda não está conectada.

Ver [spec detalhada](../architecture/backend.md#7-calls-files-and-temporary-room-chat).
