#Set Subjects directory to ONM:
SUBJECTS_DIR=/import/monstrum/ONM/group_results/freesurfer/subjects
#Check that Subjects directory was set:
source /import/monstrum/Applications/freesurfer/SetUpFreeSurfer.sh

for i in "$SUBJECTS_DIR"/*_*
do
subid=`basename $i`;

echo " Processing subject "$subid

#check if ROI folder is present or else make one
roisfolder=$(ls -d "$i"/ROIs)

if [ ! -d "$roisfolder" ]; then
	echo "ROIs folder does not exist..creating folder for this subject"
	mkdir "$i"/ROIs;
	mkdir "$i"/7T_prep;

#Annotation to Label for each ROI (for both aparc and aparc.a2009s)
mri_annotation2label --subject $subid --hemi lh --annotation aparc.a2009s --outdir "$i"/ROIs; 
mri_annotation2label --subject $subid --hemi rh --annotation aparc.a2009s --outdir "$i"/ROIs;
mri_annotation2label --subject $subid --hemi lh --annotation aparc --outdir "$i"/ROIs; 
mri_annotation2label --subject $subid --hemi rh --annotation aparc --outdir "$i"/ROIs;

#TkRegister--create registration file for rawavg
tkregister2 --mov "$i"/mri/rawavg.mgz --noedit --s $subid --regheader --reg "$i"/mri/raw_register.dat;

#TkRegister--create registration file for aparc --gray matter
tkregister2 --mov "$i"/mri/aparc.a2009s_aseg.mgz --noedit --s $subid --regheader --reg "$i"/mri/aparc2009_register.dat;

#TkRegister--create registration file for aparc --white matter
tkregister2 --mov "$i"/mri/wmparc.mgz --noedit --s $subid --regheader --reg "$i"/mri/wmparc_register.dat;

mri_label2vol --label "$i"/ROIs/rh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_raw_rh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
mri_label2vol --label "$i"/ROIs/rh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_aparc_rh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/aparc2009_register.dat; 
mri_label2vol --label "$i"/ROIs/rh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_wmparc_rh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/wmparc_register.dat; 

mri_convert "$i"/mri/rawavg.mgz "$i"/mri/"$subid"_rawavg.nii.gz;
mri_convert "$i"/mri/aparc.a2009s_aseg.mgz "$i"/mri/"$subid"_gmaparc.nii.gz
mri_convert "$i"/mri/wmparc.mgz "$i"/mri/"$subid"_wmparc.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/mri/"$subid"_rawavg.nii.gz "$i"/mri/"$subid"_rawavg_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_raw_rh_medialorbitofrontal.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_gmparc_rh_medialorbitofrontal.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_wmparc_rh_medialorbitofrontal.nii.gz
