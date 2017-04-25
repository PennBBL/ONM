#this script will run the first step of TBSS

#remove any prior directories for origdata and FA
rm -rf /import/monstrum/ONM/group_results/DTI/TBSS/origdata
rm -rf /import/monstrum/ONM/group_results/DTI/TBSS/FA

#for each ONM subject with final distortion corrected motion regressed DTI directories
for i in `ls -d /import/monstrum/ONM/subjects/*/*_DTI_*/bbl/dtifit/dico_corrected/motion_regressors`;

do 

#create a variable for the subjectid
subid=`echo $i | cut -d "/" -f 6`

#copy their eddy with CNI rotated bvecs FA data to have their subject id on the front of it
cp $i/dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz $i/"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz

#check in the tbss_dx_list for their diagnosis and create a variable
dx=`grep $subid /import/monstrum/ONM/scripts/DTI/tbss_dx_list.csv | cut -d "," -f 2`

#if diagnosis exists then
if [ "X$dx" != "X" ]; then

#print to the screen the subject that's being processed
echo "copying $subid to TBSS folder"

#copy their subject identified dti eddy with CNI rotated bvecs FA file into the ONM group results DTI TBSS directory with diagnosis in front of the name before subjectid
cp $i/"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz /import/monstrum/ONM/group_results/DTI/TBSS/"$dx"_"$subid"_dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz
fi

done

#move into the group results directory for DTI TBSS
cd /import/monstrum/ONM/group_results/DTI/TBSS

#run the first step of tbss
tbss_1_preproc *.nii.gz

#after that is done, submit to the grid the second step of tbss using tbss_step2_run.sh
qsub -V -q all.q -S /bin/bash -o ~/onm_tbss_logs -e ~/onm_tbss_logs /import/monstrum/ONM/scripts/DTI/tbss_step2_run.sh


