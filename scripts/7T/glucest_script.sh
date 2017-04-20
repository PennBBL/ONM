cat subs_redo.txt | while read id

do

echo $id

bblid=`echo $id | cut -d "_" -f1`

echo $bblid


##Create directories for output files##

mkdir /import/monstrum/ONM/7T/subjects/$id/PR
mkdir /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest
mkdir /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest
mkdir /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest
mkdir /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP
mkdir /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP

dicoms=`ls -v /import/monstrum/ONM/7T/subjects/$id/*None*/PR/S0994*/*dcm 2> /dev/null` #create list of all folders that contain dicoms
number=`echo $dicoms | wc -w`
#[ $number != 2 ] && echo "wrong number of dicoms-$number" && continue #how many dicoms are in a subjects folder

EP_dicoms=`echo $dicoms | cut -d " " -f1` #list of EP dicoms
mOFC_dicoms=`echo $dicoms | cut -d " " -f2` #list of mOFC dicoms

EP_use=`echo $EP_dicoms | cut -d "/" -f1-10` #creates list of the EP folders to use for dicom2nifti
mOFC_use=`echo $mOFC_dicoms | cut -d "/" -f1-10` #creates list of the mOFC folders to use for dicom2nifti

echo $EP_use
echo $mOFC_use


##DICOMS2NIFTI FOR ENTORHINAL AND MOFC## 

