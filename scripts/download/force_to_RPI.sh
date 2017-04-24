#this script will take each subject's t2 bulb scan and force the orientation to RPI

#for each subject's bulb scanid
for i in /import/monstrum/ONM/subjects/*_*/*t2*BULB*/nifti
do

#move into their bulb nifti directory
cd $i

#for each nifti in this directory
for j in `ls $i/*.nii.gz`
do

#get filename so can name RPI file accordingly
filename=`echo $j | cut -d "/" -f 9 | cut -d "." -f 1`
filename=`echo $filename"_""RPI"`

#if there is already an RPI file, then don't create another one
if [ -s $i/$filename.nii ];then
echo $i "RPI file exists"
continue
fi

echo $filename #echo the filename so can make sure getting right file

#run script to force to RPI first must move to dicoms folder
cd ..
cd ./dicoms 
/import/speedy/scripts/melliott/dicom2nifti.sh -F $filename *.dcm

#move file from dicoms folder to nifti folder
mv ./*RPI* ..
cd ..
mv ./*RPI* ./nifti

#pull open the new file so can make sure have the right orientation 
cd ./nifti
fslview *RPI*.nii &

done

done
