#!/bin/bash
# ---------------------------------------------------------------
cd /import/monstrum/ONM/7T/subjects

for s in */S00*R_EP-CEST_*; do
#for s in */S00*R_OFC-CEST_*; do
#for s in */S00*R_*CEST_*; do

    subjid=`echo $s |cut -d '/' -f1`
    series=`echo $s |cut -d '/' -f2`
    
#	echo $subjid
	
    if [ -d $s/dicoms ]; then
        d=$s/dicoms
    else
        d=$s
    fi
        
 #   echo $d  
 #   dicom2nifti.sh -um $d/qatest $d/E[1-2]S*.dcm
 
 #   if [ -e $d/qatest.nii ]; then
 #       maskfile=$s/../GluCEST/mOFC/$subjid.mOFC_ROI_slice_binary_mask.nii.gz            
 #       if [ -e $maskfile ]; then
 #           echo $d/qatest.nii
 #           qa_clipcount_v1.sh $d/qatest.nii $maskfile $d/qatest_mOFCmask.clipqa
 #       fi
 #   fi

    if [ -e $d/qatest.nii ]; then
        maskfile1=$s/../GluCEST/entorhinal/$subjid.entorhinal_ROI_slice_binary_mask.nii.gz            
        maskfile2=$s/../GluCEST/entorhinal/$subjid.temporalpole_ROI_slice_binary_mask.nii.gz            
        maskfile3=$s/../GluCEST/entorhinal/$subjid.combined_ROI_slice_binary_mask.nii.gz            
        if [ -e $maskfile1 -a -e $maskfile2 ]; then
            echo $d/qatest.nii
            fslmaths $maskfile1 -add $maskfile2 -bin $maskfile3
            qa_clipcount_v1.sh $d/qatest.nii $maskfile3 $d/qatest_combinedmask.clipqa
        fi
    fi

 #   if [ -e $s/qatest.clipqa ]; then
 #       line=`grep -w clipcount $s/qatest.clipqa`
 #       ccount=`echo $line |cut -d ' ' -f2`
 #       echo $subjid $series $ccount 
 #   fi
        
done
exit 0 
