library(zinbwave)
library(scRNAseq)
library(matrixStats)
library(magrittr)
library(biomaRt)
library(sparseMatrixStats)
library(readr)
library(dplyr)
library(BiocParallel)
library(edgeR)

# Set up paths
input_dir  <- ""
output_dir <- ""

# Stiffness thresholds 
values <- c(260,520,780)

for (value in values) { 
  # Load the counts matrix
  counts <- as.matrix(read.csv(file.path(input_dir, paste0("counts_", value, ".csv"), row.names = 1)))
  
  # Load the metadata
  coldata <- read.csv(file.path(input_dir, paste0("coldata_", value, ".csv"), row.names = 1))
  
  # Clean the column names in counts
  colnames(counts) <- gsub("^X", "", colnames(counts))          # Remove leading 'X'
  colnames(counts) <- gsub("\\.", "-", colnames(counts))        # Replace '.' with '-'
  colnames(counts) <- gsub("-1$", "", colnames(counts))         # Remove trailing '-1'
  rownames(coldata) <- gsub("-1$", "", rownames(coldata))         # Remove trailing '-1'
  
  # Ensure rownames in metadata match column names in counts
  stopifnot(all(rownames(coldata) == colnames(counts)))
  
  # Create a SummarizedExperiment object
  se <- SummarizedExperiment(
    assays = list(linda_counts = counts), 
    colData = coldata
  )
  
  #using top 2k highly variable genes for zinb-wave
  assay(se) %>% log1p %>% rowVars -> vars
  names(vars) <- rownames(se)
  vars <- sort(vars, decreasing = TRUE)
  head(vars)
  se <- se[names(vars)[1:2000],]
  assayNames(se)[1] <- "counts"
  
  #zinb-wave
  # Construct the design matrix
  # Set ECM_low as the reference level
  colData(se)$Barcode_DE <- as.factor(colData(se)$Barcode_DE)
  colData(se)$Barcode_DE <- relevel(colData(se)$Barcode_DE, ref = "ECM_low")
  X <- model.matrix(~ Barcode_DE, data = colData(se))
  # Check the design matrix
  head(X)
  
  zinb_model <- zinbFit(se,
                        X = X,
                        epsilon = 1e6,
                        verbose = TRUE,
                        BPPARAM = BiocParallel::MulticoreParam(workers = 4))
  
  se_zinb <- zinbwave(se, fitted_model = zinb_model, K = 2, epsilon=1e6,
                      observationalWeights = TRUE)
  weights <- assay(se_zinb, "weights")
  
  dge <- DGEList(assay(se_zinb))
  dge <- calcNormFactors(dge)
  dge$weights <- weights
  dge <- estimateDisp(dge, X)
  fit <- glmFit(dge, X)
  
  # Perform LRT for the second coefficient (e.g., condition effect)
  lrt <- glmLRT(fit, coef = 2)
  top <- topTags(lrt, n = Inf)  # Extract all genes
  
  top_table <- as.data.frame(top)
  
  write.table(
    top_table,
    file = file.path(output_dir, paste0(value, "_zinbw_edgeR_all_final.tsv"),
    sep = "\t",
    row.names = TRUE,
    quote = FALSE
  )
}
