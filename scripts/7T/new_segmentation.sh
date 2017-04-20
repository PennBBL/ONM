#cat /import/monstrum/ONM/7T/tmp_3_3/subject_list.txt | while read id

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

EP_nifti_new=/import/monstrum/ONM/7T/subjects/$id_7T/DR/"$id_7T"_EP_cest_DR.nii
mOFC_nifti_new=/import/monstrum/ONM/7T/subjects/$id_7T/PR/"$id_7T"_mOFC_cest_PR.nii

#/import/monstrum/Applications/fsl5/bin/fslchfiletype NIFTI_GZ $EP_nifti_new
#/import/monstrum/Applications/fsl5/bin/fslchfiletype NIFTI_GZ $mOFC_nifti_new

mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/
mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_registered/
mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/


#Right lateral ventricle

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 43 -thr 43 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_lateral_ventricle.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_lateral_ventricle.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_lateral_ventricle_RPI.nii.gz


#Right Inf-Lat-Vent

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 44 -thr 44 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_Inf-Lat-Vent.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_Inf-Lat-Vent.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_Inf-Lat-Vent_RPI.nii.gz

#Right Cerebellum White Matter

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 46 -thr 46 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_wm.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_wm.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_wm_RPI.nii.gz

#Right Cerebellum Cortex

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 47 -thr 47 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_cortex.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_cortex.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_cerebellum_cortex_RPI.nii.gz

#Right Thalamus-Proper

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 49 -thr 49 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_thalamus_proper.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_thalamus_proper.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_thalamus_proper_RPI.nii.gz

#Right Caudate

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 50 -thr 50 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate_RPI.nii.gz

#Right Putamen

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 51 -thr 51 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_putamen.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_putamen.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_putamen_RPI.nii.gz

#Right Pallidum

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 52 -thr 52 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_pallidum.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_pallidum.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_pallidum_RPI.nii.gz

#Right Caudate

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 50 -thr 50 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_caudate_RPI.nii.gz

#Right hippocampus

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 53 -thr 53 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_hippocampus.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_hippocampus.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_hippocampus_RPI.nii.gz

#Right amygdala

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 54 -thr 54 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_amygdala.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_amygdala.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_amygdala_RPI.nii.gz

#Right Accumbens-area

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 58 -thr 58 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_accumbens_area.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_accumbens_area.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_accumbens_area_RPI.nii.gz

#Right VentralDC

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 60 -thr 60 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_ventralDC.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_ventralDC.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_ventralDC_RPI.nii.gz

#Right Vessel

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 62 -thr 62 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_vessel.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_vessel.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_vessel_RPI.nii.gz

#Right Choroid-plexus

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/$id_3T"_aseg2raw_RPI.nii.gz" -uthr 63 -thr 63 /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_choroid_plexus.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_choroid_plexus.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/"$bblid"_right_choroid_plexus_RPI.nii.gz

#Extract glucest information in axial slice

#for j in /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/*_RPI.nii.gz
	#do

	#echo $j 

	#name=`echo $j | cut -d "." -f1`
	#name_use=`echo $name | cut -d "/" -f11`

	#antsApplyTransforms -d 3 -n MultiLabel -i $j -o /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_registered/"$name_use"_2_7T.nii.gz -r /import/monstrum/ONM/7T/subjects/$id_7T/*MPRAGE*/*.nii* -t /import/monstrum/ONM/7T/tmp_3_3/reg/"$bblid"_3T_2_7T0GenericAffine.mat

	#echo "Start extracting $name_use slice"  
	
	#echo $name
	#echo $name_use

	#extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_registered/"$name_use"_2_7T.nii.gz $EP_nifti_new /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$name_use"_EP_cest_ROI.nii.gz

#creates ROI from registered ROI onto the CEST map image mOFC nifti
	

	#echo "Done extracting $name_use slice" 
		
	#roi_data=$(fslstats $EP_nifti_new -k /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$name_use"_EP_cest_ROI.nii.gz -M -S -V)
	
	#echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_EP_aseg_glucest_data.txt

	#echo "Done $name_use slice" 

	#done


#Extract glucest data from mOFC slice
for j in /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_rois/*_RPI.nii.gz
	do

	echo $j 

	name=`echo $j | cut -d "." -f1`
	name_use=`echo $name | cut -d "/" -f11`

	antsApplyTransforms -d 3 -n MultiLabel -i $j -o /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_registered/"$name_use"_2_7T.nii.gz -r /import/monstrum/ONM/7T/subjects/$id_7T/*MPRAGE*/*.nii* -t /import/monstrum/ONM/7T/tmp_3_3/reg/"$bblid"_3T_2_7T0GenericAffine.mat

	echo "Start extracting $name_use slice"  
	
	echo $name
	echo $name_use

	extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_registered/"$name_use"_2_7T.nii.gz $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$name_use"_mOFC_cest_ROI.nii.gz

#creates ROI from registered ROI onto the CEST map image mOFC nifti
	

	echo "Done extracting $name_use slice" 
		
	roi_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$name_use"_mOFC_cest_ROI.nii.gz -M -S -V)
	
	echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_mOFC_aseg_glucest_data.txt

	echo "Done $name_use slice" 

	done


fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_accumbens_area_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_amygdala_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_caudate_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_cerebellum_cortex_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_cerebellum_wm_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_choroid_plexus_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_hippocampus_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_Inf-Lat-Vent_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_lateral_ventricle_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_pallidum_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_putamen_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_thalamus_proper_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_ventralDC_RPI_mOFC_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_vessel_RPI_mOFC_cest_ROI.nii /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_combined_mOFC_rois.nii

fslmaths /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_accumbens_area_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_amygdala_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_caudate_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_cerebellum_cortex_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_cerebellum_wm_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_choroid_plexus_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_hippocampus_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_Inf-Lat-Vent_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_lateral_ventricle_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_pallidum_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_putamen_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_thalamus_proper_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_ventralDC_RPI_EP_cest_ROI.nii -add  /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_right_vessel_RPI_EP_cest_ROI.nii /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/aseg_extract/"$bblid"_combined_EP_rois.nii

done
	
