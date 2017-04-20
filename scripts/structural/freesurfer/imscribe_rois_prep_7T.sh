
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

#TkRegister--create registration file
tkregister2 --mov "$i"/mri/rawavg.mgz --noedit --s $subid --regheader --reg "$i"/mri/register.dat;

#Surface label to Volume for each ROI to be used at 7T
mri_label2vol --label "$i"/ROIs/rh.entorhinal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;
mri_label2vol --label "$i"/ROIs/rh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
mri_label2vol --label "$i"/ROIs/rh.temporalpole.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_temporalpole.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
mri_label2vol --label "$i"/ROIs/lh.entorhinal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;
mri_label2vol --label "$i"/ROIs/lh.medialorbitofrontal.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_medialorbitofrontal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 
mri_label2vol --label "$i"/ROIs/lh.temporalpole.label --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_temporalpole.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat; 

echo "finished converting label to volume ...."

#Convert whole brain MGZ to NIFTI:
mri_convert "$i"/mri/rawavg.mgz "$i"/mri/"$subid"_rawavg.nii.gz;
#Convert aseg (subcortex) to NIFTI:
mri_convert -rl "$i"/mri/rawavg.mgz -rt nearest "$i"/mri/aseg.mgz "$i"/mri/"$subid"_aseg2raw.nii.gz;
#force RPI as mri_convert defaults to RAI
/import/speedy/scripts/melliott/force_RPI.sh "$i"/mri/"$subid"_rawavg.nii.gz "$i"/mri/"$subid"_rawavg_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/mri/"$subid"_aseg2raw.nii.gz "$i"/mri/"$subid"_aseg2raw_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_entorhinal.nii.gz "$i"/ROIs/"$subid"_rh_entorhinal_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_rh_medialorbitofrontal_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_rh_temporalpole.nii.gz "$i"/ROIs/"$subid"_rh_temporalpole_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_entorhinal.nii.gz "$i"/ROIs/"$subid"_lh_entorhinal_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_medialorbitofrontal.nii.gz "$i"/ROIs/"$subid"_lh_medialorbitofrontal_RPI.nii.gz
/import/speedy/scripts/melliott/force_RPI.sh "$i"/ROIs/"$subid"_lh_temporalpole.nii.gz "$i"/ROIs/"$subid"_lh_temporalpole_RPI.nii.gz
echo "finished converting whole brain mgz and aseg to RPI niftis ...."

#Create amygdala ROI
echo "creating Amygdala ROI ...."
fslmaths "$i"/mri/"$subid"_aseg2raw_RPI.nii.gz -uthr 54 -thr 54 "$i"/ROIs/"$subid"_right_amgydala_RPI.nii.gz;

#Create Entorhinal+Amygdala ROI
echo "Creating Entorhinal+Amygdala ROI ...."
fslmaths "$i"/ROIs/"$subid"_rh_entorhinal_RPI.nii.gz -add "$i"/ROIs/"$subid"_right_amgydala_RPI.nii.gz "$i"/ROIs/"$subid"_ento+amyg_RPI.nii.gz; 

#Make Ento+Amyg mask binary
fslmaths "$i"/ROIs/"$subid"_ento+amyg_RPI.nii.gz -bin "$i"/ROIs/"$subid"_rh_ento+amyg_RPI_mask.nii.gz;
fslmaths "$i"/ROIs/"$subid"_ento+amyg_RPI.nii.gz -bin "$i"/ROIs/"$subid"_lh_ento+amyg_RPI_mask.nii.gz;
echo "Finished processing subject " $subid"...." 

#Create Entorhinal+Temporal Pole ROI
echo "Creating Entorhinal+TemporalPole ROI ...."
fslmaths "$i"/ROIs/"$subid"_rh_entorhinal_RPI.nii.gz -add "$i"/ROIs/"$subid"_rh_temporalpole_RPI.nii.gz "$i"/ROIs/"$subid"_rh_ento+temporalpole_RPI.nii.gz; 
fslmaths "$i"/ROIs/"$subid"_lh_entorhinal_RPI.nii.gz -add "$i"/ROIs/"$subid"_lh_temporalpole_RPI.nii.gz "$i"/ROIs/"$subid"_lh_ento+temporalpole_RPI.nii.gz; 

#Make Ento+TemporalPole mask binary
fslmaths "$i"/ROIs/"$subid"_rh_ento+temporalpole_RPI.nii.gz -bin "$i"/ROIs/"$subid"_rh_ento+temporalpole_RPI_mask.nii.gz;
fslmaths "$i"/ROIs/"$subid"_lh_ento+temporalpole_RPI.nii.gz -bin "$i"/ROIs/"$subid"_lh_ento+temporalpole_RPI_mask.nii.gz;

#Make Medial Orbital Frontal mask binary
fslmaths "$i"/ROIs/"$subid"_rh_medialorbitofrontal_RPI.nii.gz -bin "$i"/ROIs/"$subid"_rh_medialorbitofrontal_RPI_mask.nii.gz;
fslmaths "$i"/ROIs/"$subid"_lh_medialorbitofrontal_RPI.nii.gz -bin "$i"/ROIs/"$subid"_lh_medialorbitofrontal_RPI_mask.nii.gz;
echo "Finished processing subject " $subid"...." 

#Move data to 7T_prep folder
mv "$i"/ROIs/*.nii.gz "$i"/7T_prep/
mv "$i"/mri/*.nii.gz "$i"/7T_prep/

echo "Finished processing subject " $subid"...." 

fi

#do the same for all freesurfer ROIs
roisfolder=$(ls -d "$i"/7T_prep/all_fs_rois)

if [ ! -d "$roisfolder" ]; then
	echo "all fs rois folder does not exist..creating folder for this subject"
	mkdir "$i"/7T_prep/all_fs_rois;
fi

for j in `ls -d $i/ROIs/*`;
do

mri_label2vol --label $j --temp "$i"/mri/rawavg.mgz --subject $subid --hemi rh --o "$i"/ROIs/"$subid"_rh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;
mri_label2vol --label $j --temp "$i"/mri/rawavg.mgz --subject $subid --hemi lh --o "$i"/ROIs/"$subid"_lh_entorhinal.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg "$i"/mri/register.dat;

done
done
