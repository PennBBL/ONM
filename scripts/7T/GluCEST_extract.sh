for i in /import/monstrum/ONM/7T/subjects/*

do

a=`echo $i| cut -d "/" -f7`
b=`fslstats $i/GluCEST/entorhinal/*.ento_GluCEST_data.nii.gz -M -S -V`
c=`fslstats $i/GluCEST/mOFC/*.mOFC_GluCEST_data.nii.gz -M -S -V`
echo $a $b >>onm_GluCEST_data_ento_temp.txt;
echo $a $c >>onm_GluCEST_data_mOFC.txt;
done
