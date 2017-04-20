export FREESURFER_HOME=/import/monstrum/Applications/freesurfer
export SUBJECTS_DIR=/import/monstrum/ONM/group_results/freesurfer/subjects
export PERL5LIB=/import/monstrum/Applications/freesurfer/mni/lib/perl5/5.8.5

#Once all three of these export requests are set up run:
tkmedit *_* T1.mgz lh.pial -aux-surface rh.pial
