#this script is to be run after freesurfer is done running (from surf2grid.sh and freesurfer_grid_submission.sh) it will move the freesurfer data for each newly processed subject from the working subjects directory to a freesurfer directory in their mprage directory and create a symlink with this data so the data also lives in the group results freesurfer subjects directory 

#get the output directory for the processed freesurfer data
symlinkdir=/import/monstrum/ONM/group_results/freesurfer/subjects

#get the current directory where the freesurfer data lives for newly processed subjects
workingdir=/import/monstrum/ONM/group_results/freesurfer/working_subjects

#for each newly processed subject in the working subjects directory
for i in `ls -d $workingdir/*_*`;do

	#print the subject id to the screen
	echo $i

	#create variables for the subject id, the path in the working directory, and their mprage directory
	subid=`echo $i | cut -d "/" -f 8`
	workdir=$(ls -d "$i" 2>/dev/null)
	mprage=$(ls -d /import/monstrum/ONM/subjects/"$subid"/*MPRAGE_TI1110_ipat2_moco3 2>/dev/null | grep -v "um0" | tail -n 1)
	
	#print the path to their mprage directory to the screen        
	echo $mprage
	
	#if their data is in working directory and they have an mprage directory
	if [ ! -z $workdir ] && [ ! -z $mprage ]; then

		#and they don't have a mprage freesurfer directory then
		if [ ! -e "$mprage"/freesurfer ]; then
	
			#move their working subjects freesurfer data to an mprage freesurfer directory
			mv $workdir "$mprage"/freesurfer
		else
			echo "freesurfer directory "$mprage"/freesurfer exists"
		fi
	else
		echo "no mprage and/or no freesurfer working directory for" $subid
	fi

	#get a variable for the subject's mprage freesurfer directory
	direc=$(ls -d "$mprage"/freesurfer 2>/dev/null)

	#print the path for this directory to the screen and where the data will be symlinked
	echo $direc
	echo $symlinkdir/$subid	

	#if the subject's mprage freesurfer directory has data and their symlink group results subjects directory does not then
	if [ ! -z $direc ] && [ ! -e $symlinkdir/$subid ]; then

		#print the path to the screen where the data will be symlinked
		echo $direc $symlinkdir/$subid

		#symlink the mprage freesurfer directory and the group results freesurfer subjects directory
		ln -s $direc $symlinkdir/$subid
	else 
		echo "no freesurfer folder for $subid"
	fi
done

	
