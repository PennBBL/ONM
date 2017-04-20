file=/import/monstrum/ONM/scripts/DWI/CSF_Thresh.txt

for i in `ls -d /import/monstrum/ONM/subjects/*`; do
  subjid=`echo $i | cut -d "/" -f 6`
  scanid=`echo $subjid | cut -d "_" -f 2`
  cd $i/*dwi_ADC_[Am][Da][Cp]/nifti
  if [ ! -e "00"$scanid"_csf_rescaled_masked.nii.gz" ]; then
    if [ -e "00"$scanid"_CSF_mask.nii.gz" ]; then
      echo "processing" $scanid
      fslmaths "00"$scanid"_brain_rescaled_masked.nii.gz" -mas "00"$scanid"_CSF_mask.nii.gz" "00"$scanid"_CSF"
      mean=`fslstats "00"$scanid"_CSF" -M` 
      sd=`fslstats "00"$scanid"_CSF" -S`
      sd2=`echo "$sd * 2" | bc`
      thresh=`echo "$mean - $sd" | bc`
      echo $subjid "Mean" $mean "2*SD" $sd2 "Thresh" $thresh >> $file
      fslmaths "00"$scanid"_brain_rescaled_masked.nii.gz" -uthr $thresh "00"$scanid"_csf_rescaled_masked.nii.gz"
    else
      echo "No CSF Mask"
      echo $subjid "No CSF Mask" >> $file
    fi
  fi
done
