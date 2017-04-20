rm -rf /import/monstrum/ONM/group_results/DTI/TBSS/origdata
rm -rf /import/monstrum/ONM/group_results/DTI/TBSS/FA

for i in `ls -d /import/monstrum/ONM/subjects/*/*_DTI_*/bbl/dtifit/dico_corrected/motion_regressors`;

do 

subid=`echo $i | cut -d "/" -f 6`

cp $i/dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz $i/"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz

dx=`grep $subid /import/monstrum/ONM/scripts/DTI/tbss_dx_list.csv | cut -d "," -f 2`

if [ "X$dx" != "X" ]; then

echo "copying $subid to TBSS folder"

cp $i/"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz /import/monstrum/ONM/group_results/DTI/TBSS/"$dx"_"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz
fi

done

cd /import/monstrum/ONM/group_results/DTI/TBSS

tbss_1_preproc *.nii.gz

qsub -V -q all.q -S /bin/bash -o ~/onm_tbss_logs -e ~/onm_tbss_logs /import/monstrum/ONM/scripts/DTI/tbss_step2_run.sh


