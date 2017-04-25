#script to extract sulcal depth measures for right and left orbital and olfactory sulci for ONM subjects, based off of David Roalf's to do so for GO subjects

# set the env variable for subjects dir used by freesurfer
export SUBJECTS_DIR="/import/monstrum/ONM/subjects"

#move into the subjects directory for onm
cd "$SUBJECTS_DIR"

#for each onm subject
for i in *_*
do

#create variables with that subject's mprage freesurfer directory, and their rois_turetsky directory
surfdir=`ls -d "$i"/*_MPRAGE*moco3/freesurfer`
roidir=`ls -d "$surfdir"/rois_turetsky`

#if the roisturetsky directory doesn't exist then 
if [ "X$roidir" == "X" ] ; then 

#make that rois_turetsky directory
mkdir "$surfdir"/rois_turetsky


#creates label files from a specified annotation file and outputs them to the rois_turetsky directory
mri_annotation2label --subject "$surfdir" --hemi rh --annotation aparc.a2009s --outdir "$surfdir"/rois_turetsky
mri_annotation2label --subject "$surfdir" --hemi lh --annotation aparc.a2009s --outdir "$surfdir"/rois_turetsky

# extract output summary stats from curvature or label files
mris_curvature_stats -m -l "$surfdir"/rois_turetsky/rh.S_orbital_med-olfact.label -o "$surfdir"/rois_turetsky/"$i".rh.olfactory_sulcus "$surfdir" rh sulc
mris_curvature_stats -m -l "$surfdir"/rois_turetsky/lh.S_orbital_med-olfact.label -o "$surfdir"/rois_turetsky/"$i".lh.olfactory_sulcus "$surfdir" lh sulc
mris_curvature_stats -m -l "$surfdir"/rois_turetsky/rh.S_orbital-H_Shaped.label -o "$surfdir"/rois_turetsky/"$i".rh.orbital_sulcus "$surfdir" rh sulc
mris_curvature_stats -m -l "$surfdir"/rois_turetsky/lh.S_orbital-H_Shaped.label -o "$surfdir"/rois_turetsky/"$i".lh.orbital_sulcus "$surfdir" lh sulc


# parse the file
function parseoutfile()
{
filename=$1
#Raw Total Surface Area
tot_surf_area=`cat $filename|grep Total|grep Area|head -1|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
#ROI Surface Area
roi_surf_area=`cat $filename|grep ROI|grep Area|head -1|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
#Raw min
roi_min=`cat $filename|grep Min|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
#raw max
roi_max=`cat $filename|grep Max|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
# Raw mean positive integral
roi_mean_pos_int=`cat $filename|grep Mean|grep Positive|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
# Raw mean negative integral
roi_mean_neg_int=`cat $filename|grep Mean|grep Negative|cut -d ':' -f2| sed 's/^ *//g'|cut -d ' ' -f1`
#print to the screen all the extracted variables
echo $tot_surf_area $roi_surf_area $roi_min $roi_max $roi_mean_pos_int $roi_mean_neg_int

}

#create variables for the left and right olfactory and orbital frontal sulci
lh_olf_sulc=$(parseoutfile "$surfdir"/rois_turetsky/"$i".lh.olfactory_sulcus)
rh_olf_sulc=$(parseoutfile "$surfdir"/rois_turetsky/"$i".rh.olfactory_sulcus)
lh_orb_sulc=$(parseoutfile "$surfdir"/rois_turetsky/"$i".lh.orbital_sulcus)
rh_orb_sulc=$(parseoutfile "$surfdir"/rois_turetsky/"$i".rh.orbital_sulcus)

#output this data into the output files
echo "$i" "$lh_olf_sulc" >> /import/monstrum/ONM/group_results/freesurfer/stats/lh_olf_sulc_onm.txt
echo "$i" "$rh_olf_sulc" >> /import/monstrum/ONM/group_results/freesurfer/stats/rh_olf_sulc_onm.txt
echo "$i" "$lh_orb_sulc" >> /import/monstrum/ONM/group_results/freesurfer/stats/lh_orb_sulc_onm.txt
echo "$i" "$rh_orb_sulc" >> /import/monstrum/ONM/group_results/freesurfer/stats/rh_orb_sulc_onm.txt
echo ".........."

elif [ ! "X$roidir" == "X" ] ; then
echo $i "rois turetsky folder exists, subject already run"

else
echo "ERROR"

fi

done

