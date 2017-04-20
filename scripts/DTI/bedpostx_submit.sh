#List to be populated for grid submission
joblist=/import/monstrum/ONM/scripts/DTI/onm_bedpostx_joblist.txt

#Remove all previous versions of joblist
rm -f $joblist

for i in `ls -d /import/monstrum/ONM/subjects/*/*DTI*64*`; do
	subid=`echo $i | cut -d "/" -f 6`
	bedpost_file=`ls -d $i/bedpostx.bedpostX/mean_S0samples.nii.gz`

if [ "X$bedpost_file" == "X" ]; then

	echo "........................... Processing subject "$subid

#Check if 'bedpostx' folder exists, if not make one
		#if [ ! -e $i/bedpostx ]; then
		echo "making directory"
		mkdir $i/bedpostx
		# copy dti.nii.gz and associated bvecs and bvals files to working bedpostx directory
		cp $i/nifti/*.bvec $i/bedpostx/bvecs
		cp $i/nifti/*.bval $i/bedpostx/bvals
		cp $i/nifti/*DTI*.nii.gz $i/bedpostx/data.nii.gz
		cp $i/bbl/raw_dti/dtistd_2_*.mask.nii.gz $i/bedpostx/nodif_brain_mask.nii.gz
		#else
		#echo "Bedpostx folder structure complete"
		#fi

echo $subid >> $joblist

fi

done

ntasks=$(cat $joblist | wc -l)

qsub -V -q all.q -S /bin/bash -o ~/onm_bedpostx_logs -e ~/onm_bedpostx_logs -t 1-${ntasks} /import/monstrum/ONM/scripts/DTI/bedpostx_run.sh $joblist
