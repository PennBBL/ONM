#this is a wrapper script which will get the necessary parameters for bedpostx to run and then run bedpostx using the script bedpostx_run.sh

#List to be populated for grid submission
joblist=/import/monstrum/ONM/scripts/DTI/onm_bedpostx_joblist.txt

#Remove all previous versions of joblist
rm -f $joblist

#for each ONM subject with DTI data
for i in `ls -d /import/monstrum/ONM/subjects/*/*DTI*64*`; do

	#create variables for the subject id and the final output of bedpostx
	subid=`echo $i | cut -d "/" -f 6`
	bedpost_file=`ls -d $i/bedpostx.bedpostX/mean_S0samples.nii.gz`

#if the final output of bedpostx doesn't exist then run the rest of the script
if [ "X$bedpost_file" == "X" ]; then

	#print to the screen which subject is being processed
	echo "........................... Processing subject "$subid

		#Check if 'bedpostx' folder exists, if not make one
		if [ ! -e $i/bedpostx ]; then
		echo "making directory"
		mkdir $i/bedpostx
		# copy dti.nii.gz and associated bvecs and bvals files to working bedpostx directory (NOTE: for many downloads from ONM there are TWO DTI niftis, bvec files, and bval files. This will cause the script to fail. You must go into the DTI directory and delete one of the sets before running this script. The sets are identical so either is fine.)
		cp $i/nifti/*.bvec $i/bedpostx/bvecs
		cp $i/nifti/*.bval $i/bedpostx/bvals
		cp $i/nifti/*DTI*.nii.gz $i/bedpostx/data.nii.gz
		cp $i/bbl/raw_dti/dtistd_2_*.mask.nii.gz $i/bedpostx/nodif_brain_mask.nii.gz

		#if the bedpostx directory exists then print to the screen
		else
		echo "Bedpostx folder structure complete"
		fi

#append the subject id to the list for submission of bedpostx
echo $subid >> $joblist

fi

done

#get the number of subjects that will be run for bedpostx
ntasks=$(cat $joblist | wc -l)

#submit the bedpostx_run.sh script to the grid with the joblist of subjects to be run
qsub -V -q all.q -S /bin/bash -o ~/onm_bedpostx_logs -e ~/onm_bedpostx_logs -t 1-${ntasks} /import/monstrum/ONM/scripts/DTI/bedpostx_run.sh $joblist
