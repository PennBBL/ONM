#this script is submitted by the wrapper script bedpostx_submit.sh and will run bedpostx on the given subject

#this is the subject list given by the wrapper script
subjlist=$1
subj=$(cat $subjlist|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing

#this runs the command bedpostx for that given subject's DTI data
bedpostx /import/monstrum/ONM/subjects/$subj/*DTI*64*/bedpostx/
