# Slouching fichas

This is the project-level documentation index. The [source architecture PDF](architecture/sources/architecture-p2p-v0.1.pdf) is preserved in full, with a [page-by-page transcript](architecture/sources/README.md). The accepted product decisions and ADRs take precedence over the PDF where they differ. Specifications describe the target; current-slice notes describe implemented code. The frontend and backend code live in separate repositories.

| Domain | Documents |
| --- | --- |
| Architecture | [Product specification](architecture/backend.md), [Elixir backend boundary](architecture/elixir-backend.md), [technology stack](architecture/tech-stack.md), [frontend technology plan](architecture/frontend-tech-stack.md), [client/server integration](architecture/integration.md), [local storage contract](architecture/local-storage.md), [repository map](architecture/workspace.md), [local status API](architecture/local-status-api.md) |
| Frontend | [Eleven-screen specification](frontend/screens.md), [current native slice](frontend/current-slice.md), [Iced design implementation](frontend/iced-design.md) |
| Brand | [Visual style](brand/visual-style.md), [original source bank](brand/source-bank.md), [earlier references](brand/references.md) |
| Identity | [Local identity](identity/identity.md), [signed QR invitation v1](identity/pairing-invite-v1.md) |
| Groups and MLS | [Commit chain](groups/commits.md) |
| Delivery | [Replication](delivery/replication.md) |
| Transport | [Routes](transport/routes.md) |
| Media | [Calls](media/calls.md) |

## Accepted decisions

- [ADR 0001: local state, direct peers, and optional helper](architecture/adr-0001-peer-first.md)
- [ADR 0002: designated MLS committer](groups/adr-0002-designated-committer.md)
- [ADR 0003: native Rust/Iced client](architecture/adr-0003-rust-iced-client.md)
- [ADR 0004: separate code repositories](architecture/adr-0004-separate-repositories.md), stack wording corrected by ADR 0005
- [ADR 0005: Elixir backend and Rust client](architecture/adr-0005-elixir-server-core.md)
- [ADR 0006: local SQLite and optional helper deployment](architecture/adr-0006-local-storage-optional-helper.md)

## Historical material

- [Single-workspace ADR, superseded by ADR 0004](architecture/archive/adr-0004-workspace-superseded.md)
- [Honest web-preview ADR](frontend/adr-0003-honest-prototype.md), limited to the first prototype and superseded as a product-client choice by ADR 0003 above
- [Earlier centralized Elixir server draft](architecture/archive/centralized-draft.md), historical; central storage and server authority assumptions superseded by ADRs 0001 and 0006
