rm -rf /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv
echo "subid,left_mean_length,right_mean_length" > /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv

for i in `ls -d /import/monstrum/ONM/subjects/*/*MPRAGE*moco3/sulci`; do

left=`cat $i/l_results_MQ.csv | tail -5 | grep "Mean" | rev | cut -d "," -f 1 | rev`
right=`cat $i/r_results_MQ.csv | tail -5 | grep "Mean" | rev | cut -d "," -f 1 | rev`
subid=`echo $i | cut -d "/" -f 6`

echo $subid
echo $left
echo $right

echo $subid","$left","$right >> /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv

done
