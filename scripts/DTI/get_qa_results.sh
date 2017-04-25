#this script loops through processed DTI images and extracts values for different QA parameters and outputs them to a subject aggregated csv

#USAGE: getqa_results.sh 

#####EDITABLE PARAMETER##########

#this is the csv file that will contain the qa output for all subjects
out='/import/monstrum/ONM/group_results/DTI/ONM_qa_results.txt'

#################################

#for each subject in ONM subjects directory
for i in /import/monstrum/ONM/subjects/*;
	do 
		#create variables for bblid and scanid		
		bblid=`echo $i|cut -d "/" -f 6 |cut -d "_" -f1`; 
		scanid=`echo $i|cut -d "/" -f 6 |cut -d "_" -f2`;
		
		#check for the bblid and scanid in the output file and if they have already had their qa data extracted then skip the subject
		grep -q "$bblid $scanid" $out && echo $bblid $scanid "has already been processed" && continue

		#move into the subject's DTI/bbl/qa directory, and print to the screen the qa file
		cd $i/*DTI*/bbl/qa; 
		ls *.qa
		echo "gathering data"

		#create variables for the different qa metrics with the values for that subject
		clipcount=$(cat *.qa |grep clipcount |awk '{print $2}');
		tsnr=$(cat *.qa |grep tsnr |awk '{print $2}'); 
		gmean=$(cat *.qa |grep gmean |awk '{print $2}');
		drift=$(cat *.qa |grep drift |awk '{print $2}');
		outmax=$(cat *.qa |grep outmax |awk '{print $2}');
		outmean=$(cat *.qa |grep outmean |awk '{print $2}');
		outcount=$(cat *.qa |grep outcount |awk '{print $2}');
		meanABSrms=$(cat *.qa |grep meanABSrms |awk '{print $2}');
		meanRELrms=$(cat *.qa |grep meanRELrms |awk '{print $2}');
		maxABSrms=$(cat *.qa |grep maxABSrms |awk '{print $2}');
		maxRELrms=$(cat *.qa |grep maxRELrms |awk '{print $2}');

	#output the subject ids and qa metrics to the output file
	echo $bblid $scanid $clipcount $tsnr $gmean $drift $outmax $outmean $outcount $meanABSrms $meanRELrms $maxABSrms $maxRELrms >>$out;

	#move back into the subject's directory (out of their DTI/bbl/qa directory)
	cd $i;


done
