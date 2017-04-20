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

#!/bin/bash

###check for necessary software/scripts
fsl=`ls $FSLDIR/bin/feat 2> /dev/null`
seq2nifti=`ls /import/speedy/scripts/melliott/sequence2nifti.sh 2> /dev/null`
dti_qa=`ls /import/speedy/scripts/melliott/qa_dti_v1.sh 2> /dev/null`
if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
echo "All necessary programs/scripts found."
echo "Checking for necessary files by subject."

####
#List of subjects to be analyzed
subjects=`cat /import/monstrum/ONM/scripts/download/*_audit_*.csv | sed -n 2,'$'p | cut -d ',' -f1,9`
#subjects=`cat /import/monstrum/ONM/scripts/DTI/ONM_ids.csv`

#List to be populated for grid submission
joblist=/import/monstrum/ONM/scripts/DTI/onm_joblist.txt

#List of subjects missing base DTI file
no_merge_dti=/import/monstrum/ONM/scripts/DTI/onm_dti_missing.csv

#Remove all previous versions of joblist and missing 
rm -f $joblist
rm -f $no_dti
rm -f $process_fail
#rm -f ~/eddy_logs/*

for l in $subjects; do 
	subid=`echo $l |cut -d ',' -f2`
	#subid=`echo $l | cut -d "_" -f 1`
	subid1stchar=`echo $subid | cut -c 1`
	[ $subid1stchar == "0" ] && subid=`echo $subid | cut -c 2-6`
	scanid=`echo $l |cut -d ',' -f1`
	scanid2ndchar=`echo $scanid | cut -c 2`
	[ $scanid2ndchar == "0" ] && scanid=`echo $scanid | cut -c 3-`
	[ $scanid2ndchar != "0" ] && scanid=`echo $scanid | cut -c 2-`
	date=`date +%Y-%m-%d`	
	s=`echo "$subid"_"$scanid"`
	i=/import/monstrum/ONM/subjects/$s
	dtidir=`ls -d $i/*DTI* | cut -d "/" -f 7`
	logfile=$i/$dtidir/bbl/$scanid"_logfile_pipeline_"$date".log"
	echo "........................... Processing subject "$s

grep -q $scanid /import/monstrum/ONM/scripts/download/onm_excludes.csv && continue

#Check if 'bbl' folder exists (dtifit is the last folder populated), if not make one
		if [ ! -e $i/$dtidir/bbl/dtifit/dico_corrected/motion_regressors ]; then
		echo "making bbl directory"
		mkdir $i/$dtidir/bbl
		mkdir $i/$dtidir/bbl/raw_dti
		mkdir $i/$dtidir/bbl/qa
		mkdir $i/$dtidir/bbl/eddy_results
		mkdir $i/$dtidir/bbl/eddy_results/dico_corrected
		mkdir $i/$dtidir/bbl/dtifit
		mkdir $i/$dtidir/bbl/dtifit/dico_corrected
		mkdir $i/$dtidir/bbl/dtifit/non_dico_corrected
		mkdir $i/$dtidir/bbl/dtifit/non_dico_corrected/no_motion_regressors
		mkdir $i/$dtidir/bbl/dtifit/non_dico_corrected/motion_regressors
		mkdir $i/$dtidir/bbl/dtifit/dico_corrected/no_motion_regressors
		mkdir $i/$dtidir/bbl/dtifit/dico_corrected/motion_regressors
		else
		echo "BBL DTI folder structure complete"
		fi

# copy dti.nii.gz and associated bvecs and bvals files to working DTI directory
cp $i/$dtidir/nifti/*.bvec $i/$dtidir/bbl/raw_dti
cp $i/$dtidir/nifti/*.bval $i/$dtidir/bbl/raw_dti
cp $i/$dtidir/nifti/*.nii.gz $i/$dtidir/bbl/raw_dti

dti_nii_gz_out=`ls $i/$dtidir/bbl/raw_dti/*DTI*.nii.gz`

#If QA has already been run, then skip the next two steps

qa_file=`ls $i/$dtidir/bbl/qa/"$scanid".qa`

	if [ "X$qa_file" == "X" ] ; then 
		#Run QA on DTI file
		if [ -e "$dti_nii_gz_out" ] ; then		
		echo "running QA"
		logrun /import/speedy/scripts/melliott/qa_dti_v1.sh $i/$dtidir/bbl/raw_dti/*DTI*.nii.gz $i/$dtidir/bbl/raw_dti/*.bval /$i/$dtidir/bbl/raw_dti/*.bvec $i/$dtidir/bbl/qa/"$scanid".qa
		echo "QA complete"
		else
		echo "no DTI, skipping"
		fi

		#Create list of subjects to run DTI processing steps
		if [ -e "$dti_nii_gz_out" ]; then 
		echo $s >> $joblist
		else
		echo $s >> $no_dti 
		fi
	elif [ ! "X$qa_file" == "X" ] ; then
	echo "QA complete"
	fi #if [ "X$qa_file" == "X" ] ; then 

done #for l in $subjects; do 

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q all.q -S /bin/bash -o ~/onm_dti_logs -e ~/onm_dti_logs -t 1-${ntasks} /import/monstrum/ONM/scripts/DTI/ONM_DTI_process.sh $joblist

else
echo "*******"
echo "ERROR: One or more of the scripts required to quantify and register DTI is missing."
echo "FSL: "$fsl
echo "seq2nifiti: "$seq2nifiti
echo "dti_qa: "$dtiqa
echo "*******"

fi #if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
