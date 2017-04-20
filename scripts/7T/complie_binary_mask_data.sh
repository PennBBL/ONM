cat /import/monstrum/ONM/7T/subjects/subj_7t_list.txt | while read id

do

bblid=`echo $id | cut -d "_" -f1`

cp /import/monstrum/ONM/7T/subjects/$id/DR/$bblid"_mask_vol.txt" /import/monstrum/ONM/7T/data_analysis/progs/$bblid"_mask_vol.txt"

cd /import/monstrum/ONM/7T/data_analysis/

cat *.txt >> mask_size.txt

done
