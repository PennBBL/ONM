#!/bin/bash
. /etc/bashrc
export FREESURFER_HOME="/import/monstrum/Applications/freesurfer"
#export FREESURFER_HOME="/import/monstrum/Applications/freesurfer5_0"
export SUBJECTS_DIR=$2
export PERL5LIB="/import/monstrum/Applications/freesurfer/mni/lib/perl5/5.8.5"

mprage=$1
subjid=$3
recon-all -i $mprage -subjid $subjid  ## run this to set up each subject's FS directory 
recon-all -subjid $subjid -all -qcache  ## after running intial set up 
