#this should be run after the ONM_DTI_pipeline.sh and ONM_DTI_process.sh scripts have been run (these scripts create the FA maps and are run through either the 1_new_subject_processing.sh script or the /import/monstrum/ONM/scripts/DTI/ONM_DTI_pipeline.sh script)

#this step gets the qa results
/import/monstrum/ONM/scripts/DTI/get_qa_results.sh

#this step submits bedpostx
/import/monstrum/ONM/scripts/DTI/bedpostx_submit.sh

#this step runs TBSS
/import/monstrum/ONM/scripts/DTI/tbss_run.sh
