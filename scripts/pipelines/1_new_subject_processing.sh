#This script is the processing pipeline to run for any new ONM 3T subject that has been checked into xnat and downloaded to monstrum using the download script (/import/monstrum/ONM/scripts/download/download_v2.0.sh). It will submit and run FreeSurfer, process the B0 mag and phase images, process the DTI image, create DWI masks, and create directories for the MPRAGE sulci drawings and T2 olfactory bulb drawings


#Submit FreeSurfer to the grid to run (will need to run extraction scripts (4_freesurfer_processing_pipeline.sh) the next day when FreeSurfer finishes running)
echo "Running FreeSurfer surf2grid"
/import/monstrum/ONM/scripts/structural/freesurfer/surf2grid.sh

#Process the B0 mag and phase images
echo "Calculating B0"
/import/monstrum/ONM/scripts/B0/calculate_B0_onm.sh

#Submit DTI processing to the grid to run DTI (creates FA maps) (then run 2_dti_processing_pipeline.sh)
echo "Processing DTI"
/import/monstrum/ONM/scripts/DTI/ONM_DTI_pipeline.sh

#Create DWI masks (first step of DWI processing, then can pick correct mask and run the next step in DWI processing- 3_dwi_processing_pipeline.sh)
echo "Creating DWI masks"
/import/monstrum/ONM/scripts/DWI/dwi_iterative_masking.sh

#make directories for olfactory bulb and sulci drawing outputs
for i in `ls -d /import/monstrum/ONM/subjects/*`; do

mkdir $i/*t2_BULB*/bulb_volume
mkdir $i/*MPRAGE*moco3/sulci

done
