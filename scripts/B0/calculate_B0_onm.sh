#This script is a standard monstrum BBL script that was created to take the B0 magnitude and phase scans and ultimately output a B0_mask_new directory which calculates rps maps and b0 scans masked by the T1. 

########################################################
###########VARIABLE CREATION AND DATA PREP##############
########################################################

#the B0 script directory where the error log should be output
scriptdir=/import/monstrum/ONM/scripts/B0

#remove any previous error logs so they can be repopulated with this run
rm -f B0_error_log.txt

#for each subject in the audit csv (created by the download script)
for line in `cat /import/monstrum/ONM/scripts/download/onm_audit_*.csv | sed -n 2,'$'p` 
do

#create variables for scanid (i), if the B0 scan is present (has_B0), and if the rps map has already been created (i.e. this script has been run on the subject before- rps_check)
i=`echo $line | cut -d "," -f 1 | cut -c 3-`
has_B0=`echo $line | cut -d "," -f 3`
rps_check=`ls /import/monstrum/ONM/subjects/*$i/B0_map_new/rpsmap_t1bet.nii.gz 2> /dev/null`

#############################################
###########PROCESS THE B0 SCANS##############
#############################################

#if the subject has B0 scans but this script has not been complete on them yet then
if [ $has_B0 == 1 ] && [ "X$rps_check" == "X" ];then

#get the subject's subject directory, their bias corrected MPRAGE (created by the download script), and the path to both of their B0 dicoms (magnitude and phase)
subdir=`ls -d /import/monstrum/ONM/subjects/*$i`
cor=`ls $subdir/*MPRAGE*moco3/biascorrection/*_corrected.nii.gz | grep -v NAV`
cor_brain=`ls $subdir/*MPRAGE*moco3/biascorrection/*_correctedbrain.nii.gz | grep -v NAV`
B0_folders=`ls -d $subdir/*B0map*/dicoms 2> /dev/null`

	#if there are no B0 dicoms, then download the subject's B0 scans from xnat and re-populate the B0 path to the dicoms
	if [ "X$B0_folders" == "X" ];then
	echo "download B0"
	/import/monstrum/ONM/scripts/download/onm_b0_downloader.py $i $subdir
	B0_folders=`ls -d $subdir/*B0map*/dicoms`
	fi

#count the number of B0 folders (there should be 2- mag and phase)
count=`echo $B0_folders | wc -w`

#check if the rps map exists
calc_check=`ls $subdir/B0_map_new/*rpsmap.nii`

	#if the rps map doesn't exist (i.e. this script hasn't been run for the subject), and there are 2 B0 directories as there should be then
	if [ "X$calc_check" == "X" ] && [ $count == 2 ];then

	#print out the following variables and text
	echo "****** running dico calc for" $i
	echo $cor
	echo $cor_brain
	echo $B0_folders
	echo $B0_folders | wc -w
	echo ""

	#make a B0_map_new directory in their subject's directory and cd into that directory
	mkdir -p $subdir/B0_map_new
	cd $subdir/B0_map_new

	#do distortion correction on the B0 using the script below written by Mark Elliott
	/import/speedy/scripts/melliott/dico_b0calc_v3.sh -kFmxS "test_RUN01" $B0_folders
	cd $scriptdir
	
	#alternatively, if the script has already been run, print that out
	elif [ "X$calc_check" != "X" ];then
	echo $i "- dico_calc already run"
	
	#alternatively, if there are not two B0 directories (mag and phase) then output an error to the error log
	elif [ $count != 2 ];then
	echo $i "- wrong number of sequences found -" $count
	echo $i "- wrong number of sequences found -" $count >> B0_error_log.txt
	fi # if [ "X$calc_check" == "X" ] && [ $count == 2 ];then

#create a variable which gets the path to the newly created B0_map_new directory
b0path=`ls -d $subdir/B0_map_new`

	#if there are 2 B0 scans directories, and there are bias corrected MPRAGE brains then
	if [ $count == 2 ] && [ "X$cor" != "X" ] && [ "X$cor_brain" != "X" ];then

	#create variables for bias corrected MPRAGE's (bet and non-bet), the mag1 image created above and the rps image created above
	t1_brain=$(ls -d $subdir/*MPRAGE*moco3/biascorrection/*correctedbrain.nii.gz | grep -v NAV)
	t1_head=$(ls -d $subdir/*MPRAGE*moco3/biascorrection/*corrected.nii.gz | grep -v NAV)
	fmap_head=$(ls -d $b0path/*mag1.nii)
	rps_head=$(ls -d $b0path/*rpsmap.nii)

	#pring out those variables to the screen
	echo "t1 head is $t1_head"
	echo "t1 brain is $t1_brain"
	echo "fmap is $fmap_head"

	echo ""

	#register the mprage (both bet and non-bet) to the b0
	echo "running flirt"
	flirt -in $t1_head -ref $fmap_head -omat $b0path/struct2b0.mat -dof 6

	echo "applying flirt transform to brain extracted image"
	flirt -in $t1_brain -ref $fmap_head -applyxfm -init $b0path/struct2b0.mat -out $b0path/t1bet2b0
	
	#mask the B0 output by the t1 image
	echo "creating and applying mask"
	fslmaths $b0path/t1bet2b0 -bin $b0path/t1bet2b0_mask
	fslmaths $fmap_head -mas $b0path/t1bet2b0_mask $b0path/mag1_t1bet
	fslmaths $rps_head -mas $b0path/t1bet2b0_mask $b0path/rpsmap_t1bet

	#alternatively if there are not 2 B0 scans, or if there is no bias corrected MPRAGE scans (bet or non-bet) output an error to the error log
	elif [ $count != 2 ];then
	echo "$i - wrong number of sequences found"
	echo "$i - wrong number of sequences found" >> B0_error_log.txt
	elif [ "X$cor" == "X" ];then
	echo "$i - no corrected T1 found"
	echo "$i - no corrected T1 found" >> B0_error_log.txt
	elif [ "X$cor_brain" == "X" ];then
	echo "$i - no bet corrected T1 found"
	echo "$i - no bet corrected T1 found" >> B0_error_log.txt
	fi # if [ $count == 2 ] && [ "X$cor" != "X" ] && [ "X$cor_brain" != "X" ];then


#alternatively, if the rps image already exists then don't run the script
elif [ "X$rps_check" != "X" ];then
echo "Already run for $i"

#alternatively if the subject has no B0 in xnat then don't run the script
elif [ $has_B0 == 0 ];then
echo "No B0 in xnat for $i"

#if none of these things are met then print to the screen an error message for the subject
else
echo "******* Error for $i"
fi # if [ $has_B0 == 1 ] && [ "X$rps_check" == "X" ];then

#fi
done
