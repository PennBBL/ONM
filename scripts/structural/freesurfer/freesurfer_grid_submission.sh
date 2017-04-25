#this script is submitted by the wrapper script surf2grid.sh and runs freesurfer on the subjects given by the wrapper script

#!/bin/bash
. /etc/bashrc

#set freesurfer specific environment variables
export FREESURFER_HOME="/import/monstrum/Applications/freesurfer"
export PERL5LIB="/import/monstrum/Applications/freesurfer/mni/lib/perl5/5.8.5"

#set a variable for the subject directory that's passed by the wrapper script
export SUBJECTS_DIR=$2

#set a variable for the subject's mprage, and subject id that's passed by the wrapper script
mprage=$1
subjid=$3

#run recon all on that subject
recon-all -i $mprage -subjid $subjid  ## run this to set up each subject's FS directory 
recon-all -subjid $subjid -all -qcache  ## after running intial set up 
