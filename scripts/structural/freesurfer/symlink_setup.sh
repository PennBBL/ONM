symlinkdir=/import/monstrum/ONM/group_results/freesurfer/subjects
workingdir=/import/monstrum/ONM/group_results/freesurfer/working_subjects
for i in `ls -d $workingdir/*_*`;do
	echo $i
	subid=`echo $i | cut -d "/" -f 8`
	workdir=$(ls -d "$i" 2>/dev/null)
	mprage=$(ls -d /import/monstrum/ONM/subjects/"$subid"/*MPRAGE_TI1110_ipat2_moco3 2>/dev/null | grep -v "um0" | tail -n 1)
        echo $mprage
	if [ ! -z $workdir ] && [ ! -z $mprage ]; then
		if [ ! -e "$mprage"/freesurfer ]; then
			mv $workdir "$mprage"/freesurfer
		else
			echo freesurfer directory "$mprage"/freesurfer exists
		fi
	else
		echo no mprage and/or no freesurfer working directory for $subid
	fi
	direc=$(ls -d "$mprage"/freesurfer 2>/dev/null)
	echo $direc
	echo $symlinkdir/$subid	
	if [ ! -z $direc ] && [ ! -e $symlinkdir/$subid ]; then
		echo $direc $symlinkdir/$subid
		ln -s $direc $symlinkdir/$subid
	else 
		echo no freesurfer folder for $subid
	fi
done

	
