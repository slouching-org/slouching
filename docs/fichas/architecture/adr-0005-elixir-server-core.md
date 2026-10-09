# ADR 0005 — Elixir backend and Rust client

**Status:** accepted language correction, 2026-10-08; deployment and storage
clarified by [ADR 0006](adr-0006-local-storage-optional-helper.md) on 2026-10-09.

## Context

The owner explicitly clarified that Elixir remains the backend core and
Rust/Iced remains the client. The earlier Rust-only backend scaffold did
not follow that language division. The source PDF supplies the same
language direction, but its central deployment assumptions are governed
by the later peer-first decisions.

## Decision

Build backend service components in Elixir/OTP. Keep the UI and local
cryptography, storage, peer networking, and media components in Rust.
Preserve [ADR 0001](adr-0001-peer-first.md): local state, direct peer paths,
and an optional member-operated helper. Choosing Elixir does not require
PostgreSQL or a permanently available hosted service.

The `server/` Mix application is the current Elixir development scaffold.
It provides loopback diagnostics and a protobuf WebSocket handshake with
Ping/Pong. It does not yet implement identity, MLS, peer delivery, or calls.

## Consequences

The existing Rust `peer/` crate remains an experiment and policy-gate
reference; it is not the adopted Elixir backend. The product specification
in [backend.md](backend.md) retains its peer-first behavior, with language
ownership corrected by this ADR. [ADR 0006](adr-0006-local-storage-optional-helper.md)
defines the storage and deployment rules that implementation must follow.
