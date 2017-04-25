#! /bin/bash
# this script is run by QA.sh and gets mean thickness and total surface area for each subject in list
# returns NA if not available.

#create a variable for the subject directory and subject list to be run, passed by QA.sh
export SUBJECTS_DIR=$2
slist=$1

#if the group results freesurfer stats aparc.stats directory doesn't exist then make it
if [ ! -e $SUBJECTS_DIR/../stats/aparc.stats ]; then
	mkdir $SUBJECTS_DIR/../stats/aparc.stats
fi

#print headers for the variables desired to an output file
echo "bblid,scanid,rh.meanthickness,rh.totalarea,lh.meanthickness,lh.totalarea" > $SUBJECTS_DIR/../stats/aparc.stats/bilateral.meanthickness.totalarea.csv

#for each subject in that passed list
for i in $(cat $slist); do

	#create variables for the bblid and scanid
	bblid=$(echo $i | cut -d"_" -f1)
	scanid=$(echo $i | cut -d"_" -f2)

	#if that subject doesn't have freesurfer data in the group results freesurfer subjects directory then print an error to the screen
	if [ ! -e $SUBJECTS_DIR/${bblid}_${scanid} ]; then
		echo "no subject directory for $bblid $scanid"

	#otherwise...
	else

		### EXTRACT RH MEAN THICKNESS AND TOTAL AREA ###
		################################################
		subdir=$SUBJECTS_DIR/${bblid}_${scanid}
		if [ ! -e "$subdir/stats/rh.aparc.stats" ]; then
			echo "no rh.aparc.stats file for $bblid $scanid"
			rmt="NA"
			rta="NA"
		else
			string=`grep MeanThickness,  $subdir/stats/rh.aparc.stats` 
			rmt=`echo $string | cut -d "," -f 4`
			string=`grep SurfArea,  $subdir/stats/rh.aparc.stats` 
			rta=`echo $string | cut -d "," -f 4`
		fi
		
		### EXTRACT LH MEAN THICKNESS AND TOTAL AREA ###
		################################################
		if [ ! -e "$subdir/stats/lh.aparc.stats" ]; then
			echo "no lh.aparc.stats file for $bblid $scanid"
			lmt="NA"
			lta="NA"
		else
			string=`grep MeanThickness,  $subdir/stats/lh.aparc.stats` 
			lmt=`echo $string | cut -d "," -f 4`
			string=`grep SurfArea,  $subdir/stats/lh.aparc.stats` 
			lta=`echo $string | cut -d "," -f 4`
		fi

		#output these data to the output file for each subject, this is an aggregate file
		echo $bblid,$scanid,$rmt,$rta,$lmt,$lta >> $SUBJECTS_DIR/../stats/aparc.stats/bilateral.meanthickness.totalarea.csv
	fi
done
