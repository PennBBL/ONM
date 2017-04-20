# 2_dti_processing_pipeline.sh
#this should be run after the ONM_DTI_pipeline.sh and ONM_DTI_process.sh scripts have been run

#this step gets the qa results
/import/monstrum/ONM/scripts/DTI/get_qa_results.sh

#this step uploads DTI data to RedCap
#/import/monstrum/ONM/scripts/DTI/upload_DTI_data_to_redcap.py

#this step submits bedpostx
/import/monstrum/ONM/scripts/DTI/bedpostx_submit.sh

#this step runs TBSS
/import/monstrum/ONM/scripts/DTI/tbss_run.sh

#3_dwi_processing_pipeline.sh
#to be run after mask has been chosen and input into mask_list.txt and after CSF has been drawn on ADC and bulb mask has been drawn

#mask images
#/import/monstrum/ONM/scripts/DWI/dwi_mask_images.sh

#mask csf
#/import/monstrum/ONM/scripts/DWI/csf_mask.sh

#register adc and bulb (bulb mask must be drawn first)
#/import/monstrum/ONM/scripts/DWI/adc_registration.sh



#4_freesurfer_processing_pipeline.sh
#this script runs the pipeline for freesurfer scripts after surf2grid.sh has been run


#symlink

echo "....................Creating symlink"
/import/monstrum/ONM/scripts/structural/freesurfer/symlink_setup.sh

#extract sulcal depth

echo "....................Extract sulc depth"
/import/monstrum/ONM/scripts/structural/freesurfer/extract_sulc_depth.sh

#extract cortical thickness

echo "....................Extract cortical thickness"
/import/monstrum/ONM/scripts/structural/freesurfer/extract_cortial_thickness_sulc_label.sh

#extract stats entorhinal

echo "....................Extract entorhinal"
/import/monstrum/ONM/scripts/structural/freesurfer/extract_stats_entorhinal.sh

#imscribe script for 7T prep

echo "....................Imscribe 7T prep"
/import/monstrum/ONM/scripts/structural/freesurfer/imscribe_rois_prep_7T.sh

#extraction of rois script

echo "....................Extraction of ROI stats"
/import/monstrum/ONM/scripts/structural/freesurfer/extract_stats.sh


#Run QA script

echo ".................Running QA"

rm -rf /import/monstrum/ONM/redcap/subject_variables/bblid_scanid.csv

for i in `ls -d /import/monstrum/ONM/subjects/*`; do 

subid=`echo $i | cut -d "/" -f 6`

echo $subid >> /import/monstrum/ONM/redcap/subject_variables/bblid_scanid.csv

done

/import/monstrum/ONM/scripts/structural/freesurfer/qa/QA.sh

/import/monstrum/ONM/scripts/structural/freesurfer/upload_freesurfer_data_to_redcap.py

#migrate 7T data to tesla
/import/monstrum/ONM/scripts/pre_processing/migrate_7T_prep_to_tesla.sh

#Hand draw ROI processing

#this script extracts volume data for the bulb
#/import/monstrum/ONM/scripts/Bulbs/T2/dilation_mask_segmentation/segmented_data/bulb_separate.sh

#this script extracts sulcus length from the sulcus drawing
#/import/monstrum/ONM/scripts/Sulci/get_sulci_length.sh

