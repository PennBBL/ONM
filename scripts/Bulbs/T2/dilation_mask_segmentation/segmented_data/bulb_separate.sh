#This script will take the olfactory bulb mask you drew by hand in FSL and separate it into left and right hemispheres based on the pen value you assigned each hemisphere (right is 1, left is 7), save each new mask in the subject's bulb_volume directory, and then extract the volume for each hemisphere and output each subject's volume data to a csv.

#create a variable called dir which gets the output directory for the aggregated volume output csv
dir=`ls -d /import/monstrum/ONM/group_results/Bulbs/T2`

#remove any existing bulb volume csv
rm -rf $dir/onm_bulb_volume.csv

#for every subject in the ONM subjects directory...
for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do

#create variables for bblid and scanid
scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
bblid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 1`

#print to the screen which subject is being processed
echo "......Processing" $bblid $scanid

#for each bulb_volume directory for each subject...(although there should only be one)
for j in `ls -d "$i"/*t2*BULB*/bulb_volume`; do

#move into the bulb volume directory
cd "$j"

#threshold the t2 bulb mask by the pen value, for left t2 bulb (it was drawn using value of 7) and for right t2 bulb (it was drawn using a value of 1), and save these separated bulb masks out into files in the bulb_volume directory
fslmaths *mask_MQ.nii.gz -thr 5 00"$scanid"_bulb_mask_left
fslmaths *mask_MQ.nii.gz -uthr 5 00"$scanid"_bulb_mask_right

#next, create variables which get bulb volume for left and right bulbs from the left and right masks created in the previous step
l_volume=`fslstats 00"$scanid"_bulb_mask_left.nii.gz -V | cut -d " " -f 2`
r_volume=`fslstats 00"$scanid"_bulb_mask_right.nii.gz -V | cut -d " " -f 2`

#print the left and right volume to the screen
echo "l",$l_volume
echo "r",$r_volume

#output the left and right bulb volume as well as subject identifiers to the onm_bulb_volume.csv for each subject
echo $bblid, $scanid, $l_volume, $r_volume >> $dir/onm_bulb_volume.csv

done
done


