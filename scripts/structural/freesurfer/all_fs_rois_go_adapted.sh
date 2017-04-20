
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
fi

#Annotation to Label for each ROI (for both aparc and aparc.a2009s)
mri_annotation2label --subject $subid --hemi lh --annotation aparc.a2009s --outdir "$i"/ROIs; 
mri_annotation2label --subject $subid --hemi rh --annotation aparc.a2009s --outdir "$i"/ROIs;
mri_annotation2label --subject $subid --hemi lh --annotation aparc --outdir "$i"/ROIs; 
mri_annotation2label --subject $subid --hemi rh --annotation aparc --outdir "$i"/ROIs;

#TkRegister--create registration file
tkregister2 --mov "$i"/mri/rawavg.mgz --noedit --s $subid --regheader --reg "$i"/mri/register.dat;

#Surface label to Volume for each ROI to be used at 7T 

for j in `ls -d "$i"/ROIs/*`; do

hemi=`cut -d "/" -f 10 | cut -d "." -f 1`;
name=`cut -d "/" -f 10 | cut -d "." -f 2`;

mri_label2vol --label $j --temp "$i"/mri/rawavg.mgz --subject $subid --hemi $hemi --o "$i"/7T_prep/all_fs_rois/"$subid"_"$hemi"_"$name".nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;


#mri_label2vol --label "$i"/ROIs/rh.entorhinal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;
#mri_label2vol --label "$i"/ROIs/rh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
#mri_label2vol --label "$i"/ROIs/rh.temporalpole.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_temporalpole.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
#mri_label2vol --label "$i"/ROIs/lh.entorhinal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;
#mri_label2vol --label "$i"/ROIs/lh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
#mri_label2vol --label "$i"/ROIs/lh.temporalpole.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_temporalpole.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 

/import/speedy/scripts/melliott/force_RPI.sh "$i"/7T_prep/all_fs_rois/"$subid"_"$hemi"_"$name".nii.gz "$i"/7T_prep/all_fs_rois/"$subid"_"$hemi"_"$name"_RPI.nii.gz;

done

echo "finished converting label to volume ...."

#Convert whole brain MGZ to NIFTI:
mri_convert "$i"/mri/rawavg.mgz "$i"/mri/"$subid"_rawavg.nii.gz;
#Convert aseg (subcortex) to NIFTI:
mri_convert -rl "$i"/mri/rawavg.mgz -rt nearest "$i"/mri/aseg.mgz "$i"/mri/"$subid"_aseg2raw.nii.gz;

#force RPI as mri_convert defaults to RAI 
/import/speedy/scripts/melliott/force_RPI.sh "$i"/mri/"$subid"_rawavg.nii.gz "$i"/mri/"$subid"_rawavg_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/mri/"$subid"_aseg2raw.nii.gz "$i"/mri/"$subid"_aseg2raw_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_entorhinal.nii.gz "$i"/ROIs/"$subid"_rh_entorhinal_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_rh_medialorbitofrontal_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_temporalpole.nii.gz "$i"/ROIs/"$subid"_rh_temporalpole_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_entorhinal.nii.gz "$i"/ROIs/"$subid"_lh_entorhinal_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_lh_medialorbitofrontal_RPI.nii.gz
#/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_temporalpole.nii.gz "$i"/ROIs/"$subid"_lh_temporalpole_RPI.nii.gz
echo "finished converting whole brain mgz and aseg to RPI niftis ...."

done
