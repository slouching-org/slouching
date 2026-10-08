# Slouching fichas

This is the project-level documentation index. The [source architecture PDF](architecture/sources/architecture-p2p-v0.1.pdf) is preserved in full, with a [page-by-page transcript](architecture/sources/README.md). Specifications describe the target; current-slice notes describe implemented code. The frontend and backend code live in separate repositories.

| Domain | Documents |
| --- | --- |
| Architecture | [Peer-first backend specification](architecture/backend.md), [backend technology stack](architecture/tech-stack.md), [frontend technology plan](architecture/frontend-tech-stack.md), [repository map](architecture/workspace.md), [local status API](architecture/local-status-api.md) |
| Frontend | [Eleven-screen specification](frontend/screens.md), [current native slice](frontend/current-slice.md) |
| Brand | [Visual style](brand/visual-style.md), [original source bank](brand/source-bank.md), [earlier references](brand/references.md) |
| Identity | [Local identity](identity/identity.md) |
| Groups and MLS | [Commit chain](groups/commits.md) |
| Delivery | [Replication](delivery/replication.md) |
| Transport | [Routes](transport/routes.md) |
| Media | [Calls](media/calls.md) |

## Accepted decisions

- [ADR 0001: peer-first core](architecture/adr-0001-peer-first.md)
- [ADR 0002: designated MLS committer](groups/adr-0002-designated-committer.md)
- [ADR 0003: native Rust/Iced client](architecture/adr-0003-rust-iced-client.md)
- [ADR 0004: separate code repositories](architecture/adr-0004-separate-repositories.md)

## Historical material

- [Single-workspace ADR, superseded by ADR 0004](architecture/archive/adr-0004-workspace-superseded.md)
- [Honest web-preview ADR](frontend/adr-0003-honest-prototype.md), limited to the first prototype and superseded as a product-client choice by ADR 0003 above
- [Centralized-server draft](architecture/archive/centralized-draft.md), superseded by ADR 0001
