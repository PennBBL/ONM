for id in `cat /import/monstrum/ONM/7T/tmp_3_3/subs_redo3t7t.csv`;

do

echo $id


bblid=`echo $id | cut -d "_" -f1`

echo $bblid

scanid_3T=`echo $id | cut -d "_" -f2`

echo $scanid_3T

scanid_7T=`echo $id | cut -d "_" -f3`

echo $scanid_7T

id_3T=$bblid"_"$scanid_3T
id_7T=$bblid"_"$scanid_7T


#CEST images

mOFC_nifti_new=/import/monstrum/ONM/7T/subjects/$id_7T/PR/"$id_7T"_mOFC_cest_PR.nii
echo $mOFC_nifti_new

mkdir /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/


for j in /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_rois/*_RPI.nii.gz
	do

	echo $j 

	name=`echo $j | cut -d "." -f1`
	name_use=`echo $name | cut -d "/" -f11`
echo "Start extracting $name_use slice"  
	
	echo $name
	echo $name_use

	extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_registered/"$name_use"_2_7T.nii.gz $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$name_use"_mOFC_cest_ROI.nii.gz

#creates ROI from registered ROI onto the CEST map image mOFC nifti
	

	echo "Done extracting $name_use slice" 
		
	roi_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$name_use"_mOFC_cest_ROI.nii.gz -M -S -V)
	
	echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$bblid"_mOFC_wm_glucest_data.txt

	echo "Done $name_use slice" 

	done

done



