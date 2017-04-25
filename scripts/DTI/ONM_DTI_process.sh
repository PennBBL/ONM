#this script is run by the wrapper ONM_DTI_pipeline.sh and will process each subject given by the wrapper script's DTI data

#######add logs
logfile=""
logrun(){
run="$*"
lrn=$(($lrn+1))
printf ">> `date`: $lrn: ${run}\n" >> $logfile
$run 2>> $logfile
ec=$?
printf "exit code: $ec\n" #|tee -a $logfile
#[ ! $ec -eq 0 ] && printf "\nError running $exe; exit code: $ec; aborting.\n" |tee -a $logfile && exit 1
}

#create a variable for the subject list given by the wrapper script
subjlist=$1

#create variables for subj, scanid, the path to the ONM subject directory, DTI directory and raw nifti image, and various files needed for processing
subj=$(cat $subjlist|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing
scanid=`echo $subj |cut -d '_' -f2`;
path=/import/monstrum/ONM/subjects/
dtidir=`ls -d $path$subj/*DTI* | cut -d "/" -f 7`
dti_image=`ls $path$subj/$dtidir/bbl/raw_dti/*DTI*.nii.gz`

#these text files are created by DRR for ONM DTI and do not change between ONM subjects
acqparams=/import/monstrum/ONM/scripts/DTI/acqparams.txt
indexfile=/import/monstrum/ONM/scripts/DTI/index.txt

#these are the subject specific bvec and bval files
bvecs=`ls $path$subj/$dtidir/bbl/raw_dti/*DTI*.bvec`
bvals=`ls $path$subj/$dtidir/bbl/raw_dti/*DTI*.bval`

#this is the error output file, a variable with the date, and the log file output for each subject
process_fail=/import/monstrum/ONM/scripts/DTI/dti_process_fail.csv
date=`date +%Y-%m-%d`
logfile=$path$subj/$dtidir/bbl/$scanid"_logfile_process_"$date".log"

#print to the screen the subject id you are processing
echo "....................Processing subject "$subj


#Make DTI coverage mask for each subject by backtransforming FSL's FMRIB58 DTI mask to native space
#Register single b=0 dwi image to FMRIB58 DTI FA map		
		if [ -e $path$subj/$dtidir/bbl/qa/*DTI*b0mean.nii ] ; then
		echo "move b=0 image to standard space"
		logrun flirt -dof 6 -in $path$subj/$dtidir/bbl/qa/*DTI*b0mean.nii -ref /import/monstrum/Applications/fsl5/data/standard/FMRIB58_FA_1mm.nii.gz -out $path$subj/$dtidir/bbl/raw_dti/$scanid"_dwi_n_standard_space.nii.gz" -omat $path$subj/$dtidir/bbl/raw_dti/$scanid"_dwi_n_standard_space.mat"
		echo "dwi to std space done"
		else
		echo "ERROR: no mean b=0 image"
		error_msg1="ERROR: no b=0 image"
		fi		

#Invert transform
		if [ -e $path$subj/$dtidir/bbl/raw_dti/$scanid"_dwi_n_standard_space.mat" ] ; then
		logrun convert_xfm -omat $path$subj/$dtidir/bbl/raw_dti/$scanid"_std_n_dwi_space.mat" -inverse $path$subj/$dtidir/bbl/raw_dti/$scanid"_dwi_n_standard_space.mat"
		else
		echo "ERROR: dwi to standard not run"
		error_msg2="ERROR: dwi to standard not run"
		fi

#Transform FMRIB58 FA to single subject space
		if [ -e $path$subj/$dtidir/bbl/raw_dti/$scanid"_std_n_dwi_space.mat" ] ; then
		logrun flirt -in /import/speedy/eons/progs/DTI/FMRIB58_mask.nii.gz -ref $path$subj/$dtidir/bbl/qa/*DTI*b0mean.nii -interp nearestneighbour -applyxfm -init $path$subj/$dtidir/bbl/raw_dti/$scanid"_std_n_dwi_space.mat" -out $path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz
		else
		echo "ERROR: inverse transformation matrix does not exist"
		error_msg3="ERROR: inverse transformation matrix does not exist"
		fi

#Run FSL EDDY for motion correction and eddy current correction (should be done before distortion correction -per FSL's Mark Jenkinson
	
		if [ -e $dti_image ] ; then
		logrun eddy --imain=$dti_image --mask="$path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz" --acqp=$acqparams --index=$indexfile --bvecs=$bvecs --bvals=$bvals --out="$path$subj/$dtidir/bbl/eddy_results/"$scanid"_eddy"
		else
		echo "ERROR: merged DTI image does not exist"
		error_msg4="ERROR: merged DTI image does not exist"
		fi

#Extract Motion Parameters from EDDY Corrected data 

		if [ -e $path$subj/$dtidir/bbl/eddy_results/"$scanid"_eddy.eddy_parameters ] ; then 
		echo "eddy was run....time to extract 6 motion parameters"
		logrun cat $path$subj/$dtidir/bbl/eddy_results/"$scanid"_eddy.eddy_parameters | sed "s/  / /g" | cut  -d " " -f 1-6 > $path$subj/$dtidir/bbl/eddy_results/$scanid.6param.eddy_parameters
		else 
		echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi

#Rotate bvecs file after motion correction
		if [ -e $path$subj/$dtidir/bbl/eddy_results/"$scanid"_eddy.eddy_parameters ] ; then
		logrun /import/speedy/scripts/bin/ME_rotate_bvecs.sh $bvecs $path$subj/$dtidir/bbl/raw_dti/$scanid".dti_rotated.bvec" $path$subj/$dtidir/bbl/eddy_results/"$scanid"_eddy.eddy_parameters
		else 
		echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi

#Apply distortion correction using field map
		if [ -e $path$subj/B0_map_new/mag1_t1bet.nii.gz ] && [ -e $path$subj/B0_map_new/rpsmap_t1bet.nii.gz ] && [ -e $path$subj/B0_map_new/t1bet2b0_mask.nii.gz ] ; then
		cd $path$subj/$dtidir/bbl/eddy_results/dico_corrected
		echo "running distortion correction"
		logrun dico_correct_v2.sh -n -k -f $path$subj/B0_map_new/mag1_t1bet.nii.gz -e $path$subj/$dtidir/dicoms/*00.dcm $path$subj/$dtidir/bbl/eddy_results/dico_corrected/$scanid".dico." $path$subj/B0_map_new/rpsmap_t1bet.nii.gz $path$subj/B0_map_new/t1bet2b0_mask.nii.gz $path$subj/$dtidir/bbl/eddy_results/$scanid"_eddy.nii.gz"
		cd $path
		else 
		echo "ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		error_msg6="ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		fi

#Estimate tensors with and without motion regressors for distortion corrected (rotated b-vectors)
		if [ -e $path$subj/$dtidir/bbl/eddy_results/dico_corrected/$scanid.dico_dico.nii ] ; then
	#Estimate tensor without confound regressors and with rotated b-vectors file
		echo "moving on to next, using rotated bvecs, no CNI"
		logrun dtifit -k $path$subj/$dtidir/bbl/eddy_results/dico_corrected/$scanid.dico_dico.nii -o $path$subj/$dtidir/bbl/dtifit/dico_corrected/no_motion_regressors/dti_eddy_no_CNI_rotated_bvecs -m $path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz -r $path$subj/$dtidir/bbl/raw_dti/$scanid".dti_rotated.bvec" -b $bvals
	#Estimate tensor with confound regressors and with rotated b-vectors file
		echo "moving on to next, using 6 parameter motion as confound regressors and rotating bvecs"
		logrun dtifit -k $path$subj/$dtidir/bbl/eddy_results/dico_corrected/$scanid.dico_dico.nii -o $path$subj/$dtidir/bbl/dtifit/dico_corrected/motion_regressors/dti_eddy_with_CNI_rotated_bvecs -m $path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz -r $path$subj/$dtidir/bbl/raw_dti/$scanid".dti_rotated.bvec" -b $bvals --cni=$path$subj/$dtidir/bbl/eddy_results/$scanid.6param.eddy_parameters
		echo "running dtifit in standard FSL pipeline"
		else
		echo "ERROR: DTIFIT fail- dico corrected"
		error_msg7="ERROR: DTIFIT fail- dico corrected"
		echo $subj $error_msg1 $error_msg2 $error_msg3 $error_msg4 $error_msg5 $error_msg6 $error_msg7 >> $process_fail
		fi

#Estimate tensors with and without motion regressors for non-distortion corrected (rotated bvecs)
		if [ -e $path$subj/$dtidir/bbl/eddy_results/$scanid"_eddy.nii.gz" ] ; then
		logrun dtifit -k $path$subj/$dtidir/bbl/eddy_results/$scanid"_eddy.nii.gz" -o $path$subj/$dtidir/bbl/dtifit/non_dico_corrected/no_motion_regressors/dti_eddy_no_CNI_rotated_bvecs -m $path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz -r $path$subj/$dtidir/bbl/raw_dti/$scanid".dti_rotated.bvec" -b $bvals
		#motion regressor
		echo "moving on to next, using 6 parameter motion as confound regressors"
		logrun dtifit -k $path$subj/$dtidir/bbl/eddy_results/$scanid"_eddy.nii.gz" -o $path$subj/$dtidir/bbl/dtifit/non_dico_corrected/motion_regressors/dti_eddy_with_CNI_rotated_bvecs -m $path$subj/$dtidir/bbl/raw_dti/dtistd_2_$scanid.mask.nii.gz -r $path$subj/$dtidir/bbl/raw_dti/$scanid".dti_rotated.bvec" -b $bvals --cni=$path$subj/$dtidir/bbl/eddy_results/$scanid.6param.eddy_parameters
		echo "running dtifit in standard FSL pipeline"
		else
		echo "ERROR: DTIFIT fail- non-dico corrected"
		error_msg8="ERROR: DTIFIT fail- non-dico corrected"
		echo $subj $error_msg1 $error_msg2 $error_msg3 $error_msg4 $error_msg5 $error_msg6 $error_msg7 $error_msg8 >> $process_fail
		fi
