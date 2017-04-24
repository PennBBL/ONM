#This script takes the saved results you output from ImageJ after drawing the olfactory sulci and outputs the data into a aggregated csv with each subject's data

#first remove any existing aggregated csv with sulci data in it
rm -rf /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv

#output headers for subject id, left mean sulcal length, and right mean sulcal length to a blank csv which will contain the aggregated sulcal data after this script is run
echo "subid,left_mean_length,right_mean_length" > /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv

#for each subject in the ONM subects directory with an MPRAGE sulci directory...
for i in `ls -d /import/monstrum/ONM/subjects/*/*MPRAGE*moco3/sulci`; do

#create variables which get the left mean sulcal length and right mean sulcal length from the previously created l_results and r_results csv's, also create a variable with the subject's bblid_scanid
left=`cat $i/l_results_MQ.csv | tail -5 | grep "Mean" | rev | cut -d "," -f 1 | rev`
right=`cat $i/r_results_MQ.csv | tail -5 | grep "Mean" | rev | cut -d "," -f 1 | rev`
subid=`echo $i | cut -d "/" -f 6`

#print these values to the screen, first subject id, then left sulcal mean length, then right sulcal mean length
echo $subid
echo $left
echo $right

#output these data (subject id, left sulcal mean length, right sulcal mean length) to an aggregated csv file
echo $subid","$left","$right >> /import/monstrum/ONM/group_results/sulci/mean_sulci_length_MQ.csv

done
