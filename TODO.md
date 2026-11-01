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

## Zenodo DOI for 0.3.0

- The README DOI badge still points at the original v0.01 Zenodo record (`10.5281/zenodo.3374105`).
- To mint a DOI for **0.3.0**, enable the Zenodo–GitHub integration on this repository and create/publish a new versioned record from the `v0.3.0` release; do not reuse the old DOI for the new annotation snapshot.
