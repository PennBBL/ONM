path=`ls -d /import/monstrum/ONM/subjects`
day=`date +%m_%d_%y`

#for every subject in the subjects folder...
for i in `ls -d "$path"/*_*`; do

#get scanid
subject=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`

echo $subject

#for every subject in every dwi map folder....
#Note: some of these folders are called dwi_ADC_map, some are called ADC_ADC. 
for j in `ls -d "$i"/*ADC_[Am][Da][Cp]/nifti`; do
test_map=`ls $j/*ADC_[Am][Da][Cp]*.nii.gz`
echo $j
echo $test_map
test_out=`ls $j/mask4.nii.gz`

#check if there is already a mask4 file, if there is don't do anything. If there isn't, then bet .3 threshold and create a rescaled file 
if [ "X$test_map" != "X" ] && [ "X$test_out" == "X" ];then
bet $test_map "$j"/00"$subject"_brain_0.3 -f 0.3 -g 0 -m
fslmaths $test_map -div 1000000 "$j"/00"$subject"_ADC_rescaled.nii.gz

input_mask=`ls $j/"00"$subject"_brain_0.3.nii.gz"`  

echo $input_mask

cd $j

#the following scripts are from Mark Elliott to create iterative masks (four of them) for the DWI data, each mask adds a bit more data back to the .3 bet file
# make a nifti image that is 3x3x3 with same voxel size as target mask image
fslcreatehd 3 3 3 1   1.875 1.875 2.0 6.5   0 0 0 4 empty_kernel

# set kernel(1,1,2) = 1 AND kernel(1,1,1) = 1 (where indexing goes 0..n-1)
rm -f Zkernel.*
3dcalc -a empty_kernel.nii.gz -expr 'equals(i,1)*equals(j,1)*equals(k,2) + equals(i,1)*equals(j,1)*equals(k,1)' -prefix Zkernel.nii

# Dilate the mask several times using our kernel
rm -f mask1* mask2* mask3* mask4* 
fslmaths $input_mask -kernel file Zkernel -dilF mask1
fslmaths mask1 -kernel file Zkernel -dilF mask2
fslmaths mask2 -kernel file Zkernel -dilF mask3
fslmaths mask3 -kernel file Zkernel -dilF mask4

#if there is no map file (dwi map) then say no map file and put this in a file called map_error_log.txt
elif [ "X$test_map" == "X" ];then
echo "$subject - no map file exists"
echo "$subject - no map file exists","$day" >> /import/monstrum/ONM/scripts/DWI/map_error_log.txt

#if there is already a mask4 file then don't do anything
elif [ "X$test_out" != "X" ];then 
echo "$subject - already run"
fi # if [ "X$test_map" != "X" ] && [ "X$test_out" == "X" ];then

done

done
