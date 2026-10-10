# Chamadas e captura

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** chamadas diretas agora integram sinalização WebRTC pelo canal QUIC
pinado, tracks RTP de Opus e proteção SFrame baseada no grupo MLS exclusivo da
chamada. Oferta e resposta validam grupo, época e identidade do membro. ICE usa
candidatos host reunidos no SDP. Ofertas recebidas aguardam aceite ou recusa
explícita antes de montar a conexão; o microfone só começa depois do aceite e
de ICE/DTLS conectar.

O cliente captura o microfone escolhido via CPAL, converte para mono 48 kHz em
quadros de 20 ms, codifica Opus, protege os quadros com SFrame e os envia por
RTP. No recebimento, valida SFrame, rejeita replay, decodifica Opus e envia PCM
para a saída selecionada, com conversão para a taxa padrão do dispositivo. Os
dispositivos escolhidos ficam em memória durante a sessão do app.

O painel **Chat temporário** envia texto pelo DataChannel confiável da chamada,
protegido pela chave SFrame do grupo MLS de chamada. Cada mensagem tem limite
de 4 KiB e o cliente mantém no máximo 100 mensagens visíveis em memória. O
transcript não entra no SQLite, não sincroniza histórico para quem entra tarde
e é apagado ao terminar a chamada. O loopback valida envio e recepção nos dois
sentidos; não há confirmação de entrega ou leitura.

Há teste de loopback com dois peers WebRTC: negocia host ICE/DTLS, envia um
quadro Opus/SFrame pela track RTP e verifica amostras decodificadas no sink
remoto. Isso valida o pipeline local de mídia sem hardware físico. Ainda falta
testar captura e reprodução reais entre dois computadores, incluindo VPN, perda
de pacotes e reconexão. A chamada exige que ambos estejam no mesmo grupo MLS
de chamada e conectados pelo peer pinado. O cliente mantém uma sessão WebRTC
remota por dispositivo; grupos MLS de chamada podem ter mais membros, mas
chamadas mesh com três ou mais participantes ainda não existem.

O backend Elixir agora tem um coordenador efêmero de sala e componentes para
responder ofertas WebRTC, criar uma saída de áudio por membro remoto autorizado,
encaminhar RTP opaco e repassar mensagens binárias limitadas pelo DataChannel
confiável `slouching-call-v1`. Cada dispositivo precisa assinar o mesmo ID de
chamada, grupo MLS, época e roster; o cliente deve derivar o roster do estado
MLS local. O coordenador não verifica MLS independentemente. A rota autenticada
do gateway e um modo experimental do cliente Rust já fazem o join assinado e a
negociação SDP/ICE com o SFU. Para usar esse modo, ambos os clientes precisam
configurar `SLOUCHING_SFU_WS_URL` para o mesmo helper, abrir o mesmo grupo MLS
de chamada de dois dispositivos e iniciar a chamada pelo painel **Chamada**.
O SFU não precisa do transporte P2P direto para encaminhar mídia. O smoke test
local usa dois clientes Rust e valida autenticação, admissão, SDP, ICE/DTLS e
áudio Opus/SFrame encaminhado pelo helper. Ainda faltam teste com dispositivos
físicos e validação em redes distintas. Chamadas com mais de duas
pessoas e convite/aceite coordenado pelo helper ainda não estão disponíveis.

Quando a época do grupo de chamada avança ou o grupo entra em quarentena, o
cliente silencia os quadros imediatamente e encerra a sessão WebRTC antiga; os
membros precisam sincronizar a nova época e renegociar a chamada.

O botão de microfone silencia localmente os quadros de saída sem encerrar a
captura. O teste local de microfone em **Áudio & vídeo** continua separado da
chamada. **Escolher tela** enumera monitores e captura uma imagem local sob
demanda para prévia. Durante uma chamada ativa, **Compartilhar tela na chamada**
captura a tela selecionada, codifica quadros H.264, protege cada quadro com a
chave SFrame do grupo MLS e envia fragmentos limitados por DataChannel. O peer
remonta, autentica e decodifica o quadro antes de exibi-lo; parar o
compartilhamento limpa a imagem remota. Testes locais cobrem codec, proteção,
fragmentação, entrega WebRTC, decodificação e sinal de parada. Ainda falta
validar captura/permissões entre computadores reais e por VPN. A aba **Janelas**
enumera janelas visíveis, permite prévia local explícita e compartilha quadros
H.264/SFrame pelo mesmo canal de vídeo da tela e da câmera. No Linux, X11 usa
xcap; em Wayland puro, o portal ScreenCast seleciona a janela e fornece quadros
PipeWire para a prévia ou chamada. O portal precisa oferecer fontes de janela;
a validação em compositores reais ainda falta. Supressão de ruído, cancelamento
de eco, push-to-talk, TURN e descoberta automática ainda não estão
implementados. O modo SFU ainda está em validação ponta a ponta.

A aba **Câmera** enumera dispositivos V4L2, Media Foundation ou AVFoundation.
Uma prévia abre a câmera apenas após ação explícita. Durante uma chamada, a
câmera selecionada pode enviar quadros H.264/SFrame no mesmo canal e estágio de
vídeo que a tela; apenas uma fonte pode ser enviada por vez. A captura limita
quadros a 1920 × 1080 e mantém no máximo dois quadros aguardando codificação.
A enumeração foi exercitada neste ambiente, mas acesso, permissões, reprodução
remota física e vídeo por VPN ainda precisam de teste em máquinas reais.

Ver [spec detalhada](../architecture/backend.md#7-calls-files-and-temporary-room-chat).
