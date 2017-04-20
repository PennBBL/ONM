for i in `ls -d /import/monstrum/ONM/subjects/*/*_DTI_*/bedpostx.bedpostX`; do

subjid=`echo $i | cut -d "/" -f 6`
dti_dir=`echo $i | cut -d "/" -f 1-7`

#create probtrax folder
mkdir $dti_dir/probtrax

#move seed masks into seed mask folder
cp /import/monstrum/ONM/group_results/freesurfer/subjects/$subjid/ROI_volumes/$subjid*_RPI.nii.gz $i/seed_masks/

for j in `ls -d $i/seed_masks/*.nii.gz`; do

seed=`echo $j | cut -d "/" -f 10 | cut -d "." -f 1 | cut -d "_" -f 2- | rev | cut -d "_" -f2- | rev`

#create probtrax folder for that seed
mkdir $dti_dir/probtrax/$seed

/import/monstrum/Applications/fsl5/bin/probtrackx2 -x $j -l --onewaycondition -c 0.2 -S 2000 -P 5000 --steplength=0.5 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $i/merged -m $i/nodif_brain_mask --dir=$dti_dir/probtrax/$seed 

done

done
