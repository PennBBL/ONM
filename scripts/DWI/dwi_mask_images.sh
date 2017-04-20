#this script masks the dwi images using the iterative mask chosen from Mark Elliott's iterative masking script dwi_iterative_masking.sh

#for every subject in ONM...
for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do

#get scanid, mask number from the txt file mask_list.txt and the dwi directory
scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
mask_num=`cat /import/monstrum/ONM/scripts/DWI/mask_list.txt | grep $scanid | awk '{print $3}'`
mask=`echo "mask"$mask_num".nii.gz"`
dir=`ls -d $i/*dwi*ADC_[Am][Da][Cp]/nifti`

echo ..........$scanid $mask............

#go into the folder 

cd $dir


#get the original dwi nifti file

original=`ls $dir/*dwi_[Am][Da][Cp]*.nii.gz`
rescaled=`ls $dir/*ADC*rescaled*.nii.gz`

#get what the masked file should be called

masked=`ls 00"$scanid"_brain_0.3_masked.nii.gz`
masked2=`ls 00"$scanid"_brain_rescaled_masked.nii.gz`

#if the masked file doesn't already exist, then do fslmaths

if [ "X$masked" == "X" ]; then

fslmaths $original -mas $mask 00"$scanid"_brain_0.3_masked.nii.gz

echo ........."masking done".........

else

echo ........"masked file exists"......

fi

if [ "X$masked2" == "X" ]; then

fslmaths $rescaled -mas $mask 00"$scanid"_brain_rescaled_masked.nii.gz

echo ........."masking done".........

else

echo ........"masked file exists"......

fi


done

