# Slouching fichas

This is the project-level documentation index. The [source architecture PDF](architecture/sources/architecture-p2p-v0.1.pdf) is preserved in full, with a [page-by-page transcript](architecture/sources/README.md). Specifications describe the target; current-slice notes describe implemented code. The frontend and backend code live in separate repositories.

| Domain | Documents |
| --- | --- |
| Architecture | [Elixir backend boundary](architecture/elixir-backend.md), [technology stack](architecture/tech-stack.md), [frontend technology plan](architecture/frontend-tech-stack.md), [client/server integration](architecture/integration.md), [repository map](architecture/workspace.md), [local status API](architecture/local-status-api.md) |
| Frontend | [Eleven-screen specification](frontend/screens.md), [current native slice](frontend/current-slice.md) |
| Brand | [Visual style](brand/visual-style.md), [original source bank](brand/source-bank.md), [earlier references](brand/references.md) |
| Identity | [Local identity](identity/identity.md) |
| Groups and MLS | [Commit chain](groups/commits.md) |
| Delivery | [Replication](delivery/replication.md) |
| Transport | [Routes](transport/routes.md) |
| Media | [Calls](media/calls.md) |

## Accepted decisions

- [ADR 0001: local key custody and direct peer preference](architecture/adr-0001-peer-first.md), scoped by ADR 0005
- [ADR 0002: designated MLS committer](groups/adr-0002-designated-committer.md)
- [ADR 0003: native Rust/Iced client](architecture/adr-0003-rust-iced-client.md)
- [ADR 0004: separate code repositories](architecture/adr-0004-separate-repositories.md), stack wording corrected by ADR 0005
- [ADR 0005: Elixir service backend and Rust client](architecture/adr-0005-elixir-server-core.md)

## Historical material

- [Single-workspace ADR, superseded by ADR 0004](architecture/archive/adr-0004-workspace-superseded.md)
- [Honest web-preview ADR](frontend/adr-0003-honest-prototype.md), limited to the first prototype and superseded as a product-client choice by ADR 0003 above
- [Earlier Elixir server draft](architecture/archive/centralized-draft.md), historical design input requiring reconciliation with ADR 0005
- [Rust peer-backend proposal](architecture/backend.md), superseded by ADR 0005