dicom2nifti.sh -uF -r Y /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii $EP_use/*.dcm #output cest nifti for EP from S0994 
dicom2nifti.sh -u -r Y /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_mOFC_cest_PR.nii $mOFC_use/*.dcm #output cest nifti for mOFC from S0994


EP_nifti_new=/import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii
mOFC_nifti_new=/import/monstrum/ONM/7T/subjects/$id/PR/"$id"_mOFC_cest_PR.nii

echo $EP_nifti_new
echo $mOFC_nifti_new

###Extract Slices-entorhinal,temporalpole,mOFC using EP and mOFC cest niftis and sagittal,axial structural slices###
 
echo "Starting extract entorhinal slice" 

extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/onm_glucest_rois/*rh_entorhinal* $EP_nifti_new /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/entorhinal_cest_ROI_PR.nii.gz #creates entorhinal ROI

echo "Starting extract temporal slice" 

extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/onm_glucest_rois/*rh_temporal* $EP_nifti_new /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/temporal_pole_cest_ROI_PR.nii.gz #creates temporal pole ROI

echo "Starting extract temporal slice"

extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/onm_glucest_rois/*rh_medorbifrontal* $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/mOFC_cest_ROI_PR.nii #creates mOFC ROI

echo "Starting extract axial structural slice"


##extracting the CEST equivalent slice from the structrual scan 
extract_slice.sh /import/monstrum/ONM/7T/subjects/$id/*MPRAGE_iPAT2/*.nii* $EP_nifti_new /import/monstrum/ONM/7T/subjects/$id/PR/axial_structural_slice_PR.nii #creates axial slice using mprage

echo "Starting extract sagittal structural slice"

extract_slice.sh /import/monstrum/ONM/7T/subjects/$id/*MPRAGE_iPAT2/*.nii* $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id/PR/sagittal_structural_slice_PR.nii #creates sagittal slice using mprage

echo "Done extracting all slices"

##FSLSTATS ON ENT,MOFC,TEMPORAL##

ent_fsl_data=$(fslstats $EP_nifti_new -k /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/entorhinal_cest_ROI_PR.nii -M -S -V)


temp_fsl_data=$(fslstats $EP_nifti_new -k /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/temporal_pole_cest_ROI_PR.nii -M -S -V) 


mOFC_fsl_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/mOFC_cest_ROI_PR.nii -M -S -V) 


echo $id $ent_fsl_data $temp_fsl_data $mOFC_fsl_data >> /import/monstrum/ONM/7T/subjects/$id/PR/ent_temp_mOFC_data.txt


#####Threshold B0MAP####

B0dicoms=`ls -v /import/monstrum/ONM/7T/subjects/$id/*None*/PR/S0991*/*dcm 2> /dev/null` #create list of all folders that contain B0 dicoms
EP_B0dicoms=`echo $B0dicoms | cut -d " " -f1` #list of EP dicoms
#mOFC_B0dicoms=`echo $B0dicoms | cut -d " " -f2` #list of mOFC dicoms

B0_EP_use=`echo $EP_B0dicoms | cut -d "/" -f1-10` #creates list of the EP folders to use for dicom2nifti
#B0_mOFC_use=`echo $mOFC_B0dicoms | cut -d "/" -f1-10` #creates list of the mOFC folders to use for dicom2nifti

dicom2nifti.sh -uF -r Y /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_PR.nii $B0_EP_use/*.dcm #output cest nifti for EP; axial
dicom2nifti.sh -u -r Y /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_PR.nii $B0_mOFC_use/*.dcm #output cest nifti for mOFC; sagittal

#Axial B0MAP threshold 
	
	#thresholded EP B0MAP -1 to 1
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_PR.nii -thr -1 -uthr 1 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_PR.nii.gz -add 1.01 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_temp_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_temp_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_PR.nii.gz
	
	#thresholded EP B0MAP -.3-.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_PR.nii -thr -0.3 -uthr 0.3 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_change_PR.nii.gz -add 1.01 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_temp_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_temp_change_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_change_PR.nii.gz

B0_EP_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_PR.nii.gz -V) 
B0_EP_volume_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_change_PR.nii.gz -V)



#Sagittal B0MAP threshold

	#thresholded mOFC B0MAP -1 to 1
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_PR.nii -thr -1 -uthr 1 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_PR.nii.gz -add 1.01 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_temp_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_temp_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_PR.nii.gz
	
	#thresholded mOFC B0MAP -.3 to .3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_PR.nii -thr -0.3 -uthr 0.3 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_change_PR.nii.gz -add 1.01 /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_temp_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_temp_change_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_change_PR.nii.gz

B0_mOFC_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_PR.nii.gz -V)
B0_mOFC_volume_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_change_PR.nii.gz -V) 

#####Threshold B1MAP####

B1dicoms=`ls -v /import/monstrum/ONM/7T/subjects/$id/*None*/PR/S0992*/*dcm 2> /dev/null` #create list of all folders that contain B1 dicoms
EP_B1dicoms=`echo $B1dicoms | cut -d " " -f1` #list of EP dicoms
mOFC_B1dicoms=`echo $B1dicoms | cut -d " " -f2` #list of mOFC dicoms

B1_EP_use=`echo $EP_B1dicoms | cut -d "/" -f1-10` #creates list of the EP folders to use for dicom2nifti
B1_mOFC_use=`echo $mOFC_B1dicoms | cut -d "/" -f1-10` #creates list of the mOFC folders to use for dicom2nifti

dicom2nifti.sh -uF -r Y /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_PR.nii $B1_EP_use/*.dcm #output cest nifti for EP
dicom2nifti.sh -u -r Y /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_PR.nii $B1_mOFC_use/*.dcm #output cest nifti for mOFC

#Axial B1MAP threshold 

	#thresholded EP B1MAP 0.3-1.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_PR.nii -thr 0.3 -uthr 1.3 /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_binary_mask_PR.nii.gz

	#thresholded EP B1MAP 0.5-1.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_PR.nii -thr 0.5 -uthr 1.3 /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_change_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_binary_mask_change_PR.nii.gz

B1_EP_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_binary_mask_PR.nii.gz -V) 
B1_EP_volume_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_binary_mask_change_PR.nii.gz -V)

#Sagittal B1MAP threshold

	#thresholded mOFC B1MAP 0.3-1.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_PR.nii -thr 0.3 -uthr 1.3 /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.3_1.3_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.3_1.3_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.3_1.3_binary_mask_PR.nii.gz

	#thresholded mOFC B1MAP 0.5-1.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_PR.nii -thr 0.5 -uthr 1.3 /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.5_1.3_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.5_1.3_change_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.5_1.3_binary_mask_change_PR.nii.gz

B1_mOFC_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.3_1.3_binary_mask_PR.nii.gz -V)
B1_mOFC_volume_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.5_1.3_binary_mask_change_PR.nii.gz -V)

echo "B0 Only" $B0_EP_volume $B0_EP_volume_change $B0_mOFC_volume $B0_mOFC_volume_change > /import/monstrum/ONM/7T/subjects/$id/PR/B0_volumes.txt

echo "B1 Only" $B1_EP_volume $B1_EP_volume_change $B1_mOFC_volume $B1_mOFC_volume_change > /import/monstrum/ONM/7T/subjects/$id/PR/B1_volumes.txt

######Make binary ROI mask for quantification and measure its size####### 

#Entorhinal

	#threshold entorhinal ROI 
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/entorhinal_cest_ROI_PR.nii -thr 0.50 /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_thr_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_thr_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz 

msg1="Entorhinal"
ento_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz -V)


#merge B0, B1, and ROI masks entorhinal for -1 to 1 thresholdd B0MAP and B1MAP .3-1.3
	#fslmaths $i/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz -mul $i/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_PR.nii.gz $i/PR/entorhinal_cest/"$id"_ento_B0_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_binary_mask_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_PR.nii.gz
	#fslmaths $i/PR/entorhinal_cest/"$id"_ento_B0_PR.nii.gz -mul $i/PR/entorhinal_cest/"$id"_ento_B1_PR.nii.gz $i/PR/entorhinal_cest/"$id"_ento_ROI_thresh_by_B0_B1_PR.nii.gz

#merge B0, B1, and ROI masks entorhinal for -0.3 to .3 thresholdd B0MAP and B1MAP .5-1.3
	#fslmaths $i/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz -mul $i/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_change_PR.nii.gz $i/PR/entorhinal_cest/"$id"_ento_B0_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_entorhinal_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_binary_mask_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_change_PR.nii.gz
	#fslmaths $i/PR/entorhinal_cest/"$id"_ento_B0_change_PR.nii.gz -mul $i/PR/entorhinal_cest/"$id"_ento_B1_change_PR.nii.gz $i/PR/entorhinal_cest/"$id"_ento_ROI_thresh_by_B0_B1_change_PR.nii.gz


#extract data from B0B1cest map using merged ROI for B0MAP thresholded -1 to 1 and B1MAP .3-1.3
		fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_PR.nii.gz
		ento_glucest=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_PR.nii.gz -M)
		ento_glucest1=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_PR.nii.gz -l 0.001 -M) 
		#ento_b0_mask=$(fslstats $i/PR/entorhinal_cest/"$id"_ento_B0_PR.nii.gz -V)
		ento_b1_mask=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_PR.nii.gz -V)
		#ento_final_mask=$(fslstats $i/PR/entorhinal_cest/"$id"_ento_ROI_thresh_by_B0_B1_PR.nii.gz -V)
		
echo $subjid $msg1 $ento_volume $ento_b1_mask $ento_glucest $ento_glucest1 > /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_glucest_data_output.txt

#extract data from B0B1cest map using merged ROI for B0MAP thresholded -0.3 to 0.3 and B1MAP .5-1.3
		fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_change_PR.nii.gz
		ento_glucest_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_change_PR.nii.gz -M)
		ento_glucest1_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_Glucest_data_change_PR.nii.gz -l 0.001 -M) 
		#ento_b0_mask_change=$(fslstats $i/PR/entorhinal_cest/"$id"_ento_B0_change_PR.nii.gz -V)
		ento_b1_mask_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_B1_change_PR.nii.gz -V)
		#ento_final_mask_change=$(fslstats $i/PR/entorhinal_cest/"$id"_ento_ROI_thresh_by_B0_B1_change_PR.nii.gz -V)
		
echo $subjid $msg1 $ento_volume $ento_final_mask $ento_b1_mask $ento_glucest $ento_glucest1 > /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_glucest_data_output.txt

echo $subjid $msg1 $ento_volume_change $ento_b0_mask_change $ento_b1_mask_change $ento_glucest_change $ento_glucest1_change > /import/monstrum/ONM/7T/subjects/$id/PR/entorhinal_cest/"$id"_ento_glucest_data_output_change.txt

#Temporal Pole
	#threshold temporal pole ROI
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/temporal_pole_cest_ROI_PR.nii -thr 0.50 /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_thr_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_thr_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz

msg2="Temporal Pole"

temppole_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz -V)

#merge B0, B1, and ROI masks temporal pole for B0MAP threshold -1 to 1 and B1MAP threshold .3-1.3

	#fslmaths $i/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz -mul $i/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_PR.nii.gz $i/PR/temporal_pole_cest/"$id"_temppole_B0_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.3_1.3_binary_mask_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_B1_PR.nii.gz
	#fslmaths $i/PR/temporal_pole_cest/"$id"_temppole_B0_PR.nii.gz -mul $i/PR/temporal_pole_cest/"$id"_temppole_B1_PR.nii.gz $i/PR/temporal_pole_cest/"$id"_temppole_ROI_thresh_by_B0_B1_PR.nii.gz

#merge B0, B1, and ROI masks temporal pole for B0MAP threshold -0.3 to 0.3 and B1MAP threshold .5-1.3

	#fslmaths $i/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz -mul $i/PR/B0MAP/"$id"_B0MAP_EP_thr_binary_mask_change_PR.nii.gz $i/PR/temporal_pole_cest/"$id"_temppole_B0_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temporal_pole_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_EP_thr_0.5_1.3_binary_mask_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_B1_change_PR.nii.gz
	#fslmaths $i/PR/temporal_pole_cest/"$id"_temppole_B0_change_PR.nii.gz -mul $i/PR/temporal_pole_cest/"$id"_temppole_B1_change_PR.nii.gz $i/PR/temporal_pole_cest/"$id"_temppole_ROI_thresh_by_B0_B1_change_PR.nii.gz


#extract data from B0B1cest map using merged ROI for B0MAP threshold -1 to 1 and B1MAP .3-1.3
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_B1_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_PR.nii.gz
		temppole_glucest=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_PR.nii.gz -M)
		temppole_glucest1=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_PR.nii.gz -l 0.001 -M) 
		#temppole_b0_mask=$(fslstats $i/PR/temporal_pole_cest/"$id"_temppole_B0_PR.nii.gz -V)
		temppole_b1_mask=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_B1_PR.nii.gz -V)
		#temppole_final_mask=$(fslstats $i/PR/entorhinal_cest/"$id"_temppole_ROI_thresh_by_B0_B1_PR.nii.gz -V)
		echo $subjid $msg1 $temppole_volume $temppole_b1_mask $temppole_glucest $temppole_glucest1 >> /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_glucest_data_output.txt

#extract data from B0B1cest map using merged ROI for B0MAP threshold -0.3 to 0.3 and B1MAP .5-1.3
		
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_EP_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/		temporal_pole_cest/"$id"_temppole_B1_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_change_PR.nii.gz
	temppole_glucest_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_change_PR.nii.gz -M)
	temppole_glucest1_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_Glucest_data_change_PR.nii.gz -l 0.001 -M) 
		#temppole_b0_mask_change=$(fslstats $i/PR/temporal_pole_cest/"$id"_temppole_B0_change_PR.nii.gz -V)
		temppole_b1_mask_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_B1_change_PR.nii.gz -V)
		#temppole_final_mask_change=$(fslstats $i/PR/entorhinal_cest/"$id"_temppole_ROI_thresh_by_B0_B1_change_PR.nii.gz -V)
		
echo $subjid $msg1 $temppole_volume_change $temppole_b1_mask_change $temppole_glucest_change $temppole_glucest1_change > /import/monstrum/ONM/7T/subjects/$id/PR/temporal_pole_cest/"$id"_temppole_glucest_data_output_change.txt

#mOFC 
	#thresholded mOFC ROI
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/mOFC_cest_ROI_PR.nii -thr 0.50 /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_thr_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_thr_PR.nii.gz -bin /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz

#msg3="mOFC"
mOFC_volume=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz -V)

#merge B0, B1, and ROI masks mOFC for B0MAP threshold -1 to 1 and B1MAP threshold 0.3-1.3

	#fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.3_1.3_binary_mask_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_PR.nii.gz
	#fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_thresh_by_B0_B1_PR.nii.gz

#merge B0, B1, and ROI masks mOFC for B0MAP threshold -0.3 to 0.3 and B1MAP threshold 0.5-1.3

	#fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B0MAP/"$id"_B0MAP_mOFC_thr_binary_mask_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_change_PR.nii.gz
	fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_slice_binary_mask_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/B1MAP/"$id"_B1MAP_mOFC_thr_0.5_1.3_binary_mask_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_change_PR.nii.gz
	#fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_change_PR.nii.gz -mul /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_thresh_by_B0_B1_change_PR.nii.gz

#extract data from B0B1cest map using merged ROI B0MAP threshold -1 to 1 and B1MAP threshold 0.3-1.3
		fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_mOFC_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_PR.nii.gz
		mOFC_glucest=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_PR.nii.gz -M)
		mOFC_glucest1=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_PR.nii.gz -l 0.001 -M) 
		#mOFC_b0_mask=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_PR.nii.gz -V)
		mOFC_b1_mask=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_PR.nii.gz -V)
		#mOFC_final_mask=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_thresh_by_B0_B1_PR.nii.gz -V)
		echo $subjid $msg1 $mOFC_volume $mOFC_b1_mask $mOFC_glucest $mOFC_glucest1 > /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_glucest_data_output.txt

#extract data from B0B1cest map using merged ROI B0MAP threshold -0.3 to 0.3 and B1MAP threshold 0.5-1.3
		fslmaths /import/monstrum/ONM/7T/subjects/$id/PR/"$id"_mOFC_cest_PR.nii -mas /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_change_PR.nii.gz /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_change_PR.nii.gz
		mOFC_glucest_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_change_PR.nii.gz -M)
		mOFC_glucest1_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_Glucest_data_change_PR.nii.gz -l 0.001 -M) 
		#mOFC_b0_mask_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B0_change_PR.nii.gz -V)
		mOFC_b1_mask_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_B1_change_PR.nii.gz -V)
		#mOFC_final_mask_change=$(fslstats /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_ROI_thresh_by_B0_B1_change_PR.nii.gz -V)
		echo $subjid $msg1 $mOFC_volume_change $mOFC_b1_mask_change $mOFC_glucest_change $mOFC_glucest1_change > /import/monstrum/ONM/7T/subjects/$id/PR/mOFC_cest/"$id"_mOFC_glucest_data_output_change.txt



#####EXTRACT ALL RIGHT HEMISPHERE FREESURFER ROIS FOR EACH SUBJECT#####

##assumes that FS rois have been extracted to volume space and one file made for each ROI

mkdir /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_rois_PR #folder to place the registered ROI 
mkdir /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR #folder to place the extracted ROIs created by new registered FS ROIs

	######EXTRACT ALL RH ROIS######
	for j in /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/*_rh_*
	do

	echo $j

	name=`echo $j | cut -d "." -f1`
	name_use=`echo $name | cut -d "/" -f10`

	antsRegistrationSyNQuick.sh -d 3 -f /import/monstrum/ONM/7T/subjects/$id/*MPRAGE*/*.nii* -m /import/monstrum/ONM/subjects/$bblid*/*MPRAGE*/bet/*BET_SEQ04.nii.gz -o /import/monstrum/ONM/7T/subjects/reg/"$bblid"_Reg3T_2_7T


	antsApplyTransforms -d 3 -n MultiLabel -i $j -o /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_rois_PR/"$name_use"_2_7T.nii.gz -r /import/monstrum/ONM/7T/subjects/$id/*MPRAGE*/*.nii* -t /import/monstrum/ONM/7T/subjects/reg/"$bblid"_Reg3T_2_7T0GenericAffine.mat

	echo "Start extracting $name_use slice"  
	
	echo $name
	echo $name_use

	extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_rois_PR/"$name_use"_2_7T.nii.gz $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$name_use"_cest_ROI.nii.gz #creates ROI from registered ROI onto the CEST map image mOFC nifti
	
	echo "Done extracting $name_use slice" 
		
	roi_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$name_use"_cest_ROI.nii.gz -M -S -V)
	
	echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$id"_glucest_data.txt

	echo "Done $name_use slice" 

	done

