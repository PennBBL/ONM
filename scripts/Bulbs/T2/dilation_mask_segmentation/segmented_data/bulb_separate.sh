#right is 1
#left is 7

dir=`ls -d /import/monstrum/ONM/group_results/Bulbs/T2`

rm -rf $dir/onm_bulb_volume.csv

#for every subject, get scanid and bblid and...
for i in `ls -d /import/monstrum/ONM/subjects/*_*`; do

scanid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 2`
bblid=`echo $i | cut -d "/" -f 6 | cut -d "_" -f 1`


echo "......Processing" $bblid $scanid

for j in `ls -d "$i"/*t2*BULB*/bulb_volume`; do

cd "$j"

#threshold a t2 bulb mask for left t2 bulb (it was drawn using value of 7) and for right t2 bulb (it was drawn using a value of 1), output them into a file called scanid_bulb_mask_left/right
fslmaths *mask_MQ.nii.gz -thr 5 00"$scanid"_bulb_mask_left
fslmaths *mask_MQ.nii.gz -uthr 5 00"$scanid"_bulb_mask_right

#next, take that thresholded left/right mask and get the volume for the left/right bulb, output this into a file previously created called onm_bulb_volume_date.csv
l_volume=`fslstats 00"$scanid"_bulb_mask_left.nii.gz -V | cut -d " " -f 2`
r_volume=`fslstats 00"$scanid"_bulb_mask_right.nii.gz -V | cut -d " " -f 2`

echo "l",$l_volume
echo "r",$r_volume

echo $bblid, $scanid, $l_volume, $r_volume >> $dir/onm_bulb_volume.csv

done
done


