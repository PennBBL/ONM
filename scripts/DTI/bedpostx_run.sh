subjlist=$1
subj=$(cat $subjlist|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing

bedpostx /import/monstrum/ONM/subjects/$subj/*DTI*64*/bedpostx/
