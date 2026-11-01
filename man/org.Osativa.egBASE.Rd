\name{org.Osativa.eg.db}
\alias{org.Osativa.eg.db}
\alias{org.Osativa.eg}
\title{Oryza sativa organism annotation package}
\description{
  \code{org.Osativa.eg.db} is an \code{OrgDb} package for
  \emph{Oryza sativa} Japonica Group. The central identifier
  (\code{GID}) is the MSU/RGAP \code{LOC_Os} locus ID. RAP-DB locus IDs
  are available as keytype \code{RAP}. Gene Ontology annotations are
  taken from the RAP-DB 2026-02-05 representative annotation and mapped
  onto MSU IDs.

  Use \code{select()}, \code{keys()}, \code{columns()},
  \code{keytypes()}, and \code{mapIds()} from AnnotationDbi. For GO
  enrichment with clusterProfiler, set \code{keyType} to \code{"GID"}
  or \code{"RAP"}.
}
\keyword{datasets}
