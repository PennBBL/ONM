for s in /import/monstrum/ONM/7T/subjects/*; do
	subjid=`echo $s |cut -d '/' -f7`;
	echo $subjid


ento_processed=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice.nii
Ent_B0map=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_EP[_-]CEST_1.5*/dicoms/B0map.nii)
Ent_B1map=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_EP[_-]CEST_1.5*/dicoms/B1map.nii)
Ent_MTRmap=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_EP[_-]CEST_1.5*/dicoms/MTR0map.nii)
Ent_B0B1CESTmap=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_EP[_-]CEST_1.5*/dicoms/B0B1CESTmap.nii)
mOFC_B0map=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_OFC[_-]CEST_1.5*/dicoms/B0map.nii)
mOFC_B1map=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_OFC[_-]CEST_1.5*/dicoms/B1map.nii)
mOFC_MTRmap=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_OFC[_-]CEST_1.5*/dicoms/MTRmap.nii)
mOFC_B0B1CESTmap=$(ls /import/monstrum/ONM/7T/subjects/$subjid/*R_OFC[_-]CEST_1.5*/dicoms/B0B1CESTmap.nii)
glucest_entorhinal=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/B0B1CESTmap.nii
glucest_mOFC=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/B0B1CESTmap.nii
binary_entorhinal_ROI=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_binary_mask.nii.gz
binary_temporalpole_ROI=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_binary_mask.nii.gz
binary_mOFC_ROI=/import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/$subjid.mOFC_ROI_slice_binary_mask.nii.gz
GluCEST_data_output=/import/monstrum/ONM/group_results/7T/GluCEST/GluCEST_data_output.txt
B0_B1=/import/monstrum/ONM/group_results/7T/GluCEST/B0B1.txt

	mkdir /import/monstrum/ONM/7T/subjects/$subjid/GluCEST

	#Find and copy raw data for processing	
	if [ -e "$Ent_B0B1CESTmap" ]; then
	mkdir /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/
	cp $Ent_B0map /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/
	cp $Ent_B1map /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/
	cp $Ent_MTRmap /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/
	cp $Ent_B0B1CESTmap /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/entorhinal/
	else
	echo "No Entorhinal ROI"
	fi

	if [ -e "$mOFC_B0B1CESTmap" ]; then
	mkdir /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/
	cp $mOFC_B0map /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/
	cp $mOFC_B1map /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/
	cp $mOFC_MTRmap /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/
	cp $mOFC_B0B1CESTmap /import/monstrum/ONM/7T/subjects/$subjid/GluCEST/mOFC/
	else
	echo "No mOFC ROI"
	fi

	

		#Create ROI slice and MPRAGE slice to match the CEST map for each ROI
		if [ -e "$glucest_entorhinal" ]; then 
		echo "***********************************************"
		echo "Entorhinal GluCEST exists, extracting ROI slice"
		echo "***********************************************"
		/import/speedy/scripts/bin/extract_slice.sh $s/7T_ROIs/Imscribe*entorhinal.nii $glucest_entorhinal $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice.nii
		echo "extract ROI slice from MPRAGE"
		/import/speedy/scripts/bin/extract_slice.sh $s/*MPRAGE_iPAT2/nifti/*.nii* $glucest_entorhinal $s/GluCEST/entorhinal/$subjid.entorhinal_structrual_slice.nii
		else
		echo "###########################################"
		echo "Entorhinal GluCEST does NOT exist, skipping"
		echo "###########################################"
		fi

		#Create ROI slice and MPRAGE slice to match the CEST map for each ROI
		if [ -e "$glucest_entorhinal" ]; then 
		echo "***********************************************"
		echo "TempPole GluCEST exists, extracting ROI slice"
		echo "***********************************************"
		/import/speedy/scripts/bin/extract_slice.sh $s/7T_ROIs/Imscribe*temporalpole.nii $glucest_entorhinal $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice.nii
		echo "extract ROI slice from MPRAGE"
		/import/speedy/scripts/bin/extract_slice.sh $s/*MPRAGE_iPAT2/nifti/*.nii* $glucest_entorhinal $s/GluCEST/entorhinal/$subjid.temporalpole_structrual_slice.nii
		else
		echo "###########################################"
		echo "TempPole GluCEST does NOT exist, skipping"
		echo "###########################################"
		fi

		if [ -e "$glucest_mOFC" ]; then 
		echo "***********************************************"
		echo "mOFC GluCEST exists, extracting ROI slice"
		echo "***********************************************"
		/import/speedy/scripts/bin/extract_slice.sh $s/7T_ROIs/*rh_medorbifrontal_RPI.nii $glucest_mOFC $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice.nii
		echo "extract ROI slice from MPRAGE"
		/import/speedy/scripts/bin/extract_slice.sh $s/*MPRAGE_iPAT2/nifti/*.nii* $glucest_mOFC $s/GluCEST/mOFC/$subjid.mOFC_structrual_slice.nii
		else
		echo "###########################################"
		echo "mOFC GluCEST does NOT exist, skipping"
		echo "###########################################"
		fi	

		echo "###########################################"
		echo "masking B0 and B1 maps"
		echo "###########################################"


		#Threshold B0 & B1 maps for use in thresholding B0B1CEST map
		#B0 threshold: -1 to 1
		#B1 threshold: between 0.3-1.3?
		#Entorhinal/Temporal B0 map
		msgA="Entorhinal/TemporalPole B0"
		fslmaths $s/GluCEST/entorhinal/B0map.nii -thr -1 -uthr 1 $s/GluCEST/entorhinal/$subjid.B0map_thr.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.B0map_thr.nii.gz -add 1.01 $s/GluCEST/entorhinal/$subjid.B0map_thr_temp.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.B0map_thr_temp.nii.gz -bin $s/GluCEST/entorhinal/$subjid.B0map_thr_binary_mask.nii.gz
		B0_volume_ento_temp=$(fslstats $s/GluCEST/entorhinal/$subjid.B0map_thr_binary_mask.nii.gz -V)
		rm -rf $s/GluCEST/entorhinal/$subjid.B0map_thr_temp.nii.gz

		echo "masking B0 ento/temp complete"

		#Entorhinal/Temporal B1 map
		msgB="Entorhinal/TemporalPole B1"
		fslmaths $s/GluCEST/entorhinal/B1map.nii -thr 0.3 -uthr 1.3 $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3.nii.gz -bin $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz
		B1_volume_ento_temp=$(fslstats $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz -V)

		echo "masking B1 ento/temp complete"

		#mOFC B0 map
		msgC="mOFC B0"
		fslmaths $s/GluCEST/mOFC/B0map.nii -thr -1 -uthr 1  $s/GluCEST/mOFC/$subjid.B0map_thr.nii.gz
		fslmaths $s/GluCEST/mOFC/$subjid.B0map_thr.nii.gz -add 1.01 $s/GluCEST/mOFC/$subjid.B0map_thr_temp.nii.gz
		fslmaths $s/GluCEST/mOFC/$subjid.B0map_thr.nii.gz -bin $s/GluCEST/mOFC/$subjid.B0map_thr_binary_mask.nii.gz
		B0_volume_mOFC=$(fslstats $s/GluCEST/mOFC/$subjid.B0map_thr_binary_mask.nii.gz -V)
		rm -rf $s/GluCEST/mOFC/$subjid.B0map_thr_temp.nii.gz

		echo "masking B0 mOFC complete" 

		#mOFC B1 map
		msgD="mOFC B1"
		fslmaths $s/GluCEST/mOFC/B1map.nii -thr 0.3 -uthr 1.3 $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3.nii.gz
		fslmaths $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3.nii.gz -bin $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz
		B1_volume_mOFC=$(fslstats $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz -V)

		echo "masking B1 mOFC complete"

		#echo $subjid $msgA $B0_volume_ento_temp $msgB $B1_volume_ento_temp $msgC $B0_volume_mOFC $msgD $B1_volume_mOFC>> $B0_B1
		

		###########Make binary ROI mask for quantification and measure its size
		if [ -e "$glucest_entorhinal" ]; then
		echo "***********************************************************"
		echo "making Binary mask and quantifying GluCEST and ROI size now"
		echo "***********************************************************"
		fslmaths $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice.nii -thr 0.50 $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_thr.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_thr.nii.gz -bin $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_binary_mask.nii.gz
		#######echo "Entorhinal"
		msg1="Entorhinal"
		ento_volume=$(fslstats $s/GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_binary_mask.nii.gz -V)
		#merge B0, B1 and ROI masks
		fslmaths $binary_entorhinal_ROI -mul $s/GluCEST/entorhinal/$subjid.B0map_thr_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.ento_B0.nii.gz
		fslmaths $binary_entorhinal_ROI -mul $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.ento_B1.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.ento_B0.nii.gz -mul $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.ento_ROI_thresh_by_B0_B1.nii.gz
		#extract data from B0B1cest map using merged ROI
		fslmaths $Ent_B0B1CESTmap -mas $s/GluCEST/entorhinal/$subjid.ento_ROI_thresh_by_B0_B1.nii.gz $s/GluCEST/entorhinal/$subjid.ento_GluCEST_data.nii.gz
		ento_glucest=$(fslstats $s/GluCEST/entorhinal/$subjid.ento_GluCEST_data.nii.gz -M)
		ento_glucest1=$(fslstats $s/GluCEST/entorhinal/$subjid.ento_GluCEST_data.nii.gz -l 0.001 -M) 
		ento_b0_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.ento_B0.nii.gz -V)
		ento_b1_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.ento_B1.nii.gz -V)
		ento_final_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.ento_ROI_thresh_by_B0_B1.nii.gz -V)
		echo $subjid $msg1 $ento_volume $ento_final_mask $ento_b0_mask $ento_b1_mask $ento_glucest $ento_glucest1 >> $GluCEST_data_output
		echo "moving on to mOFC, if it exists"	
		else
		echo "Entorhinal GluCEST does NOT exist, skipping"
		fi 	
		
		#Temporal_Pole
		if [ -e "$glucest_entorhinal" ]; then
		echo "***********************************************************"
		echo "making Binary mask and quantifying GluCEST and ROI size now"
		echo "***********************************************************"
		fslmaths $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice.nii -thr 0.50 $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_thr.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_thr.nii.gz -bin $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_binary_mask.nii.gz
		echo "TemporalPole"
		msg3="TemporalPole"
		temppole_volume=$(fslstats $s/GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_binary_mask.nii.gz -V)
		#merge B0, B1 and ROI masks
		fslmaths $binary_temporalpole_ROI -mul $s/GluCEST/entorhinal/$subjid.B0map_thr_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.temppole_B0.nii.gz
		fslmaths $binary_temporalpole_ROI -mul $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.temppole_B1.nii.gz
		fslmaths $s/GluCEST/entorhinal/$subjid.temppole_B0.nii.gz -mul $s/GluCEST/entorhinal/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/entorhinal/$subjid.temppole_ROI_thresh_by_B0_B1.nii.gz
		#extract data from B0B1cest map using merged ROI
		fslmaths $Ent_B0B1CESTmap -mas $s/GluCEST/entorhinal/$subjid.temppole_ROI_thresh_by_B0_B1.nii.gz $s/GluCEST/entorhinal/$subjid.temppole_GluCEST_data.nii.gz
		temppole_glucest=$(fslstats $s/GluCEST/entorhinal/$subjid.temppole_GluCEST_data.nii.gz -M)
		temppole_glucest1=$(fslstats $s/GluCEST/entorhinal/$subjid.temppole_GluCEST_data.nii.gz -l 0.001 -M) 
		temppole_b0_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.temppole_B0.nii.gz -V)
		temppole_b1_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.temppole_B1.nii.gz -V)
		temppole_final_mask=$(fslstats $s/GluCEST/entorhinal/$subjid.temppole_ROI_thresh_by_B0_B1.nii.gz -V)
		echo $subjid $msg3 $temppole_volume $temppole_final_mask $temppole_b0_mask $temppole_b1_mask $temppole_glucest $temppole_glucest1 >> $GluCEST_data_output
		echo "moving on to mOFC, if it exists"	
		else
		echo "TemporalPole GluCEST does NOT exist, skipping"
		fi 
		
		#mOFC
		if [ -e "$glucest_mOFC" ]; then
		fslmaths $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice.nii -thr 0.50 $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice_thr.nii.gz		
		fslmaths $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice_thr.nii.gz -bin $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice_binary_mask.nii.gz		
		echo "mOFC"
		msg2="mOFC"
		mOFC_volume=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_ROI_slice_binary_mask.nii.gz -V)
		#merge B0, B1 and ROI masks
		fslmaths $binary_mOFC_ROI -mul $s/GluCEST/mOFC/$subjid.B0map_thr_binary_mask.nii.gz $s/GluCEST/mOFC/$subjid.mOFC_B0.nii.gz
		fslmaths $binary_mOFC_ROI -mul $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/mOFC/$subjid.mOFC_B1.nii.gz
		fslmaths $s/GluCEST/mOFC/$subjid.mOFC_B0.nii.gz -mul $s/GluCEST/mOFC/$subjid.B1map_thr_0.3_1.3_binary_mask.nii.gz $s/GluCEST/mOFC/$subjid.mOFC_ROI_thresh_by_B0_B1.nii.gz
		#extract data from B0B1cest map using merged ROI
		fslmaths $mOFC_B0B1CESTmap -mas $s/GluCEST/mOFC/$subjid.mOFC_ROI_thresh_by_B0_B1.nii.gz $s/GluCEST/mOFC/$subjid.mOFC_GluCEST_data.nii.gz
		mOFC_glucest=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_GluCEST_data.nii.gz -M)
		mOFC_glucest1=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_GluCEST_data.nii.gz -l 0.001 -M)
		mOFC_b0_mask=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_B0.nii.gz -V)
		mOFC_b1_mask=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_B1.nii.gz -V)
		mOFC_final_mask=$(fslstats $s/GluCEST/mOFC/$subjid.mOFC_ROI_thresh_by_B0_B1.nii.gz -V)
		echo $subjid $msg2 $mOFC_volume $mOFC_final_mask $mOFC_b0_mask $mOFC_b1_mask $mOFC_glucest $mOFC_glucest1 >> $GluCEST_data_output
		else
		echo "mOFC GluCEST does NOT exist, skipping"
		fi

		done

