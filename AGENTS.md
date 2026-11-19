# AGENTS.md

The umbrella repository for Slouching, a peer-first desktop app for a small
crew to chat, call and share a screen. It holds the project overview, the
documentation set (fichas and ADRs), the design sources, the canonical
protobuf schema and the cross-repository scripts. Product code lives in two
other repositories, pinned here as submodules:

| Submodule | Repository | Contents |
| --- | --- | --- |
| `repositories/frontend` | `slouching-frontend` | Native Rust/Iced desktop client |
| `repositories/backend` | `slouching-backend` | Optional Elixir/OTP helper |

The README is long and parts of it lag behind the code. Where a document and
the code disagree, trust the code.

## Commands

```sh
./scripts/check-proto-sync.sh              # no submodules needed
shellcheck scripts/*.sh
git submodule update --init --recursive    # the frontend alone is about 140 MB
./scripts/check-integration.sh             # every gate of both repositories plus the smoke tests
```

CI (`.github/workflows/ci.yml`) runs the first two plus the three live-helper
smoke scripts (gateway/SFU, pairing, and mailbox) against the pinned submodules.

`check-integration.sh` and the `smoke-*.sh` scripts need initialized
submodules, both toolchains (Rust with `protoc`, Elixir), python3 and curl.
Each smoke test starts a real helper on a free loopback port with a temporary
SQLite database and runs the client tests that are `#[ignore]`d elsewhere.

## Layout

| Path | Contents |
| --- | --- |
| `README.md` | Project overview and current state |
| `docs/fichas/` | Specifications, current-state notes and ADRs by domain; start at `docs/fichas/README.md` |
| `docs/design/` | Design board source, exported screens, references and README images |
| `design/` | Earlier eight-screen design guide, kept as history |
| `proto/` | Canonical `slouching/v1/handshake.proto` |
| `scripts/` | Cross-repository checks |
| `repositories/` | The two submodules |

## Conventions

- `proto/slouching/v1/handshake.proto` is the canonical schema. The frontend
  and backend each carry a byte-identical copy. To change it: edit it here,
  copy it to both repositories, regenerate the backend's `handshake.pb.ex`,
  then move the submodule pins. `check-proto-sync.sh` fails while the pinned
  commits carry a different schema.
- A submodule pin usually moves in the same commit as the documentation
  that describes the change.
- Fichas separate the target from the present: specifications describe what
  is planned, current-slice notes describe what the code does. Keep that
  distinction and never describe planned behaviour as working.
- The accepted ADRs listed in `docs/fichas/README.md` override the source
  architecture PDF. Superseded documents are kept and listed there as
  historical material.
- Documents are written in English or Portuguese; keep the language of the
  file you are editing.
- `docs/design/source/` is preserved byte-for-byte. Do not reformat it.
- Shell scripts use `set -euo pipefail`, two-space indentation and pass
  shellcheck.
- Commit subjects are short imperative sentences without a prefix.

## Known gaps

- There is no LICENSE file yet; the team has to choose one.
- `proto/README.md` still describes protocol version 1; both code
  repositories speak version 2.
