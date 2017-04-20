#for i in /import/monstrum/ONM/7T/subjects/[0-9]*
for i in /import/monstrum/ONM/7T/subjects/120217_9029

id=`echo $i | cut -d "/" -f7`

do 

#mkdir $i/7T_ROIs/all_fs_ROIs/combined_rois_DR/occipital
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_rois_DR/parietal
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_rois_DR/frontal
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_bin_rois_DR/occipital
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_bin_rois_DR/parietal
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_bin_rois_DR/frontal
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_extracted_rois_DR/occipital
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_extracted_rois_DR/parietal
#mkdir $i/7T_ROIs/all_fs_ROIs/combined_extracted_rois_DR/frontal

### Combine Occipital Lobe ROIs ###

#Cuneus# 

echo log=`$id`
echo cuneus=`fslmaths`

for r in ls $i/7T_ROIS/all_fs_ROIs/registered_rois_DR/*nii* | grep 'G_cuneus_RPI\|cuneus_RPI'

do

echo cuneus=`echo $cuneus "$r -add"
echo log=`echo $log, $i` 
echo cuneus=`echo $cuneus | sed s @ "-add $" @ @ g`
echo cuneus=`echo $cuneus $i/7T_ROIs/all_fs_ROIS/combined_rois_DR/occipital/"$id"_cuneus_combined_roi_DR.nii
echo $cuneus 



done

