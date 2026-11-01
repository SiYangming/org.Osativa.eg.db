# org.Osativa.eg.db 0.3.1

Citation/metadata release to archive the package on Zenodo after enabling
the GitHub–Zenodo webhook. Annotation content is the same as 0.3.0
(RAP-DB 2026-02-05 snapshot).

# org.Osativa.eg.db 0.3.0

Maintainer for this release: siyangming. Original package author xuzhougeng is retained as author.

## Annotation refresh

- Taxonomy ID corrected to NCBI 39947 (*Oryza sativa* Japonica Group).
- RAP–MSU conversion updated to RAP-DB `RAP-MSU_2026-02-05`.
- GO annotations replaced: previous MSU Release 7 GO slim (IEA via TAIR) is
  no longer used. GO now comes from RAP-DB
  `IRGSP-1.0_representative_annotation_2026-02-05`, mapped onto MSU `GID`.
- RAP-DB does not provide evidence codes in that file; `EVIDENCE` is set to
  `IEA`.
- Central ID remains MSU `GID`; RAP locus IDs remain available as keytype
  `RAP` for bidirectional `mapIds()` / `select()` and for
  `enrichGO(..., keyType = "RAP")`.
- Rebuild script lives at `inst/scripts/make-orgdb.R`.

## Package metadata

- Version set to 0.3.0.
- DESCRIPTION, README, and package checks updated for modern OrgDb use.
