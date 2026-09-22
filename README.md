# MechanoMaST

Mechanics mapped to Spatial Transcriptomics (MechanoMaST) is a workflow that enables the spatial mapping of stiffness maps to spatial transcriptome maps acquired in adjacent tissue sections.

This GitHub repository contains all the required code to reproduce the results of the following pre-print:
https://doi.org/10.64898/2026.08.29.747727

<img width="2127" height="980" alt="Image" src="https://github.com/user-attachments/assets/0c9482e7-b597-4088-8ad7-dd1f3fa2b14a" />

## Reproduction of our results

### What you need:
1. This repository. You can clone it by running the following line of code in a terminal:  
``` git clone https://github.com/diz-lab/mechanoMaST.git ```

2. The external input images which are available here:  
Large image data will be deposited to a database. The link will be pasted here. During the review process, the images are accessible to reviewers via owncloud.

### How to do it:
1. Open the Jupyter notebook 20260825_generalMapping_withConfigFile.ipynb (in the folder Scripts).   
It contains the outputs for Patient 4 as an example.

2. Replace external_input_path = Path('../External_Image_Inputs') in the second cell with the path corresponding to where you saved the external input images.

3. Change sample_id = '04' in the same cell to the sample you would like to analyse.  
The possible options are: '01', '02', '03', '04', '05', '06', '7a', '7b', '08', '09', '10'

4. Run the script. 

## How to adapt it to your data

1. Clone this repository.
   ``` git clone https://github.com/diz-lab/mechanoMaST.git ```

2. Install Napari and the affinder plug-in according to the developers instructions.  
   https://github.com/napari/napari   
   https://github.com/jni/affinder 

3. Generate affine transformation matrices using the napari affinder plug-in
   
4. Adapt the Jupyter notebook 20260825_generalMapping_withConfigFile.ipynb (in the folder Scripts in this repository) by specifying the input paths to your images and transformation matrices. Additionally, the you might have to revisit the create_coordinate_grid function. It assumes that AFM measurements are acquired in a vertical serpentine pattern starting from the bottom right upwards. And run it. 

   
   

