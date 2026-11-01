# TODO

Optional follow-ups after the 0.3.0 release. Not blockers for day-to-day use.

## Annotation refresh

- When RAP-DB publishes a newer RAP–MSU table or representative annotation, rerun:

  ```bash
  Rscript inst/scripts/make-orgdb.R
  ```

  Then bump `Version` in `DESCRIPTION`, update `NEWS.md` / README snapshot date, and cut a new GitHub Release.

## CI matrix

- If broader pre-release coverage is needed, switch or add the r-lib `check-standard` workflow (Linux / macOS / Windows, multiple R versions):

  ```r
  usethis::use_github_action("check-standard")
  ```

  Keep `check-release` for fast PR feedback unless multi-OS issues appear.

## Bioconductor path (optional)

- Formal Bioconductor submission is not required for this GitHub OrgDb.
- If pursuing Bioconductor later, evaluate `biocthis::use_bioc_github_action()` and `BiocCheck`, plus Bioconductor versioning / `biocViews` rules.
- Note: Bioconductor submission has strict large-file limits; the packaged sqlite may need a different distribution path (for example AnnotationHub).

## Zenodo DOI for 0.3.0 (in progress)

Waiting on one manual step: enable Zenodo–GitHub for `SiYangming/org.Osativa.eg.db`.

1. Open https://zenodo.org/account/settings/github/ (log in with GitHub if needed).
2. Click **Sync now**, find `SiYangming/org.Osativa.eg.db`, toggle it **On**.
3. Reply in chat with either:
   - “已开启”, or
   - the new DOI if Zenodo already created one.

Then we will trigger archival of `v0.3.0` (or cut a tiny follow-up release if needed), update the README badge to the new DOI, and keep the old `10.5281/zenodo.3374105` only as the original v0.01 citation.
