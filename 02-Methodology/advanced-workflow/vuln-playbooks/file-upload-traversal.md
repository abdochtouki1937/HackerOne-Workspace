# File Upload and Path Traversal

CWE-434, CWE-22. TBHM files `07_File_Upload.md`, `06_SQLi.md` (file
inclusion).

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything. Read a file you own
first; only ever target your own test data.

**Trigger conditions.** Any file upload (avatar, attachment, import),
any parameter that names a file or a path (download, export, include,
template name, theme, language file), any archive extraction, any
"import from URL" that writes to disk.

**The exact test.**

1. **Upload — bypass matrix, one variant per request.** Upload a file
   with: a double extension (`file.jpg.php`, `file.php.jpg`), a case
   change (`file.PHP`, `file.PhP`), a content-type mismatch (PHP
   content with `image/jpeg`), a trailing dot/space, a null byte
   where the program allows testing it. After each upload, record
   where it lands and how it is served: content type,
   content-disposition, same origin or a separate domain.
2. **Upload — serving context is the finding.** A file served as
   HTML/JS from the app's origin is the finding (stored XSS via
   upload — see `xss.md`). An SVG served as `image/svg+xml` from the
   app origin can execute script; the same SVG served with
   `Content-Disposition: attachment` from a separate domain is safe.
   Check both headers, not just the upload success.
3. **Traversal — read your own file first.** Request a file by path
   and try `../` sequences, URL encodings (`%2e%2e%2f`,
   `%2e%2e/`), double encodings, and separators (`..\;`,
   `....//`). First read a file you own (your own upload) through
   the same parameter to prove the channel works, then try one step
   outside the intended directory — on your own test data only.
   Never read another user's files, credentials, or system files.
4. **Traversal — variants, one at a time.** Absolute paths, `..;/`,
   backslash on Windows targets, null-byte termination where the
   program allows it, and path parameters that are joined without
   normalisation. Record the exact response for each: status, body,
   and whether any file content came back.
5. **Archive / symlink.** Where archives are extracted, test whether
   a symlink inside the archive is followed, and whether a
   `../` entry in the archive escapes the extraction directory
   (Zip-Slip). Sandcastle C-01 pattern: a symlink window, verified
   end-to-end in a sandbox. Only in a lab or on your own test
   instance — never against a shared service.
6. **File inclusion (LFI/RFI).** Where a parameter names a template,
   language file, or view, try a local file you own, then a path
   outside the intended directory. For remote inclusion, point it at
   a URL you control and watch for an out-of-band fetch (cf.
   `ssrf.md` — the callback proves the fetch; the inclusion proves
   the impact).

**Common false positives.**

- An upload that is stored but served with a safe content type and a
  `Content-Disposition: attachment` from a separate domain.
- A traversal probe that returns a generic error with no file content
  (the error text alone is not a read).
- An upload that the server renames, re-encodes, or strips to a safe
  format (e.g. images re-encoded) — the bypass failed, even if the
  upload returned 200.
- A path parameter that is validated against an allowlist of names
  (the `../` is rejected before any file access — record the
  rejection, do not keep spraying encodings at a dead check).

**What proof looks like.** The file served and executed/rendered in
the wrong context (e.g. your SVG/HTML executing from the app origin
in B's view), or the content of a file outside the intended directory
that you own — saved, with the request. For archives: the extracted
file landing outside the extraction directory in your own lab.

**Grounded examples / related cases.**

- **Hostinger (lead, wave 2 plan):** file-content read on another
  account's files via a `{username}`-keyed endpoint — the same
  A-vs-B test as `idor.md`, with a path/traversal flavour: A's
  request for B's file path. Test read first, then write.
- **Sandcastle C-01 (lab-verified pattern):** symlink window during
  archive extraction, verified end-to-end in a sandbox — the model
  for testing symlink/archive handling only in a lab.
- **Slack (negative control):** `javascript:` / `data:` links that
  the web client renders as plain text / `about:blank` were dead in
  the client however interesting they looked API-side. The same
  discipline applies here: an upload that is stored but safely
  served is not a finding.
