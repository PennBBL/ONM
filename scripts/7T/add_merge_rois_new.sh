#for i in /import/monstrum/ONM/7T/subjects/[0-9]* 
for i in /import/monstrum/ONM/7T/subjects/120217_9029
do 

id=`echo $i | cut -d '/' -f7`

echo $id 

#echo log=`$id`
#echo cuneus=`fslmaths`

	for r in ls $i/7T_ROIs/all_fs_ROIs/registered_rois_DR/*nii*

	do
	grep "*G_cuneus_RPI*\|*cuneus_RPI*"
	
	echo cuneus=`echo $cuneus "$r -add"`
	echo log=`echo $log $r`
	echo cuneus=`echo $cuneus | sed s @ "-add $" @ @ g`
	echo cuneus=`echo $cuneus $i/7T_ROIs/all_fs_ROIs/combined_rois_DR/occpital/"$id"_cuneus_combined_DR.nii.gz
	echo $cuneus

	done


done
