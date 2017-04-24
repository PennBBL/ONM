#this script masks the dwi images using the iterative mask chosen from Mark Elliott's iterative masking script dwi_iterative_masking.sh. It is to be run after the dwi_iterative_masking.sh script as well as after you have chosen the appropriate mask and marked it down in the mask_list.txt

#for every subject in ONM...
for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do

#get scanid, mask number from the txt file mask_list.txt and the dwi directory
scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
mask_num=`cat /import/monstrum/ONM/scripts/DWI/mask_list.txt | grep $scanid | awk '{print $3}'`
mask=`echo "mask"$mask_num".nii.gz"`
dir=`ls -d $i/*dwi*ADC_[Am][Da][Cp]/nifti`

#print the scanid and chosen mask number (1-4) to the screen
echo ..........$scanid $mask............

#go into the DWI folder 
cd $dir


#get the original dwi nifti file as well as the rescaled file
original=`ls $dir/*dwi_[Am][Da][Cp]*.nii.gz`
rescaled=`ls $dir/*ADC*rescaled*.nii.gz`

#get what the masked file should be called (final output to this script)
masked=`ls 00"$scanid"_brain_0.3_masked.nii.gz`
masked2=`ls 00"$scanid"_brain_rescaled_masked.nii.gz`

#if the masked file doesn't already exist, then...
if [ "X$masked" == "X" ]; then

#mask the bet image by the mask you chose
fslmaths $original -mas $mask 00"$scanid"_brain_0.3_masked.nii.gz

#print to the screen when the masking is done
echo ........."masking done".........

#otherwise, if the mask output file already exists, then print to the screen that it already exists
else

echo ........"masked file exists"......

fi

#if the adc rescaled masked file doesn't exist, then...
if [ "X$masked2" == "X" ]; then

#mask that image by the mask you chose
fslmaths $rescaled -mas $mask 00"$scanid"_brain_rescaled_masked.nii.gz

#print to the screen when the masking is done
echo ........."masking done".........

#otherwise, if the rescaled mask output already exists, then print to the screen that it already exists
else

echo ........"masked file exists"......

fi


done

