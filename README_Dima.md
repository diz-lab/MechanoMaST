## Overview

Provided scripts are used to process Visium spatial transcriptomics samples, map AFM stiffness measurements onto individual capture spots, and combine both data types to (1) test for differential gene expression (DE) between high- and low-stiffness spots and (2) train a Random Forest model that predicts spot-level stiffness from gene expression. The pipeline consists of four scripts, run in the order below.

## Pipeline

### 1. `Visium_processing.ipynb` — Spatial transcriptomics processing

Reads raw 10x Visium output for each sample, computes QC metrics and concatenates all samples. AFM measurements are merged based on barcodes.

### 2. `Measurements_processing.ipynb` — Stiffness measurement QC and mapping

Processes raw stiffness measurements and pathologist annotations, filtering out outliers and calculates mean stiffness. 

### 3. `DE.R` — Differential expression (ZINB-WaVE + edgeR)

Runs differential expression between `ECM_high` and `ECM_low` spots for each of the three stiffness thresholds (275, 550, 825) produced in step 1.

### 4. `RF.ipynb` — Random Forest stiffness prediction

Trains a regression model to predict per-spot stiffness from gene expression, using the merged table produced in step 1.
