library(AnnotationDbi)

test_that("taxonomy and organism metadata are correct", {
  expect_identical(taxonomyId(org.Osativa.eg.db), 39947L)
  expect_identical(org.Osativa.egORGANISM, "Oryza sativa")
  meta <- AnnotationDbi::metadata(org.Osativa.eg.db)
  expect_identical(meta$value[meta$name == "ORGANISM"], "Oryza sativa")
  expect_identical(meta$value[meta$name == "Taxonomy ID"], "39947")
})

test_that("expected columns and keytypes are present", {
  cols <- columns(org.Osativa.eg.db)
  kts <- keytypes(org.Osativa.eg.db)
  expect_true(all(c("GID", "RAP", "GO", "EVIDENCE", "ONTOLOGY") %in% cols))
  expect_true(all(c("GID", "RAP") %in% kts))
})

test_that("MSU and RAP convert bidirectionally for a known pair", {
  msu <- "LOC_Os03g61590"
  rap <- "Os03g0831400"

  to_rap <- mapIds(
    org.Osativa.eg.db,
    keys = msu,
    column = "RAP",
    keytype = "GID",
    multiVals = "list"
  )
  to_msu <- mapIds(
    org.Osativa.eg.db,
    keys = rap,
    column = "GID",
    keytype = "RAP",
    multiVals = "list"
  )

  expect_true(rap %in% to_rap[[msu]])
  expect_true(msu %in% to_msu[[rap]])
})

test_that("truncated gene models are absent and GO is available", {
  expect_false("ChrSy.fgenesh." %in% keys(org.Osativa.eg.db, keytype = "GID"))
  expect_false("ChrUn.fgenesh." %in% keys(org.Osativa.eg.db, keytype = "GID"))

  go_gene <- "LOC_Os03g45710"
  go_terms <- mapIds(
    org.Osativa.eg.db,
    keys = go_gene,
    column = "GO",
    keytype = "GID",
    multiVals = "list"
  )[[go_gene]]
  expect_true(length(go_terms) >= 1)
  expect_true(all(grepl("^GO:[0-9]{7}$", go_terms)))
})
