# script to extract sulcal depth measures for right and left orbital and olfactory sulci for ONM subjects, based off of Kosha's script to do so for GO subjects

# set the env variable for subjects dir used by freesurfer
export SUBJECTS_DIR="/import/monstrum/ONM/subjects"

#move into the subjects directory for ONM
cd "$SUBJECTS_DIR"

#for each ONM subject
for i in *_*
do

#create variable for freesurfer directory for that subject
surfdir=`ls -d "$i"/*MPRAGE*moco3/freesurfer`

#if the subject's data isn't in the output text file then
if ! grep -q $i /import/monstrum/ONM/group_results/freesurfer/olf_orb_avg_cort_thick.txt
then

#get the thickness for the left and right olfactory and orbital sulci, and create variales with that information
lorbth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/lh.S_orbital-H_Shaped.label $surfdir lh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
rorbth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/rh.S_orbital-H_Shaped.label $surfdir rh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
lolfth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/lh.S_orbital_med-olfact.label $surfdir lh|grep thickness|sed 's/ //g'|cut -d"=" -f2`
rolfth=`mris_anatomical_stats -l "$SUBJECTS_DIR"/"$surfdir"/rois_turetsky/rh.S_orbital_med-olfact.label $surfdir rh|grep thickness|sed 's/ //g'|cut -d"=" -f2`

#print that data for each subject to the output file
echo $i $lorbth $rorbth $lolfth $rolfth >> /import/monstrum/ONM/group_results/freesurfer/olf_orb_avg_cort_thick.txt

#print to the screen when that subject is done
echo ".........." $i "...done"

#if their data was already found in the output file then don't process and print that they were already run to the screen
else
echo $i "already run"
fi
done
