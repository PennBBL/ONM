#loop through and cd into each subject's dtifit dico motion regressor directory and get all subject's basename ("dti_eddy_with_CNI_rotated_bvecs") then run fsl to dtik 

for i in `ls -d /import/monstrum/ONM/subjects/*_*/*DTI*/bbl/dtifit/dico_corrected/motion_regressors`; do

cd $i

scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
basename="dti_eddy_with_CNI_rotated_bvecs"

echo $scanid

#/import/monstrum/ONM/scripts/DTI/fsl_to_dtik_edited $basename

cp $i/dti_eddy_with_CNI_rotated_bvecs_dtitk.nii.gz /import/monstrum/ONM/group_results/DTI/dtitk/$scanid"_dti_eddy_with_CNI_rotated_bvecs_dtitk.nii.gz"

done

