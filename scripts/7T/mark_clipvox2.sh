#!/bin/bash
# ---------------------------------------------------------------
cd /import/monstrum/ONM/7T/subjects

echo "subjid EP_CEST EP_CEST100ppm EP_CEST20ppm OFC_CEST OFC_CEST100ppm OFC_CEST20ppm"

for subjid in [0-9]*; do
    
    for d in $subjid/S*_R_EP-CEST_1.5*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_combinedmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_combinedmask.clipqa`
            ccount1=`echo $line |cut -d ' ' -f2`
        else
            ccount1='-'
        fi  
    done  
 
    for d in $subjid/S*_R_EP-CEST_100*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_combinedmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_combinedmask.clipqa`
            ccount2=`echo $line |cut -d ' ' -f2`
        else
            ccount2='-'
        fi  
    done  
    
     for d in $subjid/S*_R_EP-CEST_20*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_combinedmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_combinedmask.clipqa`
            ccount3=`echo $line |cut -d ' ' -f2`
        else
            ccount3='-'
        fi  
    done  

    for d in $subjid/S*_R_OFC-CEST_1.5*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_mOFCmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_mOFCmask.clipqa`
            ccount4=`echo $line |cut -d ' ' -f2`
        else
            ccount4='-'
        fi  
    done  
    
      for d in $subjid/S*_R_OFC-CEST_100*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_mOFCmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_mOFCmask.clipqa`
            ccount5=`echo $line |cut -d ' ' -f2`
        else
            ccount5='-'
        fi  
    done  
    
      for d in $subjid/S*_R_OFC-CEST_20*; do    
        if [ -d $d/dicoms ]; then
            d=$d/dicoms
        fi
        if [ -e $d/qatest_mOFCmask.clipqa ]; then
            line=`grep -w clipcount $d/qatest_mOFCmask.clipqa`
            ccount6=`echo $line |cut -d ' ' -f2`
        else
            ccount6='-'
        fi  
    done  
    
    
    echo $subjid $ccount1 $ccount2 $ccount3 $ccount4 $ccount5 $ccount6
    
     
done
exit 0 
