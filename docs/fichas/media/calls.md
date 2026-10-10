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

Há teste de loopback com dois peers WebRTC: negocia host ICE/DTLS, envia um
quadro Opus/SFrame pela track RTP e verifica amostras decodificadas no sink
remoto. Isso valida o pipeline local de mídia sem hardware físico. Ainda falta
testar captura e reprodução reais entre dois computadores, incluindo VPN, perda
de pacotes e reconexão. A chamada exige que ambos estejam no mesmo grupo MLS
de chamada e conectados pelo peer pinado.

O botão de microfone silencia localmente os quadros de saída sem encerrar a
captura. O teste local de microfone em **Áudio & vídeo** continua separado da
chamada. Câmera, compartilhamento de tela, supressão de ruído, cancelamento de
eco, push-to-talk, TURN e descoberta automática não estão implementados. As
cenas e miniaturas continuam sendo prévias visuais.

Ver [spec detalhada](../architecture/backend.md#7-calls-files-and-temporary-room-chat).
