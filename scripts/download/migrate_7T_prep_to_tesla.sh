#for every subject that has had 7T_prep run on them (the imscribe script),
for i in /import/monstrum/ONM/group_results/freesurfer/subjects/*_?????/7T_prep; do
echo $i

#find bblid and scanid
bblid=`echo $i | cut -d "/" -f 8 | cut -d "_" -f 1`
echo $bblid
scanid=`echo $i | cut -d "/" -f 8 | cut -d "_" -f 2`
echo $scanid

#copy necessary nifti files from the 7T_prep folder to the tesla folder

scp $i/* bbluser@tesla:/home/bbluser/data/Imscribe/Templates/ONM_new/3Tscans/$bblid"_"$scanid/

done
