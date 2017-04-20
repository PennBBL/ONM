#to be run after mask has been chosen and input into mask_list.txt and after CSF has been drawn on ADC and bulb mask has been drawn

#mask images
/import/monstrum/ONM/scripts/DWI/dwi_mask_images.sh

#mask csf
/import/monstrum/ONM/scripts/DWI/csf_mask.sh

#register adc and bulb (bulb mask must be drawn first)
/import/monstrum/ONM/scripts/DWI/adc_registration.sh
