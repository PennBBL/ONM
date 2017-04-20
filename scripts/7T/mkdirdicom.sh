for i in /import/monstrum/ONM/7T/subjects/*

id=`echo $i | cut -d '/' -f7`
echo $id
do
	
	#for j in `ls -d $i/*None_prepflash`
	#do
	#mkdir $j/PR
	#mkdir $j/DR
	#mkdir $j/PR/dicoms
	#mkdir $j/DR/dicoms
	#mv $j/PR/*.dcm $j/PR/dicoms
	#mv $j/DR/*.dcm $j/DR/dicoms
	
	done
done
