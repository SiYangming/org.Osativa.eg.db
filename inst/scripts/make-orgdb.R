#!/usr/bin/env Rscript

# Rebuild org.Osativa.eg.db from RAP-DB 2026-02-05 releases.
#
# Inputs (downloaded into data-raw/):
#   https://rapdb.dna.naro.go.jp/download/archive/RAP-MSU_2026-02-05.txt.gz
#   https://rapdb.dna.naro.go.jp/download/archive/irgsp1/IRGSP-1.0_representative_annotation_2026-02-05.tsv.gz
#
# Central ID remains MSU LOC_Os* (GID). RAP IDs are stored as keytype RAP.
# GO terms are parsed from RAP representative annotation and mapped to MSU.
# Source files do not provide evidence codes; EVIDENCE is set to IEA.

suppressPackageStartupMessages({
  library(AnnotationForge)
  library(RSQLite)
  library(tidyr)
})

options(stringsAsFactors = FALSE)

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) == 1) {
  script_path <- normalizePath(sub("^--file=", "", file_arg))
  pkg_root <- normalizePath(file.path(dirname(script_path), "..", ".."))
} else if (file.exists("DESCRIPTION") || file.exists("build.R") || dir.exists("data-raw")) {
  pkg_root <- normalizePath(getwd())
} else {
  stop("Run this script from the package root or via Rscript path/to/make-orgdb.R")
}
data_raw <- file.path(pkg_root, "data-raw")
dir.create(data_raw, showWarnings = FALSE, recursive = TRUE)

rap_msu_url <- "https://rapdb.dna.naro.go.jp/download/archive/RAP-MSU_2026-02-05.txt.gz"
rap_ann_url <- "https://rapdb.dna.naro.go.jp/download/archive/irgsp1/IRGSP-1.0_representative_annotation_2026-02-05.tsv.gz"
rap_msu_file <- file.path(data_raw, "RAP-MSU_2026-02-05.txt.gz")
rap_ann_file <- file.path(data_raw, "IRGSP-1.0_representative_annotation_2026-02-05.tsv.gz")

download_if_needed <- function(url, dest) {
  if (!file.exists(dest) || file.info(dest)$size == 0) {
    message("Downloading ", url)
    download.file(url, dest, mode = "wb", quiet = TRUE)
  } else {
    message("Using existing ", dest)
  }
}

download_if_needed(rap_msu_url, rap_msu_file)
download_if_needed(rap_ann_url, rap_ann_file)

strip_tx <- function(x) {
  sub("\\.[0-9]+$", "", x)
}

# RAP <-> MSU conversion -------------------------------------------------
rap_msu <- read.delim(
  gzfile(rap_msu_file),
  header = FALSE,
  sep = "\t",
  quote = "",
  comment.char = "",
  col.names = c("RAP", "MSU"),
  stringsAsFactors = FALSE
)

rap_msu <- tidyr::separate_rows(rap_msu, MSU, sep = ",")
rap_msu$RAP <- trimws(rap_msu$RAP)
rap_msu$MSU <- trimws(rap_msu$MSU)
rap_msu <- rap_msu[
  !(rap_msu$RAP %in% c("", "None")) &
    !(rap_msu$MSU %in% c("", "None")),
  ,
  drop = FALSE
]
rap_msu$GID <- strip_tx(rap_msu$MSU)
rap_msu$RAP <- strip_tx(rap_msu$RAP)
rap_msu <- unique(rap_msu[, c("GID", "RAP"), drop = FALSE])
rap_msu <- rap_msu[grepl("^LOC_Os", rap_msu$GID), , drop = FALSE]
rap_msu <- rap_msu[grepl("^Os[0-9]", rap_msu$RAP), , drop = FALSE]
rownames(rap_msu) <- NULL

message("RAP-MSU gene-level pairs: ", nrow(rap_msu))

# RAP GO annotations -----------------------------------------------------
ann <- read.delim(
  gzfile(rap_ann_file),
  header = TRUE,
  sep = "\t",
  quote = "",
  comment.char = "",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

go_col <- ann[["GO"]]
locus_col <- ann[["Locus_ID"]]
stopifnot(!is.null(go_col), !is.null(locus_col))

parse_go_cell <- function(text) {
  if (is.na(text) || !nzchar(text)) {
    return(character())
  }
  unique(regmatches(text, gregexpr("GO:[0-9]{7}", text))[[1]])
}

go_list <- lapply(go_col, parse_go_cell)
keep <- lengths(go_list) > 0
go_rap <- data.frame(
  RAP = rep(locus_col[keep], lengths(go_list)[keep]),
  GO = unlist(go_list[keep], use.names = FALSE),
  stringsAsFactors = FALSE
)
go_rap$RAP <- strip_tx(go_rap$RAP)
go_rap <- unique(go_rap)

# Map RAP GO onto MSU GID ------------------------------------------------
go_df <- merge(go_rap, rap_msu, by = "RAP", all = FALSE)
go_df <- unique(go_df[, c("GID", "GO"), drop = FALSE])
go_df$EVIDENCE <- "IEA"
go_df <- go_df[, c("GID", "GO", "EVIDENCE"), drop = FALSE]
rownames(go_df) <- NULL

message("GO rows after mapping to MSU: ", nrow(go_df))
message("Genes with GO: ", length(unique(go_df$GID)))

conversion <- unique(rap_msu[, c("GID", "RAP"), drop = FALSE])
rownames(conversion) <- NULL

# Build package ----------------------------------------------------------
build_dir <- file.path(tempdir(), "orgdb-build")
unlink(build_dir, recursive = TRUE, force = TRUE)
dir.create(build_dir, recursive = TRUE)

makeOrgPackage(
  go = go_df,
  conversion = conversion,
  version = "0.3.0",
  # AnnotationForge template substitution treats '@' as a symbol delimiter,
  # so author/maintainer emails are finalized in DESCRIPTION after generation.
  maintainer = "siyangming <yangming-6863 AT qq.com>",
  author = "xuzhougeng; siyangming",
  outputDir = build_dir,
  tax_id = 39947L,
  genus = "Oryza",
  species = "sativa",
  goTable = "go"
)

src_pkg <- file.path(build_dir, "org.Osativa.eg.db")
stopifnot(dir.exists(src_pkg))

# Install generated sqlite into this source tree -------------------------
sqlite_src <- file.path(src_pkg, "inst", "extdata", "org.Osativa.eg.sqlite")
sqlite_dest_dir <- file.path(pkg_root, "inst", "extdata")
dir.create(sqlite_dest_dir, showWarnings = FALSE, recursive = TRUE)
file.copy(sqlite_src, file.path(sqlite_dest_dir, "org.Osativa.eg.sqlite"), overwrite = TRUE)

# Keep a generated package copy for syncing R/man/NAMESPACE if needed ----
generated_copy <- file.path(pkg_root, "data-raw", "generated-org.Osativa.eg.db")
unlink(generated_copy, recursive = TRUE, force = TRUE)
file.copy(src_pkg, file.path(pkg_root, "data-raw"), recursive = TRUE)
file.rename(
  file.path(pkg_root, "data-raw", "org.Osativa.eg.db"),
  generated_copy
)

message("Wrote sqlite to ", file.path(sqlite_dest_dir, "org.Osativa.eg.sqlite"))
message("Generated package copy at ", generated_copy)
