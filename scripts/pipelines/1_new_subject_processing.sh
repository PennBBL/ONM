#this script contains the pipeline of pre processing scripts to run for any new ONM 3T subject

#FreeSurfer (will need to run extraction scripts the next day when FreeSurfer finishes running)

echo "Running FreeSurfer surf2grid"
/import/monstrum/ONM/scripts/structural/freesurfer/surf2grid.sh

#B0 processing

echo "Calculating B0"
/import/monstrum/ONM/scripts/B0/calculate_B0_onm.sh

#DTI processing

echo "Processing DTI"
/import/monstrum/ONM/scripts/DTI/ONM_DTI_pipeline.sh

#DWI processing (first step, then can pick mask and run second step)

echo "Creating DWI masks"
/import/monstrum/ONM/scripts/DWI/dwi_iterative_masking.sh

#make directories for sulci and bulbs

for i in `ls -d /import/monstrum/ONM/subjects/*`; do

mkdir $i/*t2_BULB*/bulb_volume
mkdir $i/*MPRAGE*moco3/sulci

done
