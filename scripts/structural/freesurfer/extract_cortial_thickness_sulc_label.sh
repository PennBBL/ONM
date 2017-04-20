# script to extract sulcal depth measures for right and left orbital and olfactory sulci for ONM subjects, based off of Kosha's script to do so for GO subjects

# set the env variable for subjects dir used by freesurfer
export SUBJECTS_DIR="/import/monstrum/ONM/subjects"

# create output directory
cd "$SUBJECTS_DIR"
for i in *_*
do
surfdir=`ls -d "$i"/*MPRAGE*moco3/freesurfer`

if ! grep -q $i /import/monstrum/ONM/group_results/freesurfer/olf_orb_avg_cort_thick.txt
then

lorbth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/lh.S_orbital-H_Shaped.label $surfdir lh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
rorbth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/rh.S_orbital-H_Shaped.label $surfdir rh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
lolfth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/lh.S_orbital_med-olfact.label $surfdir lh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
rolfth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/rh.S_orbital_med-olfact.label $surfdir rh|grep thickness|sed 's/ //g'|cut -d"=" -f2`

echo $i $lorbth $rorbth $lolfth $rolfth >> /import/monstrum/ONM/group_results/freesurfer/olf_orb_avg_cort_thick.txt

echo ".........." $i "...done"

else
echo $i "already run"
fi
done
