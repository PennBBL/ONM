cat /import/monstrum/ONM/7T/subjects/subj_7t_list.txt | while read id

do

echo $id

bblid=`echo $id | cut -d "_" -f1`

echo $bblid

#make fs mask directory

mkdir /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask
echo "folder made"

#copy .nii files to new directory

cp /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/*_rh_* /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/

echo "files copied"
#make a dummy whole brain file for mask
echo /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/*_rh_Unknown_RPI_cest_ROI.nii
cp /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/*_rh_Unknown_RPI_cest_ROI.nii /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask.nii.gz"
echo "dummy file complete"

		#all .nii mask files to dummy file to make a complete wholebrain mask of rois for CEST
		for i in /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/*.nii
			do 
			fslmaths /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask.nii.gz" -add $i /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask.nii.gz"
		done

echo "mask made"

#make new mask binary
fslmaths /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask.nii.gz" -bin /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask_binary.nii.gz"

echo "mask made binary"

#volume of wb mask
raw_mask_vol=$(fslstats /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask_binary.nii.gz" -V) 

#mask raw cest by wb_mask
fslmaths /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask_binary.nii.gz" -mul /import/monstrum/ONM/7T/subjects/$id/DR/$id"_mOFC_cest_DR.nii" /import/monstrum/ONM/7T/subjects/$id/DR/$bblid"_cest_by_wb_mask.nii.gz" 

echo "cest masked"

#multiply wb_mask by b0 binary mask
fslmaths /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask_binary.nii.gz" -mul /import/monstrum/ONM/7T/subjects/$id/DR/B0MAP/$id"_B0MAP_mOFC_thr_binary_mask_DR.nii.gz" /import/monstrum/ONM/7T/subjects/$id/DR/B0MAP/$bblid"b0_mask_by_wb_mask.nii.gz"

echo "b0 masked"

#multiply wb_mask by b1 binary mask
fslmaths /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_DR/wb_mask/$bblid"_rh_wb_mask_binary.nii.gz" -mul /import/monstrum/ONM/7T/subjects/$id/DR/B1MAP/$id"_B1MAP_mOFC_thr_0.3_1.3_binary_mask_DR.nii.gz" /import/monstrum/ONM/7T/subjects/$id/DR/B1MAP/$bblid"_b1_mask_by_wb_mask.nii.gz"
echo "b1 masked"

#combine b1 corrected and b0 corrected masks 
fslmaths /import/monstrum/ONM/7T/subjects/$id/DR/B0MAP/$bblid"b0_mask_by_wb_mask.nii.gz" -mul /import/monstrum/ONM/7T/subjects/$id/DR/B1MAP/$bblid"_b1_mask_by_wb_mask.nii.gz" /import/monstrum/ONM/7T/subjects/$id/DR/$bblid"_rh_wb_mask_b0b1_corrected.nii.gz"

echo "corrected mask made"
#volume of b0b1_corrected mask
corrected_mask_vol=$(fslstats /import/monstrum/ONM/7T/subjects/$id/DR/$bblid"_rh_wb_mask_b0b1_corrected.nii.gz" -V)

#print values
echo $id $raw_mask_vol $corrected_mask_vol > /import/monstrum/ONM/7T/subjects/$id/DR/$bblid"_mask_vol.txt"

done
