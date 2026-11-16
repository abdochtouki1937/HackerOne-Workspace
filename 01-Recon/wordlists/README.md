# Recon wordlists

This folder is a pointer, not a second copy. The wordlists live in
`05-Wordlists/` — use them from there so every program uses the same
lists and updates happen in one place.

```bash
ffuf -w ../../05-Wordlists/common-directories.txt -u https://TARGET/FUZZ -mc 200,301,302,403 -rate 20
```

See `05-Wordlists/README.md` for what each list is for.
