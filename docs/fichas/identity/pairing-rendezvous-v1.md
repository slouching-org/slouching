# SPAKE2 rendezvous helper v1 (experimental)

**Status:** the optional Elixir helper exposes a volatile HTTP rendezvous API.
The Rust/Iced client does not call it yet, and this is not a complete contact
pairing feature.

## Session contract

- `POST /api/pairing-sessions` creates a session and returns a 256-bit random
  `session_id`, a 120-second expiry, one SPAKE2 message and one confirmation
  message per role, and a single attempt per session.
- The session ID is a bearer capability sent in the `Authorization: Bearer`
  header. Share it only with the intended participant; anyone holding it can
  read, submit, or cancel that session. Proxies must redact this header.
- Roles are `inviter` and `invitee`; stages are `spake2` and `confirm`.
- `POST /api/pairing-sessions/{role}/{stage}` accepts JSON
  `{"message":"<base64>"}`. SPAKE2 messages must decode to exactly 33 bytes;
  confirmation tags must decode to exactly 32 bytes. A role may submit each
  stage once. Confirmation is rejected until both SPAKE2 messages exist. These
  requests require the session ID bearer header.
- `GET /api/pairing-sessions/{role}/{stage}` returns the other role's message,
  or HTTP 202 while it is pending. Errors distinguish invalid input, duplicate
  submission, missing sessions, and expiry. `DELETE /api/pairing-sessions`
  cancels the session when sent with the bearer header.
- The service keeps at most 10,000 sessions in memory. Sessions expire after
  120 seconds and are swept every 30 seconds. Restarting the process removes
  all outstanding sessions. There is no database migration for rendezvous.

The helper stores only public SPAKE2 messages and confirmation tags. It does
not receive the pairing code, exchange device identities, verify a person, or
decide which key should be trusted. An optional helper still sees session IDs,
network metadata, and the opaque exchange messages; use HTTPS for any remote
deployment. The default listener binds to loopback. Set `SLOUCHING_BIND_IP` to
an explicit interface address behind a TLS endpoint to accept remote clients.

The one-exchange budget means a failed code requires creating a new session and
fresh code. The helper does not implement per-IP quotas or protect availability
from a holder of the session ID; the global cap bounds memory but can be used
to deny new sessions. The client must generate a fresh 100-bit code per
session, enforce the 120-second deadline, and expose cancellation.

## Client work still required

The Iced client must create a helper session, exchange both SPAKE2 messages and
key confirmations, and then exchange the signed device identities bound to the
confirmed transcript. Both devices must show the resulting identity and ask
the user before saving a contact as trusted. The flow must expire/cancel cleanly
and keep QR/manual pairing available when no helper is configured. It must
also test an incorrect code, helper loss, replay, and a real two-device
exchange. Until then, use the signed QR route or compare the full device-key
fingerprint out of band.

## HTTP examples

```sh
curl -X POST http://127.0.0.1:3707/api/pairing-sessions
curl -X POST http://127.0.0.1:3707/api/pairing-sessions/inviter/spake2 \
  -H 'authorization: Bearer <session-id>' \
  -H 'content-type: application/json' \
  -d '{"message":"<base64-33-byte-message>"}'
curl http://127.0.0.1:3707/api/pairing-sessions/inviter/spake2 \
  -H 'authorization: Bearer <session-id>'
```

The `spake2-prototype.md` document specifies the client-side experimental
cryptographic building block and its security limits.
