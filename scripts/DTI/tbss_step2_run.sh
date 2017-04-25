#this script will run the second set of TBSS on the DTI data in the ONM group results DTI directory, it is submitted by the wrapper script tbss_run.sh

source /etc/bashrc

#move into the ONM group results DTI TBSS directory where the data is to be processed
cd /import/monstrum/ONM/group_results/DTI/TBSS

#run the second step of TBSS
tbss_2_reg -T
