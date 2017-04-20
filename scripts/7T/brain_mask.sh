for i in /import/monstrum/ONM/7T/data_analysis/[0-9]*

do

echo $i

	fslmaths $i/DR/sagittal_structural_slice_DR.nii -mul $i/DR/sagittal_structural_slice_DR-brain_mask.nii.gz $i/DR/sagittal_structural_slice_mask_output_DR.nii
	fslmaths $i/PR/sagittal_structural_slice_PR.nii -mul $i/DR/sagittal_structural_slice_DR-brain_mask.nii.gz $i/PR/sagittal_structural_slice_mask_output_PR.nii

echo "Brain mask for $i created" 


done

