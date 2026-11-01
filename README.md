# org.Osativa.eg.db

[![R-CMD-check](https://github.com/SiYangming/org.Osativa.eg.db/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SiYangming/org.Osativa.eg.db/actions/workflows/R-CMD-check.yaml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3374105.svg)](https://doi.org/10.5281/zenodo.3374105)

Genome-wide annotation for *Oryza sativa* Japonica Group, for GO enrichment and MSU ↔ RAP-DB ID conversion.

水稻日本晴注释包：用于 clusterProfiler 的 GO 富集，以及 MSU `LOC_Os*` 与 RAP-DB `Os*` 之间的双向 ID 转换。

## Identifiers / 标识符

| keytype | Meaning |
| --- | --- |
| `GID` | MSU/RGAP locus ID, e.g. `LOC_Os03g61590` (central ID) |
| `RAP` | RAP-DB locus ID, e.g. `Os03g0831400` |

Both keytypes work with `select()`, `mapIds()`, and `enrichGO()`.

`GID` 是中心基因 ID（MSU）。`RAP` 是 RAP-DB locus ID。两者都可作为 `keyType`。

Annotation snapshot: RAP-DB **2026-02-05** (RAP–MSU table and representative GO). Taxonomy ID: **39947**.

## Installation / 安装

Requires R >= 3.6 and AnnotationDbi >= 1.44.0.

```r
# recommended: remotes
# install.packages("remotes")
remotes::install_github("SiYangming/org.Osativa.eg.db@v0.3.0")

# or latest master
# remotes::install_github("SiYangming/org.Osativa.eg.db")

# or source tarball from the release / master archive
install.packages(
  "https://github.com/SiYangming/org.Osativa.eg.db/archive/refs/tags/v0.3.0.tar.gz",
  repos = NULL,
  type = "source"
)
```

## Usage / 用法

```r
library(org.Osativa.eg.db)
library(AnnotationDbi)

org <- org.Osativa.eg.db
columns(org)
keytypes(org)
```

### Bidirectional ID conversion / 双向 ID 转换

Use `mapIds()` with `multiVals = "list"` so one-to-many mappings are kept.

一对多关系请用 `multiVals = "list"`，避免丢掉第二个对应 ID。

MSU → RAP (`LOC_Os03g61590` → `Os03g0831400`):

```r
AnnotationDbi::mapIds(
  org,
  keys = "LOC_Os03g61590",
  column = "RAP",
  keytype = "GID",
  multiVals = "list"
)
```

RAP → MSU (`Os03g0831400` → `LOC_Os03g61590`):

```r
AnnotationDbi::mapIds(
  org,
  keys = "Os03g0831400",
  column = "GID",
  keytype = "RAP",
  multiVals = "list"
)
```

### GO enrichment / GO 富集

```r
library(clusterProfiler)

# with MSU IDs
enrichGO(
  gene = msu_ids,
  OrgDb = org,
  keyType = "GID",
  ont = "BP"
)

# with RAP-DB IDs
enrichGO(
  gene = rap_ids,
  OrgDb = org,
  keyType = "RAP",
  ont = "BP"
)
```

See also: <https://guangchuangyu.github.io/software/clusterProfiler/>

## Citation / 引用

Original release (v0.01) by xuzhougeng:

xuzhougeng. (2019, August 22). xuzhougeng/org.Osativa.eg.db v0.01 (Version v0.01). Zenodo. https://doi.org/10.5281/zenodo.3374105

This repository revision **0.3.0** (maintainer: siyangming) updates RAP–MSU and GO to RAP-DB 2026-02-05, fixes taxonomy metadata, and refreshes package configuration. Cite the Zenodo record for the original package; mention this 0.3.0 revision when using the updated annotations.

本仓库 **0.3.0**（维护者 siyangming）在原包基础上更新了 RAP-DB 2026-02-05 注释与包配置。使用原版请引用上述 Zenodo；使用本修订版时请同时说明 0.3.0。
