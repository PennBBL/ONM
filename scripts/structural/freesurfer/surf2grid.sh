#this is a wrapper script that loops through ONM subjects and if they don't have freesurfer processed it submits freesurfer to run using the freesurfer_grid_submission.sh script

#!/bin/bash

#set freesurfer specific environment variables for output
export SUBJECTS_DIR="/import/monstrum/ONM/group_results/freesurfer/working_subjects"

#create a variable which is a list of all ONM subjects
slist=$(ls -d /import/monstrum/ONM/subjects/*_*) 

#create a variable which gets the log directory output
logs="/import/monstrum/ONM/scripts/structural/freesurfer/logs"

#for every subject in the subjects folder
for i in $slist
do

	#print the subject id to the screen
	echo $i

	#get bblid_scanid
	subjid=`basename $i`
	
	#create a variable for their MPRAGE dicom file (just one example dicom needed)	
	infile=`ls -d $i/*MPRAGE*ipat2_moco3/dicoms/*_I000000.dcm`

	#get the working subjects folder for that subject
	surfpath=`ls -d /import/monstrum/ONM/subjects/"$subjid"/*MPRAGE*ipat2*moco3/freesurfer`
	
	#if the freesurfer folder isn't empty for that subject then skip that subject        
	if [ "X$surfpath" != "X" ]; then
		echo "*-*-*-*-Freesurfer has already been run for this subject-*-*-*-*"
		continue
	
	#if there is no freesurfer folder for that subject then submit the freesurfer_grid_submission script to the grid
	else
	qsub -V -e $logs -o $logs -q all.q -S /bin/bash /import/monstrum/ONM/scripts/structural/freesurfer/freesurfer_grid_submission.sh $infile $SUBJECTS_DIR $subjid
fi
done 
