
#for every subject in the subject's folder... 
#to get a different scan change the folder name
for i in /import/monstrum/ONM/subjects/*_????/*dwi*ADC*ADC*/nifti/
do

#open their nifti file in FSL
fslview $i/*nii.gz &

done
