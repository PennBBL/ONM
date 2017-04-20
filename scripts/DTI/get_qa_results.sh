#USAGE: getqa_results.sh 

#####EDITABLE PARAMETER##########
out='/import/monstrum/ONM/group_results/DTI/ONM_qa_results.txt'
 #set txtfile to write qa data
#################################

for i in /import/monstrum/ONM/subjects/*;
	do 
		bblid=`echo $i|cut -d "/" -f 6 |cut -d "_" -f1`; 
		scanid=`echo $i|cut -d "/" -f 6 |cut -d "_" -f2`;
		
		grep -q "$bblid $scanid" $out && echo $bblid $scanid "has already been processed" && continue

		cd $i/*DTI*/bbl/qa; 
		ls *.qa
		echo "gathering data"

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


	echo $bblid $scanid $clipcount $tsnr $gmean $drift $outmax $outmean $outcount $meanABSrms $meanRELrms $maxABSrms $maxRELrms >>$out;

	cd $i;


done
