# Wordlists

Starter wordlists for recon and content discovery. These are the lists
actually used every day — small, curated, and fast. For the big lists,
use `download-seclists.sh`.

## Included lists

| File | Lines | What it is for |
| ---- | ----- | -------------- |
| common-subdomains.txt | ~6,500 | Subdomain brute force (ffuf / gobuster dns) |
| common-directories.txt | ~8,500 | Content discovery (ffuf / gobuster dir) |
| common-api-endpoints.txt | ~2,300 | API path discovery |
| backup-files.txt | ~3,900 | Backup / archive file discovery |
| sensitive-files.txt | ~200 | Exposed sensitive files (.env, .git, keys) |
| file-extensions.txt | ~100 | File extension fuzzing |
| graphql-endpoints.txt | ~700 | GraphQL endpoint discovery |
| graphql-fields.txt | ~500 | GraphQL field names |
| js-files.txt | ~145 | Common JavaScript file names |

## Deliberately NOT included

Password and username lists are not copied here. Credential
brute-forcing is forbidden on almost every HackerOne program, and a
password list in the workspace invites a mistake. If you need one for
a lab (never a live program), SecLists has them — see below.

## Bigger lists

```bash
bash download-seclists.sh
```

This clones [SecLists](https://github.com/danielmiessler/SecLists)
(shallow, depth 1) into `05-Wordlists/SecLists/`. It is large — only
run it when you need it. Other references:

- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
  — payloads and bypasses, organised by vulnerability class.
- [vavkamil/awesome-bugbounty-tools](https://github.com/vavkamil/awesome-bugbounty-tools)
  — wordlist and fuzzing tool lists.

## Rules

- Dedupe every list with `sort -u` before use.
- Start with the small lists. A 6,500-word subdomain list that finishes
  in a minute beats a 2-million-word list that gets you rate-limited.
- Never run a wordlist against a login, reset, or OTP endpoint.
