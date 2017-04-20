#!/bin/bash
for i in /import/monstrum/ONM/7T/subjects/*
do

id=`echo $i | cut -d '/' -f7`
echo $id


/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/entorhinal/S0991_GRE_B0MAP/$id"_B0MAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/entorhinal/*GRE_B0MAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/entorhinal/S0992_B1MAP/$id"_B1MAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/entorhinal/*B1MAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/entorhinal/S0993_SEGMAP/$id"_SEGMAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/entorhinal/*SEGMAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/entorhinal/S0994_CESTMAP/$id"_CESTMAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/entorhinal/*CESTMAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/mOFC/S0991_GRE_B0MAP/$id"_B0MAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/mOFC/*GRE_B0MAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/mOFC/S0992_B1MAP/$id"_B1MAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/mOFC/*B1MAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/mOFC/S0993_SEGMAP/$id"_SEGMAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/mOFC/*SEGMAP/*.dcm

/import/speedy/scripts/melliott/dicom2nifti.sh -rY -uF $i/GluCEST/mOFC/S0994_CESTMAP/$id"_CESTMAP" /import/monstrum/ONM/7T/subjects/$id/GluCEST/mOFC/*CESTMAP/*.dcm

done
