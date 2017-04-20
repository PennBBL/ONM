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

#echo "....................Extract entorhinal"
#/import/monstrum/ONM/scripts/structural/freesurfer/extract_stats_entorhinal.sh

#imscribe script for 7T prep

echo "....................Imscribe 7T prep"
/import/monstrum/ONM/scripts/structural/freesurfer/imscribe_rois_prep_7T.sh

#extraction of rois script

echo "....................Extraction of ROI stats"
/import/monstrum/ONM/scripts/structural/freesurfer/extract_stats.sh


#Run QA script

echo ".................Running QA"

rm -rf /import/monstrum/ONM/redcap/subject_variables/bblid_scanid.csv

for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do 

subid=`echo $i | cut -d "/" -f 6`

echo $subid >> /import/monstrum/ONM/redcap/subject_variables/bblid_scanid.csv

done

/import/monstrum/ONM/scripts/structural/freesurfer/qa/QA.sh

#/import/monstrum/ONM/scripts/structural/freesurfer/upload_freesurfer_data_to_redcap.py

#migrate 7T data to tesla
#/import/monstrum/ONM/scripts/pre_processing/migrate_7T_prep_to_tesla.sh
