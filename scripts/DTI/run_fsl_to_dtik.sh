#This script will loop through and cd into each subject's dtifit dico motion regressor directory and get all subject's basename ("dti_eddy_with_CNI_rotated_bvecs") then run fsl to dtik 

#for each ONM subject with a DTI distortion corrected motion regressed directory
for i in `ls -d /import/monstrum/ONM/subjects/*_*/*DTI*/bbl/dtifit/dico_corrected/motion_regressors`; do

#move into that directory
cd $i

#create variables with scanid and the name of the file (the basename)
scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
basename="dti_eddy_with_CNI_rotated_bvecs"

#print the scanid to the screen
echo $scanid

#run the fsl to dtik script on this data
/import/monstrum/ONM/scripts/DTI/fsl_to_dtik_edited $basename

#copy the eddy with CNI rotated bvecs dtitk file to the group results directory with scanid in front of it
cp $i/dti_eddy_with_CNI_rotated_bvecs_dtitk.nii.gz /import/monstrum/ONM/group_results/DTI/dtitk/$scanid"_dti_eddy_with_CNI_rotated_bvecs_dtitk.nii.gz"

done

