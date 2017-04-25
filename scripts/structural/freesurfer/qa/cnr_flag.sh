#this script will extract the cnr data for each subject and output to an aggregate cnr file, it is run by the wrapper script QA.sh

#! /bin/bash

#create variables for the subjects directory and subject list which were passed by QA.sh
export SUBJECTS_DIR=$2
slist=$1

#create a variable which gets the output directory in the group results freesurfer directory under stats
outdir=$SUBJECTS_DIR/../stats/cnr

#if that output directory doesn't exist then make it
if [ ! -e $outdir ]; then mkdir $outdir; fi

#create a variable for an output cnr file
file=$outdir/cnr_buckner.csv

#if that output file doesn't exist then
if [ ! -e $file ]; then

	#output the headers bblid, scanid and cnr to that file
	echo "bblid,scanid,cnr" > $file
fi

#for each subject in the passed subject list
for i in $(cat $slist);do

	#create a variable for the bblid, for the scanid, and print those to the screen
	bblid=$(echo $i | cut -d"_" -f1)
	scanid=$(echo $i | cut -d"_" -f2)
	echo "working on subject $bblid $scanid"

	#create variables for the surf and mri output directories which hold freesurfer output in each subject's freesurfer directory
	surf=`ls -d $SUBJECTS_DIR/$i/surf`
	mri=`ls -d $SUBJECTS_DIR/$i/mri`

	# checks if subject id is in the output file already, if it's not then
	if ! grep -q "$bblid,$scanid" $file; then

		#run mri_cnr command on that subject's data and output that to a temp file call val.txt
		mri_cnr $surf $mri/orig.mgz > val.txt

		#create variables for the cnr value, and subject
		val=`grep "total CNR" val.txt`
		value=`echo $val |cut -f 4 -d " "`
		subj=`echo $i |cut -f 6 -d /`

		#output that data to the cnr_buckner output file
		echo $bblid,$scanid,$value >> $file
	fi
done

#remove that temporary val.txt file
rm -f val.txt
