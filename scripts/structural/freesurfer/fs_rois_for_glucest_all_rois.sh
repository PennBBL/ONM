#this script takes all freesurfer rois and converts the labels to volumes for each subject, then it takes each ONM 7t subject and each 7T roi and extracts glucest (see DRR for details on this script)

#Need to be in /import/monstrum/ONM/freesurfer/subjects to run this script
#Set Subjects directory to ONM:
SUBJECTS_DIR=/import/monstrum/ONM/group_results/freesurfer/subjects
source /import/monstrum/Applications/freesurfer/SetUpFreeSurfer.sh

#for each ONM subject
for i in "$SUBJECTS_DIR"/*_*
do

#create a variable with their subject id and print that to the screen
subid=`basename $i`;
echo " Processing subject "$subid

#create variables for the ROIs directory and ROI_volumes directory in each subject's freesurfer group results directory 
roisfolder=$(ls -d "$i"/ROIs)
volfolder=$(ls -d "$i"/ROI_volumes)

#check if ROI volume folder is present or else make one
if [ ! -d "$volfolder" ]; then
	echo "ROI_volumes folder does not exist..creating folder for this subject"
	mkdir "$i"/ROI_volumes;

#for each label file in the ROIs folder
for j in `ls -d $roisfolder/*.label`
do

#print that label file to the screen
echo $j

#create variables for the hemisphere and ROI name for that label file
hemi=`echo $j | cut -d "/" -f 10 | cut -d "." -f 1`
ROI=`echo $j | cut -d "/" -f 10 | cut -d "." -f 2`

#Surface label to Volume for each ROI
mri_label2vol --label $j --temp "$i"/mri/rawavg.mgz --subject $subid --hemi $hemi --o "$i"/ROI_volumes/"$subid"_"$hemi"_"$ROI".nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;

#force RPI as mri_convert defaults to RAI
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROI_volumes/"$subid"_"$hemi"_"$ROI".nii.gz "$i"/ROI_volumes/"$subid"_"$hemi"_"$ROI"_RPI.nii.gz

#Make ROI volume mask binary
fslmaths "$i"/ROI_volumes/"$subid"_"$hemi"_"$ROI"_RPI.nii.gz -bin "$i"/ROI_volumes/"$subid"_"$hemi"_"$ROI"_RPI_mask.nii.gz
 
done

echo "finished converting label to volume ...."

fi

done


#Extract GluCEST

#for each ONM 7T subject
for s in /import/monstrum/ONM/7T/subjects/*_*; do
	
	#get variables for the subject id and 7t scanid for each subject
	subjid=`echo $s |cut -d '/' -f7 | cut -d "_" -f1`;
	echo $subjid
	sevent_scanid=`echo $s |cut -d '/' -f7 | cut -d "_" -f2`


#move ROIs nii.gz's from fs to the subject's fs_ROIs 7T folder
mkdir /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/7T_ROIs/all_fs_ROIs/
cp /import/monstrum/ONM/group_results/freesurfer/subjects/$subjid"_"*/ROI_volumes/*RPI.nii.gz /import/monstrum/ONM/7T/subjects/$subjid"_"*/7T_ROIs/all_fs_ROIs/

#make a processed GluCEST ROIs directory
#mkdir /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/GluCEST
#mkdir /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/GluCEST/mOFC/
mkdir /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/GluCEST/mOFC/processed_GluCEST_ROIs

#create a variable which gets the B0B1CESTmap for that subject
#glucest_mOFC=/import/monstrum/ONM/7T/subjects/$subjid"_"*/GluCEST/mOFC/S0994_CESTMAP/*.nii
glucest_mOFC=/import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/GluCEST/mOFC/B0B1CESTmap.nii

#Create MPRAGE slice
echo "extract ROI slice from MPRAGE"
/import/speedy/scripts/bin/extract_slice.sh $s/*MPRAGE_iPAT2/nifti/*.nii* $glucest_mOFC $s/GluCEST/mOFC/$subjid.mOFC_structrual_slice2.nii

#for each ROI within each subject
#for j in /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/7T_ROIs/all_fs_ROIs/120217_8969_rh_medialorbitofrontal_RPI.nii.gz; do
for j in /import/monstrum/ONM/7T/subjects/$subjid"_"$sevent_scanid/7T_ROIs/120217_8969_rh_medialorbitofrontal_RPI.nii.gz; do

#ROI=`echo $j | cut -d "/" -f 10 | cut -d "." -f 1 | cut -d "_" -f 3- | rev | cut -d "_" -f2- | rev`
#sub_3t=`echo $j | cut -d "/" -f 10 | cut -d "." -f 1 | cut -d "_" -f 1-2`

ROI="rh_mofc_test"
sub_3t="120217_8969"

		#Create ROI slice to match the CEST map for each ROI
		if [ -e $glucest_mOFC ]; then 
		echo "***********************************************"
		echo "mOFC GluCEST exists, extracting" $ROI "slice"
		echo "***********************************************"
		#/import/speedy/scripts/bin/extract_slice.sh $s/7T_ROIs/all_fs_ROIs/$Imscribe $glucest_mOFC $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice.nii
/import/speedy/scripts/bin/extract_slice.sh $s/7T_ROIs/$Imscribe $glucest_mOFC $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice.nii
		fslmaths $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice.nii -thr 0.50 $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice_thr.nii.gz		
		fslmaths $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice_thr.nii.gz -bin $s/GluCEST/mOFC/processed_GluCEST_ROIs/$subjid.$ROI._CEST_slice_binary_mask.nii.gz
		else
		echo "###########################################"
		echo "mOFC GluCEST does NOT exist, skipping"
		echo "###########################################"	
		fi

done
done