######EXTRACT LEFT HEMISPHERE ROIs#####
	
	for j in /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/*_lh_*
	do

	echo $j

	name=`echo $j | cut -d "." -f1`
	name_use=`echo $name | cut -d "/" -f10`

	antsRegistrationSyNQuick.sh -d 3 -f /import/monstrum/ONM/7T/subjects/$id/*MPRAGE*/*.nii* -m /import/monstrum/ONM/subjects/$bblid*/*MPRAGE*/bet/*BET_SEQ04.nii.gz -o /import/monstrum/ONM/7T/tmp_3_3/reg/"$bblid"_Reg3T_2_7T


	antsApplyTransforms -d 3 -n MultiLabel -i $j -o /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_rois_PR/"$name_use"_2_7T.nii.gz -r /import/monstrum/ONM/7T/subjects/$id/*MPRAGE*/*.nii* -t /import/monstrum/ONM/7T/tmp_3_3/reg/"$bblid"_3T_2_7T0GenericAffine.mat

	echo "Start extracting $name_use slice"  
	
	echo $name
	echo $name_use

	extract_slice.sh -MultiLabel /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_rois_PR/"$name_use"_2_7T.nii.gz $mOFC_nifti_new /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$name_use"_cest_ROI.nii.gz #creates ROI from registered ROI onto the CEST map image mOFC nifti
	
	echo "Done extracting $name_use slice" 
		
	roi_data=$(fslstats $mOFC_nifti_new -k /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$name_use"_cest_ROI.nii.gz -M -S -V)
	
	echo $name_use $roi_data >> /import/monstrum/ONM/7T/subjects/$id/7T_ROIs/all_fs_ROIs/registered_extract_PR/"$id"_glucest_data.txt

	echo "Done $name_use slice" 

		done

done
