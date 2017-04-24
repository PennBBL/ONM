#this script will download all data that is checked into xnat under ONM to monstrum. It will also create subject directories in /import/monstrum/ONM/subjects for all missing subjects and convert dicoms for each scan to niftis (placing them into the appropriate directories as well). If a subject is listed as an exclusion in /import/monstrum/ONM/scripts/download/onm_excludes.csv they won't be downloaded. Note this script cannot be run twice in one day unless you delete the audit csv (i.e. onm_audit_date.csv) from today and move another one from a different date from the audit_archive directory into the /import/monstrum/ONM/scripts/download/ directory

#get the directory for the download script into a variable called dir
dir=/import/monstrum/ONM/scripts/download

#create a variable with today's date
day=`date +%m_%d_%y`

#create a variable which gets the most recent onm xnat audit file
lastrun=`ls onm_audit_*.csv | cut -d "." -f 1 | cut -d "_" -f 3,4,5`

#print the date and the name of last audit file created
echo $day
echo $lastrun

#if the most recent audit script is not from today, 
if [ $lastrun != $day ];then

#then move it into the audit_archive directory
mv $dir/onm_audit_*.csv $dir/audit_archive/

#run the onm xnat audit script and output the audit information into a new audit csv for today
$dir/onm_xnat_audit_4_2_14.py > "$dir/onm_audit_"$day".csv"
fi

#get a list of all subjects listed in the audit csv from today
slist=`cat $dir/onm_audit_*.csv | sed -n 2,'$'p`

#for every subject in subject list....
for i in $slist

#get scanid, shortened scanid (- 00), bblid, make id, and has_scantype variables
#had to make two bblids because some start with 0 in the file (and I don't want them too, they are only 5 characters long) while some don't start with 0 and are 6 characters long (and we want to keep the whole thing). This is where all those if statements and cut statements with the bblids come below
do
scanid=`echo $i | cut -d "," -f 1`
scanid_short=`echo $scanid | cut -c 3-6`
if [ `echo $i | cut -d "," -f 9 | cut -c 1` == 0 ]; then
bblid=`echo $i | cut -d "," -f 9 | cut -c 2-6`
else
bblid=`echo $i | cut -d "," -f 9`
fi
id=`echo $bblid"_"$scanid_short`

#create variables for if the subject has various scans in xnat or not (based on the onm_xnat_audit .py script run above)
has_mprage=`echo $i | cut -d "," -f 2`
has_B0=`echo $i | cut -d "," -f 3`
has_perf=`echo $i | cut -d "," -f 4`
has_t2bulb=`echo $i | cut -d "," -f 5`
has_ciss=`echo $i | cut -d "," -f 6`
has_dwi=`echo $i | cut -d "," -f 7`
has_dti=`echo $i | cut -d "," -f 8`

#set variable download to 0 and process to 0, these will be changed later in the script if a subject has a particular scan in xnat and not on monstrum
download=0
process=0

#create variables for the general ONM subjects directory and the subject specific directory (bblid_scanid)
downloaddir=/import/monstrum/ONM/subjects/
subdir=/import/monstrum/ONM/subjects/$id

#check for the scanid in the onm_excludes.csv and if it's there then skip this subject and move to the next one
grep -q $scanid_short $dir/onm_excludes.csv && continue

#for each subject, check if their scan folders are empty and if they should have data based on the onm_audit file, if they should have data, set process=1. If they do have data, just skip to the next scan type (this way we aren't constantly re-downloading data). 
echo "******************"$id"******************************"

t2bulb=`ls $subdir/*t2_BULB*/nifti/*.nii.gz`
if [ "X$t2bulb" == "X" ] && [ $has_t2bulb == 1 ];then 
echo "***missing t2bulb"
process=1
fi

mprage=`ls $subdir/*MPRAGE*moco3/nifti/*.nii.gz`
if [ "X$mprage" == "X" ] && [ $has_mprage == 1 ];then 
echo "***missing mprage"
process=1
fi

perf=`ls $subdir/*pcasl*se_we*/nifti/*.nii.gz`
if [ "X$perf" == "X" ] && [ $has_perf == 1 ];then 
echo "***missing perfusion"
process=1
fi

ciss=`ls $subdir/*ciss*/nifti/*.nii.gz`
if [ "X$ciss" == "X" ] && [ $has_ciss == 1 ];then
echo "***missing ciss"
process=1
fi

dwi=`ls $subdir/*dwi*ADC_[Am][Da][Cp]/nifti/*.nii.gz`
if [ "X$dwi" == "X" ] && [ $has_dwi == 1 ];then 
echo "***missing dwi"
process=1
fi

dti=`ls $subdir/*DTI*/nifti/*.nii.gz`
if [ "X$dti" == "X" ] && [ $has_dti == 1 ];then
echo "***missing dti"
process=1
fi

#process=1 # rdh to force download/upload regardless of files. COMMENT OUT
#if they don't have data and should (process=1) then run dicoms2nifti and download data
config=/import/monstrum/Users/megq/.xnat.cfg
	if [ $process == 1 ] && [ $has_mprage == 1 ];then
	echo "Not found. Running dicoms2nifti"
	/import/monstrum/BBL_scripts/dicoms2nifti.py -scanid $scanid -download_dicoms 1 -download 1 -upload 1 -outdir $downloaddir #convert dicoms to niftis 
/import/monstrum/BBL_scripts/dicoms2nifti.py -scanid $scanid -download_dicoms 1 -download 1 -upload 1 -outdir $downloaddir -force_unmatched 1 -seqname DTI
	else
	echo "Niftis already downloaded"
	fi

#if they don't have an mprage biascorrection folder (it's empty) and they have an mprage, then bet the mprage and biascorrect the mprage, download these files into the biascorrection folder	
	mprage_bias=`ls $subdir/*MPRAGE*moco3/biascorrection/*brain.nii.gz`
	if [ "X$mprage_bias" == "X" ] && [ $has_mprage == 1 ];then
	echo "Processing mprage"
	/import/monstrum/BBL_scripts/xnat_bet.py -scanid $scanid -download 0 -upload 1 -outdir $downloaddir -seqname mprage #bet mprage
	/import/monstrum/BBL_scripts/xnat_biascorr.py -scanid $scanid -download 0 -upload 1 -outdir $downloaddir -seqname mprage #biascorrect mprage
	/import/monstrum/BBL_scripts/xnat_downloaders/xnatdownloader.py -scanid $scanid -outdir $downloaddir
	else
	echo "MPRAGE already processed"
	fi

#if the subject should have B0 and MPRAGE and don't have any B0 dicoms, then download B0 dicoms
b0_dcm=`ls $subdir/*B0*/dicoms/*.dcm | wc -l`
	if [ $has_B0 == 1 ] && [ $has_mprage == 1 ] && [ "$b0_dcm" -lt 3 ];then
	echo "download B0"
	/import/monstrum/ONM/scripts/download/onm_b0_downloader.py $scanid $subdir 
	else
	echo "B0 already downloaded"
	fi

done



