# MechanoMaST

Mechanics mapped to Spatial Transcriptomics (MechanoMaST) is a workflow that enables the spatial mapping of stiffness maps to spatial transcriptomics (ST) maps acquired in adjacent tissue sections.

This GitHub repository contains all the required code to reproduce the results of the following pre-print:
https://doi.org/10.64898/2026.08.29.747727

<img width="2127" height="980" alt="Image" src="https://github.com/user-attachments/assets/0c9482e7-b597-4088-8ad7-dd1f3fa2b14a" />

The provided scripts are used to process Visium ST data, map AFM stiffness measurements onto individual capture spots, perform an error propagation and filter for confidently mapped measurements, and combine both data types to (1) test for differential gene expression (DE) between high- and low-stiffness spots and (2) train a Random Forest model that predicts spot-level stiffness from gene expression. 

## Pipeline
The pipeline consists of six scripts, run in the order below.

### Inputs
1. This repository. You can clone it by running the following line of code in a terminal:  
``` git clone https://github.com/diz-lab/mechanoMaST.git ```

2. The external input images ([https://10.5281/zenodo.23042812.](https://doi.org/10.5281/zenodo.23042812)), under embargo until formal publication of the MechanoMaST workflow.
During the review process, the images are accessible to reviewers via owncloud.

3. The Visium Spatial Transcriptomics dataset. The data will be deposited to a database upon formal publication of the MechanoMaST workflow.
The link will be pasted here. During the review process, the dataset is accessible to reviewers via owncloud.

### 0. Landmark selection in napari affinder plug-in
Our pipeline takes four images per ROI (see Figure above): 

- AFM_Section_Hoechst_20X (A)
- AFM_Section_HE_20X (B)
- AFM_Section_HE-Tilescans (C)
- Visium_Section_HE_Tilescans (D)

The registrations of A to B and C to D were performed using the napari affinder plug-in.
For our dataset, the generated landmark lists and affine transformation matrices are stored in this repository.

When adapting our workflow to you own data, install napari and the affinder plug-in according to the developers instructions.
Then select landmarks in the images, export the landmark lists and generate affine transformation matrices using the napari affinder plug-in
with the following setting: model = affine, reference = image B or D, respectively, moving = image A or C, respectively
[https://github.com/napari/napari](https://github.com/napari/napari)   
[https://github.com/jni/affinder](https://github.com/jni/affinder) 


### 1. `Mapping_withConfigFile.ipynb` — Map AFM measurements to ST capture spots

**Inputs:**
- External input images (download from Owncloud/Zenodo; external_input_path needs to be specified by user)
- [Affine transformation matrices](Inputs/Matrices)
- [Tissue position table](Inputs/tissue_positions.csv)
- [Config File](config_samples.yaml)

**Outputs:**
- [Template matching matrices](Outputs/Matrices/Template_Matching)
- [Direct transformation matrices](Outputs/Matrices/Direct_Transformation)
- [Mapped dataframe](Outputs/Mapping) with transformed AFM coordinates assigned to ST capture spots

This script contains the outputs for Patient 4 as an example. Since it uses a config file,
simply change sample_id = '04' in the cell 2 to the sample you would like to analyse.  
The possible options are: '01', '02', '03', '04', '05', '06', '7a', '7b', '08', '09', '10'

For each Patient, one [mapped dataframe](Outputs/Mapping) is saved as a csv file. A combination of all of them into an Excel file can be found
in the Inputs folder [ST_AFM_Mapping.xlsx](Inputs/ST_AFM_Mapping.xlsx). To adapt this to your own data, adapt the input paths and config file accordingly.
Additionally, the create_coordinate_grid function might need to be adapted to your data. It assumes that AFM measurements are acquired in a vertical serpentine pattern starting from the bottom right upwards.

### 2. `ErrorPropagation.ipynb` — Propagate the image registration error and filter for confidently mapped spots

**Inputs:**
- Summarized [Mapped AFM measurements](Inputs/ST_AFM_Mapping.xlsx) from Script 1 `Mapping_withConfigFile.ipynb`
- [Table of Landmarks](Inputs/Landmarks.xlsx) (selected using the napari affinder plug-in)
- [AFM coordinates](Inputs/AFM_Coords.xlsx) in tidy format

**Outputs:**
- [Error propagation dataframe](Outputs/Error_Propagated_Data.csv) containing all AFM measurements and their mapping errors.
- [Filtered Dataframe](Outputs/Mapped_Filtered_AFM_Measurements.csv) containing only stably mapped measurements.
  

This script takes the mapped AFM dataframe produced by Script 1 and performs an error propagation based on landmarks.
Next, each mapped AFM measurement is moved by its mapping error (default = 0.5 standard deviations) and the dataset is filtered to only contain measurements that can be subjected to this movement without switching to a different ST spot. 

### 3. `Measurements_processing.ipynb` — Stiffness measurement QC and mapping

**Inputs:**
- [Filtered Dataframe](Inputs/Mapped_Filtered_AFM_Measurements.csv) generated by script 2.
- [ST Spot Annotations](Inputs/Spot_Annotation)
  
**Outputs:**
- [Filtered AFM measurements](Outputs/filtered_measurements.tsv)
- [QC Histogramm](QC_Hist.svg)

Processes raw stiffness measurements and pathologist annotations, filters out outliers and calculates mean stiffness. 

### 4. `Visium_processing.ipynb` — Spatial transcriptomics processing

**Inputs:**
- External Visium ST Dataset (will be deposited to a database upon formal publication of our dataset; available to reviewers via owncloud)
- [Filtered AFM measurements](Inputs/filtered_measurements.tsv) generated by Script 3.
- [Sample List](Inputs/sample_list.csv)

**Outputs:**
- raw filtered visium data as AnnData object
- normalized visium data as AnnData
- QC plots
- dataframe with stiffness, barcodes and gene expression levels for downstream analysis
  
Reads raw 10x Visium output for each sample, computes QC metrics and concatenates all samples. AFM measurements are merged based on barcodes.

### 5. `DE.R` — Differential expression (ZINB-WaVE + edgeR)

**Inputs:**
- dataframe with stiffness, barcodes and gene expression levels for downstream analysis (created in step4)

**Outputs:**
- differential expression analysis results table
  
Runs differential expression between `ECM_high` and `ECM_low` spots for each of the three stiffness thresholds (260 Pa, 520 Pa, 780 Pa) produced in step 4.

### 6. `RF.ipynb` — Random Forest stiffness prediction

**Inputs:**
- dataframe with stiffness, barcodes and gene expression levels for downstream analysis (created in step4)

**Outputs:**
- Feature importance table
- Partial dependence plots

Trains a regression model to predict per-spot stiffness from gene expression, using the merged table produced in step 4.

## How to cite
Please cite the following pre-print:

Decker L, Olisov D, Schleussner N, Wiethoff H, Schmidt T, Nienhueser H, Pausch TM, Korbel JO, Diz-Munoz A. 2026. MechanoMaST - a multimodal pipeline for spatially registering mechanical and transcriptomic tissue data. DOI: https://doi.org/10.64898/2026.08.29.747727
