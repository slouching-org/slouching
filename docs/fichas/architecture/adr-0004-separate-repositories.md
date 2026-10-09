# ADR 0004 — Separate frontend and backend repositories

**Status:** accepted by the owner on 2026-10-08. Language ownership follows
[ADR 0005](adr-0005-elixir-server-core.md); deployment follows
[ADR 0006](adr-0006-local-storage-optional-helper.md).

## Context

The first implementation used one Cargo workspace and Git repository.
The owner directed the project to use separate organization repositories.

## Decision

`slouching-org/slouching-frontend` owns the Rust/Iced UI, visual sources, and
local Rust client components. `slouching-org/slouching-backend` owns Elixir
backend services and their protocol/domain documentation. The older Rust
`peer/` crate is preserved there as an experiment.

`slouching-org/slouching` is the project entry point, design bank, and
cross-repository specification. Submodules pin the code snapshots described
by its implementation notes. Releases must identify compatible frontend
and backend commits and test their shared contracts.

The current loopback HTTP status and protobuf WebSocket are development
surfaces. Production transport, local process packaging, and lifecycle
remain implementation work.

## Consequences

Repository separation does not require a hosted server or PostgreSQL.
Local state remains on each device, and any crew-operated helper remains
optional. Cross-repository CI, packaging, and release coordination must
preserve those product requirements.
