scriptdir=/import/monstrum/ONM/scripts/B0
rm -f B0_error_log.txt
for line in `cat /import/monstrum/ONM/scripts/download/onm_audit_*.csv | sed -n 2,'$'p` 
do
i=`echo $line | cut -d "," -f 1 | cut -c 3-`
has_B0=`echo $line | cut -d "," -f 3`
rps_check=`ls /import/monstrum/ONM/subjects/*$i/B0_map_new/rpsmap_t1bet.nii.gz 2> /dev/null`
#i=2894 #for testing on one subject
#if grep -q $i'$' /import/monstrum/eons_xnat/progs/ASL/b0/eons_b0_list_10.24.13.txt #make sure subject has B0. Not necessary if list is already restricted.
#then

if [ $has_B0 == 1 ] && [ "X$rps_check" == "X" ];then

subdir=`ls -d /import/monstrum/ONM/subjects/*$i`
cor=`ls $subdir/*MPRAGE*moco3/biascorrection/*_corrected.nii.gz | grep -v NAV`
cor_brain=`ls $subdir/*MPRAGE*moco3/biascorrection/*_correctedbrain.nii.gz | grep -v NAV`
B0_folders=`ls -d $subdir/*B0map*/dicoms 2> /dev/null`

	if [ "X$B0_folders" == "X" ];then
	echo "download B0"
	/import/monstrum/ONM/scripts/download/onm_b0_downloader.py $i $subdir
	B0_folders=`ls -d $subdir/*B0map*/dicoms`
	fi

#make sure there are 2 B0 folders, and that dico_calc hasn't already been run
count=`echo $B0_folders | wc -w`
calc_check=`ls $subdir/B0_map_new/*rpsmap.nii`
	if [ "X$calc_check" == "X" ] && [ $count == 2 ];then
	echo "****** running dico calc for" $i
	echo $cor
	echo $cor_brain
	echo $B0_folders
	echo $B0_folders | wc -w
	echo ""

	mkdir -p $subdir/B0_map_new
	cd $subdir/B0_map_new

	/import/speedy/scripts/melliott/dico_b0calc_v3.sh -kFmxS "test_RUN01" $B0_folders
	cd $scriptdir
	elif [ "X$calc_check" != "X" ];then
	echo $i "- dico_calc already run"
	elif [ $count != 2 ];then
	echo $i "- wrong number of sequences found -" $count
	echo $i "- wrong number of sequences found -" $count >> B0_error_log.txt
	fi # if [ "X$calc_check" == "X" ] && [ $count == 2 ];then

#######mask with t1
b0path=`ls -d $subdir/B0_map_new`
	if [ $count == 2 ] && [ "X$cor" != "X" ] && [ "X$cor_brain" != "X" ];then

	t1_brain=$(ls -d $subdir/*MPRAGE*moco3/biascorrection/*correctedbrain.nii.gz | grep -v NAV)
	t1_head=$(ls -d $subdir/*MPRAGE*moco3/biascorrection/*corrected.nii.gz | grep -v NAV)
	fmap_head=$(ls -d $b0path/*mag1.nii)
	rps_head=$(ls -d $b0path/*rpsmap.nii)

	echo "t1 head is $t1_head"
	echo "t1 brain is $t1_brain"
	echo "fmap is $fmap_head"

	echo ""

	echo "running flirt"
	flirt -in $t1_head -ref $fmap_head -omat $b0path/struct2b0.mat -dof 6

	echo "applying flirt transform to brain extracted image"
	flirt -in $t1_brain -ref $fmap_head -applyxfm -init $b0path/struct2b0.mat -out $b0path/t1bet2b0

	echo "creating and applying mask"
	fslmaths $b0path/t1bet2b0 -bin $b0path/t1bet2b0_mask
	fslmaths $fmap_head -mas $b0path/t1bet2b0_mask $b0path/mag1_t1bet
	fslmaths $rps_head -mas $b0path/t1bet2b0_mask $b0path/rpsmap_t1bet

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


elif [ "X$rps_check" != "X" ];then
echo "Already run for $i"
elif [ $has_B0 == 0 ];then
echo "No B0 in xnat for $i"
else
echo "******* Error for $i"
fi # if [ $has_B0 == 1 ] && [ "X$rps_check" == "X" ];then

#fi
done
