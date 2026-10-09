# Encadeamento de commits MLS

> **Current decisions:** local state and optional helpers remain in force under
> [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md).
> [ADR 0005](../architecture/adr-0005-elixir-server-core.md) defines the
> Elixir backend and Rust client language boundary.

**Estado:** OpenMLS local com committer designado, distribuição direta por
dispositivo e detecção autenticada de equivocation estão implementados no
cliente Rust. Fan-out automático, propostas concorrentes e recuperação após
quarentena continuam pendentes.

O criador de cada grupo registra um **dispositivo membro designado** como
único autor de Commits aceitos no v0.1. Outros membros enviam propostas. Cada
Commit aponta para a época/hash anterior. Uma duplicata idêntica é inofensiva;
dois hashes distintos para o mesmo sucessor indicam equivocação e colocam o
grupo em quarentena. Sem o dispositivo designado, mudanças de membros param.
Se ele se perde definitivamente, membros verificados criam explicitamente um
grupo novo. Não há eleição ou troca silenciosa.

`peer/src/lib.rs` é um experimento de política isolado: confere autor,
predecessor, duplicata e conflito **após** autenticação externa. O produto usa
OpenMLS em `repositories/frontend`: guarda snapshots históricos em SQLCipher,
verifica um Commit conflitante com a assinatura MLS, grupo, epoch, committer
designado e vínculo da identidade do dispositivo. Dois Commits válidos do
committer para o mesmo predecessor geram evidência persistente e quarentena;
o epoch previamente aceito não muda. Dados de rede só entram após validação do
envelope e autenticação criptográfica.

Ver [ADR 0002](adr-0002-designated-committer.md) e
[spec detalhada](../architecture/backend.md#6-mls-commit-rule-one-designated-member-device-v01-decision).
