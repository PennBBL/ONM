# script to extract sulcal depth measures for right and left orbital and olfactory sulci for ONM subjects, based on David Roalf's script to do so for GO1 subjects


# set the env variable for subjects dir used by freesurfer
export SUBJECTS_DIR="/import/monstrum/ONM/group_results/freesurfer/subjects"

cd "$SUBJECTS_DIR"
for i in *_*
do
surfdir=`ls -d "$i"/stats`
scanid=`echo $i | cut -d "_" -f 2`

#if the subject's scanid already exists in the file, do not re-run them and print "$scanid has already been processed". If their scanid does not exist in the file, then extract data for each file/roi

for file in `ls /import/monstrum/ONM/group_results/freesurfer/stats/aparc.stats/*.aparc.stats*.csv` ; 
do
hemi=`echo $file | cut -d "/" -f 9 | cut -d "." -f 1`
#hemisphere=`echo $file | cut -d "/" -f 9 | cut -d "." -f 1`
#if [ $hemisphere == "left" ] ; then
#hemi=lh
#elif [ $hemisphere == "right" ] ; then
#hemi=rh
#else 
#echo "ERROR hemisphere not detected"
#fi
roi=`echo $file | cut -d "/" -f 9 | cut -d "_" -f 2`

if ! grep -q $scanid $file; then

value=`cat "$SUBJECTS_DIR"/"$surfdir"/"$hemi".aparc.stats |grep "$roi"`

echo $i $value >> $file

echo ".........." $i $file "...done"

else 
echo $scanid $file "has already been processed"

fi
done
done
