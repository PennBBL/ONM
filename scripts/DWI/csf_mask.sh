#This script will take the CSF mask you drew previously and thresholds the brain rescaled image by the CSF so CSF is removed

#create a variable for the CSF threshold file
file=/import/monstrum/ONM/scripts/DWI/CSF_Thresh.txt

#for each subject in the ONM subjects directory...
for i in `ls -d /import/monstrum/ONM/subjects/*`; do

  #get variables for the subject id and scanid
  subjid=`echo $i | cut -d "/" -f 6`
  scanid=`echo $subjid | cut -d "_" -f 2`

  #move into the subject's dwi_ADC_map nifti directory
  cd $i/*dwi_ADC_[Am][Da][Cp]/nifti

  #if the final csf rescaled masked image created in this script doesn't exist,
  if [ ! -e "00"$scanid"_csf_rescaled_masked.nii.gz" ]; then

    #and the CSF mask you drew previously does exist...
    if [ -e "00"$scanid"_CSF_mask.nii.gz" ]; then

      #print to the screen the scanid that is being processed
      echo "processing" $scanid

      #mask the brain rescaled image by the CSF mask you drew
      fslmaths "00"$scanid"_brain_rescaled_masked.nii.gz" -mas "00"$scanid"_CSF_mask.nii.gz" "00"$scanid"_CSF"

     #create variables for the mean, standard deviation, and standard deviation squared of the CSF, as well as the threshold (mean - sd)
      mean=`fslstats "00"$scanid"_CSF" -M` 
      sd=`fslstats "00"$scanid"_CSF" -S`
      sd2=`echo "$sd * 2" | bc`
      thresh=`echo "$mean - $sd" | bc`

      #output these data into the CSF_Thresh.txt file you specified above 
      echo $subjid "Mean" $mean "2*SD" $sd2 "Thresh" $thresh >> $file

      #threshold the brain rescaled image by the csf rescaled mask
      fslmaths "00"$scanid"_brain_rescaled_masked.nii.gz" -uthr $thresh "00"$scanid"_csf_rescaled_masked.nii.gz"

	#otherwise, if there is no CSF mask then output the subject id and message to the CSF_Thresh.txt file
    else
      echo "No CSF Mask"
      echo $subjid "No CSF Mask" >> $file
    fi
  fi
done
