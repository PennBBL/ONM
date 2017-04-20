path=`ls -d /import/monstrum/ONM/group_results/freesurfer/stats/aparc.stats`

for i in `ls -d /import/monstrum/ONM/group_results/freesurfer/subjects/*_*/stats`; do 

subid=`echo $i | cut -d "/" -f 8`
bblid=`echo $subid | cut -d "_" -f 1`
scanid=`echo $subid | cut -d "_" -f 2`

grep -q $scanid $path/rois_turetsky.csv && echo $subid "has already been processed" && continue

echo ".............Extracting stats for" $subid

icv=`grep 'EstimatedTotalIntraCranialVol' $i/aseg.stats | cut -d " " -f 9 | cut -d "," -f 1`

echo $subid $icv >> $path/icv.txt

lh_temporal_vol=`grep 'temporalpole' $i/lh.aparc.stats | cut -d " " -f 38`
lh_temporal_thick=`grep 'temporalpole' $i/lh.aparc.stats | cut -d " " -f 40`
rh_temporal_vol=`grep 'temporalpole' $i/rh.aparc.stats | cut -d " " -f 38`
rh_temporal_thick=`grep 'temporalpole' $i/rh.aparc.stats | cut -d " " -f 40`
lh_ent_vol=`grep 'entorhinal' $i/lh.aparc.stats | cut -d " " -f 40`
lh_ent_thick=`grep 'entorhinal' $i/lh.aparc.stats | cut -d " " -f 42`
rh_ent_vol=`grep 'entorhinal' $i/rh.aparc.stats | cut -d " " -f 40`
rh_ent_thick=`grep 'entorhinal' $i/rh.aparc.stats | cut -d " " -f 42`
lh_med_vol=`grep 'medialorbitofrontal' $i/lh.aparc.stats | cut -d " " -f 29`
lh_med_thick=`grep 'medialorbitofrontal' $i/lh.aparc.stats | cut -d " " -f 31`
rh_med_vol=`grep 'medialorbitofrontal' $i/rh.aparc.stats | cut -d " " -f 29`
rh_med_thick=`grep 'medialorbitofrontal' $i/rh.aparc.stats | cut -d " " -f 31`

echo "$bblid,$scanid,$icv,$lh_temporal_vol,$lh_temporal_thick,$rh_temporal_vol,$rh_temporal_thick,$lh_ent_vol,$lh_ent_thick,$rh_ent_vol,$rh_ent_thick,$lh_med_vol,$lh_med_thick,$rh_med_vol,$rh_med_thick" >> $path/rois_turetsky.csv

done
