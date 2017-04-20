#!/bin/sh 
#   adapted from OLIFE_registration.sh  
#   This script automates the BBL protocol for processing ADC data using FSL tools.  

for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do

subject=`echo $i | cut -d "/" -f 6`
dwi_dir=`ls -d $i/*dwi*ADC_[Am][Da][Cp]/nifti`
scanid=`echo $subject | cut -d "_" -f 2`
adc_2_diffusion=`ls -d $dwi_dir/$subject"_ADC_2_FMRIB58_FA.nii.gz"`
mprage_dir=`ls -d $i/*MPRAGE*moco3/nifti`
#mprage_nifti=`ls -d $mprage_dir/*MPRAGE_TI1110_ipat2_moco3.nii.gz`
#if [ -z $mprage_nifti ]; then
mprage_nifti=`ls -d $mprage_dir/*MPRAGE_TI1110_ipat2_moco3_SEQ*[!_to_std_sub].nii.gz`
#fi
bulb_dir=`ls -d $i/*t2*BULB*2`

if [ "X$adc_2_diffusion" == "X" ]; then

#MPRAGE to MNI
flirt -in $i/*MPRAGE*/bet/*_BET_*.nii.gz -ref  /import/monstrum/Applications/fsl5/data/standard/MNI152_T1_1mm_brain.nii.gz -omat $dwi_dir/$subject"_MPRAGE_2_MNI.mat" -out $dwi_dir/$subject"_MPRAGE_2_MNI.nii.gz"

# ADC to MPRAGE
flirt -in $dwi_dir/*brain_rescaled_masked.nii.gz -ref $i/*MPRAGE*/bet/*_BET_*.nii.gz -omat $dwi_dir/$subject"_ADC_2_MPRAGE.mat" -out $dwi_dir/$subject"_ADC_2_MPRAGE.nii.gz"

#take ADC2mprage to mni space using mprage2mni mat
flirt -in $dwi_dir/$subject"_ADC_2_MPRAGE.nii.gz" -ref /import/monstrum/Applications/fsl5/data/standard/MNI152_T1_1mm_brain.nii.gz -applyxfm -init $dwi_dir/$subject"_MPRAGE_2_MNI.mat" -out $dwi_dir/$subject"_ADC_2_MNI.nii.gz"

#ADC to DIFFUSION BRAIN 
flirt -in $dwi_dir/*brain_rescaled_masked.nii.gz -ref /import/monstrum/Applications/fsl5/data/standard/FMRIB58_FA_1mm.nii.gz -omat $dwi_dir/$subject"_ADC_2_FMRIB58_FA.mat" -out $dwi_dir/$subject"_ADC_2_FMRIB58_FA.nii.gz"

#Convert to .nii

/import/monstrum/Applications/fsl_4.1.6_64bit/bin/fslchfiletype NIFTI $dwi_dir/$subject"_ADC_2_MNI.nii.gz" $dwi_dir/$subject"_ADC_2_MNI_converted"

/import/monstrum/Applications/fsl_4.1.6_64bit/bin/fslchfiletype NIFTI $dwi_dir/$subject"_ADC_2_FMRIB58_FA.nii.gz" $dwi_dir/$subject"_ADC_2_FMRIB58_FA_converted"

else
echo $subject "ADC 2 FMRIB58 FA exists"
fi

# Bulb to MPRAGE
flirt -in $bulb_dir/nifti/*t2BULB.nii.gz -ref $mprage_nifti -omat $dwi_dir/"$scanid"_bulb2MPRAGE.mat -usesqform -out $dwi_dir/"$scanid"_bulb2MPRAGE.nii.gz
flirt -in $bulb_dir/bulb_volume/*t2*BULB*-mask_MQ.nii.gz -ref $mprage_nifti -applyxfm -init $dwi_dir/"$scanid"_bulb2MPRAGE.mat -datatype float -out $dwi_dir/"$scanid"_bulbmask2MPRAGE.nii.gz
fslmaths $dwi_dir/"$scanid"_bulbmask2MPRAGE.nii.gz -bin $dwi_dir/"$scanid"_bulbmask2MPRAGE_bin.nii.gz
fslmaths $dwi_dir/"$subject"_ADC_2_MPRAGE.nii.gz -mas $dwi_dir/"$scanid"_bulbmask2MPRAGE_bin.nii.gz $dwi_dir/"$scanid"_ADC_masked_by_bulb.nii.gz
stats=`fslstats $dwi_dir/"$scanid"_ADC_masked_by_bulb.nii.gz -V -M -S`
echo $subject,$stats >> /import/monstrum/ONM/group_results/DWI/bulb_to_mprage_adc_stats.txt
done
