cat /import/monstrum/ONM/group_results/freesurfer/subjects/3t.txt | while read id

do

echo $id

bblid=`echo $id | cut -d "_" -f1`

echo $bblid

mri_convert -rl /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/rawavg.mgz -nc -rt nearest /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/wmparc.mgz /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc.nii.gz"
echo "wmparc conversion complete"

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc.nii.gz" /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc_RPI.nii.gz"
echo "wmparc RPI conversion complete"

mri_convert -rl /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/rawavg.mgz -nc -rt nearest /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/aparc+aseg.mgz /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_aparc+aseg.nii.gz"

echo "aparc+seg conversion complete"

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_aparc+aseg.nii.gz" /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_aparc+aseg_RPI.nii.gz"
echo "aparc+aeg RPI conversion complete"

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc_RPI.nii.gz" -sub /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_aparc+aseg_RPI.nii.gz" /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wm_only_RPI.nii.gz"

echo "wm mask complete"

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wm_only_RPI.nii.gz" -bin /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wm_only_binary_mask_RPI.nii.gz"

echo "wm binary mask complete"

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wm_only_binary_mask_RPI.nii.gz" -mul /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc_RPI.nii.gz" /import/monstrum/ONM/group_results/freesurfer/subjects/$id/mri/$bblid"_wmparc_wm_only_RPI.nii.gz"

echo "wmparc wm only complete"

done
