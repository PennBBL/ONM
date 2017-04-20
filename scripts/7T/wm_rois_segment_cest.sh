for id in `cat /import/monstrum/ONM/7T/tmp_3_3/sub_3t_7t_list.csv`;

do

echo $id


bblid=`echo $id | cut -d "_" -f1`

echo $bblid

scanid_3T=`echo $id | cut -d "_" -f2`

echo $scanid_3T

scanid_7T=`echo $id | cut -d "_" -f3`

echo $scanid_7T

id_3T=$bblid"_"$scanid_3T
id_7T=$bblid"_"$scanid_7T


#CEST images

mOFC_nifti_new=/import/monstrum/ONM/7T/subjects/$id_7T/PR/"$id_7T"_mOFC_cest_PR.nii.gz

mkdir /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/

#Extract white matter ROIs from the white matter mask 

#Unknown

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4000 -thr 4000 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_unknown.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_unknown.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_unknown_RPI.nii.gz

#Bankssts

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4001 -thr 4001 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_bankssts.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_bankssts.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_bankssts_RPI.nii.gz

#Caudalanteriorcingulate

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4002 -thr 4002 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalanteriorcingulate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalanteriorcingulate.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalanteriorcingulate_RPI.nii.gz

#Caudalmiddlefrontal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4003 -thr 4003 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalmiddlefrontal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalmiddlefrontal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_caudalmiddlefrontal_RPI.nii.gz

#Corpuscallosum

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4004 -thr 4004 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_corpuscallosum.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_corpuscallosum.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_corpuscallosum_RPI.nii.gz

#Cuneus

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4005 -thr 4005 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_cuneus.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_cuneus.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_cuneus_RPI.nii.gz

#entorhinal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4006 -thr 4006 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_entorhinal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_entorhinal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_entorhinal_RPI.nii.gz

#Fusiform

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4007 -thr 4007 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_fusiform.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_fusiform.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_fusiform_RPI.nii.gz

#Inferiorparietal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4008 -thr 4008 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiorparietal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiorparietal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiorparietal_RPI.nii.gz

#Inferiortemporal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4009 -thr 4009 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiortemporal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiortemporal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_inferiortemporal_RPI.nii.gz

#Isthmuscingulate

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4010 -thr 4010 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_isthmuscingulate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_isthmuscingulate.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_isthmuscingulate_RPI.nii.gz

#Lateraloccipital

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4011 -thr 4011 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateraloccipital.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateraloccipital.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateraloccipital_RPI.nii.gz

#Lateralorbitofrontal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4012 -thr 4012 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateralorbitofrontal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateralorbitofrontal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lateralorbitofrontal_RPI.nii.gz


#Lingual

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4013 -thr 4013 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lingual.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lingual.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_lingual_RPI.nii.gz

#Medialorbitofrontal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4014 -thr 4014 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_medialorbitofrontal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_medialorbitofrontal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_medialorbitofrontal_RPI.nii.gz


#middletemporal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4015 -thr 4015 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_middletemporal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_middletemporal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_middletemporal_RPI.nii.gz

#parahippocampal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4016 -thr 4016 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parahippocampal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parahippocampal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parahippocampal_RPI.nii.gz

#paracentral

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4017 -thr 4017 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_paracentral.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_paracentral.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_paracentral_RPI.nii.gz

#parsopercularis

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4018 -thr 4018 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsopercularis.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsopercularis.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsopercularis_RPI.nii.gz

#parsorbitalis

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4019 -thr 4019 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsorbitalis.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsorbitalis.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parsorbitalis_RPI.nii.gz

#parstraingularis

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4020 -thr 4020 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parstriangularis.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parstriangularis.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_parstriangularis_RPI.nii.gz

#pericalcarine

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4021 -thr 4021 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_pericalcarine.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_pericalcarine.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_pericalcarine_RPI.nii.gz

#postcentral

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4022 -thr 4022 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_postcentral.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_postcentral.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_postcentral_RPI.nii.gz

#posteriorcingulate

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4023 -thr 4023 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_posteriorcingulate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_posteriorcingulate.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_posteriorcingulate_RPI.nii.gz

#precentral

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4024 -thr 4024 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precentral.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precentral.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precentral_RPI.nii.gz

#precuneus

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4025 -thr 4025 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precuneus.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precuneus.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_precuneus_RPI.nii.gz

#rostralanteriorcingulate

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4026 -thr 4026 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralanteriorcingulate.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralanteriorcingulate.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralanteriorcingulate_RPI.nii.gz

#rostralmiddlefrontal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4027 -thr 4027 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralmiddlefrontal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralmiddlefrontal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_rostralmiddlefrontal_RPI.nii.gz

#superiorfrontal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4028 -thr 4028 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorfrontal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorfrontal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorfrontal_RPI.nii.gz

#superiorparietal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4029 -thr 4029 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorparietal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorparietal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiorparietal_RPI.nii.gz

#superiortemporal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4030 -thr 4030 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiortemporal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiortemporal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_superiortemporal_RPI.nii.gz


#supramarginal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4031 -thr 4031 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_supramarginal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_supramarginal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_supramarginal_RPI.nii.gz

#frontalpole

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4032 -thr 4032 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_frontalpole.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_frontalpole.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_frontalpole_RPI.nii.gz

#temporalpole

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4033 -thr 4033 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_temporalpole.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_temporalpole.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_temporalpole_RPI.nii.gz

#transversetemporal

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4034 -thr 4034 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_transversetemporal.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_transversetemporal.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_transversetemporal_RPI.nii.gz

#insula

fslmaths /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/$bblid"_wmparc_wm_only_RPI.nii.gz" -uthr 4035 -thr 4035 /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_insula.nii.gz

/import/speedy/scripts/melliott/force_RPI.sh /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_insula.nii.gz /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/"$bblid"_wm_rh_insula_RPI.nii.gz

#Copy RPI images over to the subjects 7T_ROIs folder

mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_rois/
mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_registered/
mkdir /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/

scp /import/monstrum/ONM/group_results/freesurfer/subjects/$id_3T/mri/wm_rois/*RPI.nii.gz /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_rois/



for j in /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_rois/*_RPI.nii.gz
	do

	echo $j 

	name=`echo $j | cut -d "." -f1`
	name_use=`echo $name | cut -d "/" -f11`

	antsApplyTransforms -d 3 -n MultiLabel -i $j -o /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_registered/"$name_use"_2_7T.nii.gz -r /import/monstrum/ONM/7T/subjects/$id_7T/*MPRAGE*/*.nii* -t /import/monstrum/ONM/7T/tmp_3_3/reg/"$bblid"_3T_2_7T0GenericAffine.mat

	echo "Start extracting $name_use slice"  
	
	echo $name
	echo $name_use

	extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_registered/"$name_use"_2_7T.nii.gz $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$name_use"_mOFC_cest_ROI.nii.gz

#creates ROI from registered ROI onto the CEST map image mOFC nifti
	

	echo "Done extracting $name_use slice" 
		
	roi_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$name_use"_mOFC_cest_ROI.nii.gz -M -S -V)
	
	echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id_7T/7T_ROIs/all_fs_ROIs/wm_extract/"$bblid"_mOFC_wm_glucest_data.txt

	echo "Done $name_use slice" 

	done

done







