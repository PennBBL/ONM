#!/import/monstrum/Applications/epd-7.1/bin/python
import xnatmaster30 as xnatmaster
import argparse
import sys
import array
import subprocess
import os
import fnmatch
import uuid
import re
'''
By chadtj
Version 1.0 Initial - Deployed
Version 1.1 Added Oblique Flag to choose to skip_oblique or not - Never Deployed
Version 1.2 Added support for config file - Never Deployed
Version 1.3 XNAT Version - Added Project Flag and general cleanup - Never Deployed
Version 1.4 Added dwi support which treats dwi like dti and fixed pyxnat config file creation and server settings, and appended date_time and version onto generated niftis - Deployed
Version 2.0 Added form support. Added d2n to filename in addition to version Cleaned up repetitive code somewhat.Added t2 support. - Deployed
Version 3.0 Massively cleaned up. Support Added for new derivitive XNAT data types, eg. bbl:nifti. Check added to download existing. Added support for comma separated scanids
Version 3.0.1 Added support for MPRAGE*moco3 scans, t2_BULB, MPRAGE_NAVprotocol, pcasl_se_we and ciss sequences. Updated AFNI to latest version.
'''
def return_needed_values(expr_id, seq_id, central):
        constraints = [('bbl:Sequence/imageSession_ID','=',str(expr_id)),'AND',('bbl:Sequence/IMAGESCAN_ID','=',str(seq_id)),'AND']
        return central.select('bbl:Sequence',['bbl:Sequence/GEOMETRY_NVOLUMES','bbl:Sequence/GEOMETRY_NZ','bbl:Sequence/MR_TR','bbl:Sequence/GEOMETRY_DZ']).where(constraints);

def print_stats(nvols, TR, slices, voxel_size, logpath):
        xnatmaster.add_to_log(logpath,"Volumes: " + nvols)
        xnatmaster.add_to_log(logpath,"TR: " + TR)
        xnatmaster.add_to_log(logpath,"Slices: " + slices)
        xnatmaster.add_to_log(logpath,"Voxel Size: " + voxel_size)

def timeshift(dicom_dir,logpath,prov_list):
        timeshifted = 1
        xnatmaster.add_to_log(logpath,"Timeshifting the EPI")
        count=0
        for filename in os.listdir(dicom_dir):
                if filename.startswith("traw"):
                        os.rename(dicom_dir + filename, dicom_dir + 'TOLD_R_A_W.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"TRAW BRIK existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'TOLD_R_A_W.' + str(count) + '.delete')
                        count = count + 1
        #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dTshift -prefix ' + dicom_dir + 'traw' + ' ' + dicom_dir + 'raw+orig',logpath)
       	xnatmaster.run_process('/import/monstrum/Applications/afni/3dTshift -prefix ' + dicom_dir + 'traw' + ' ' + dicom_dir + 'raw+orig',logpath)
	prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dTshift','AFNI version=AFNI_2011 [64-bit]','-prefix ' + dicom_dir + 'traw' + ' ' + dicom_dir + 'raw+orig')
	count=0
        for filename in os.listdir(dicom_dir):
                if filename.startswith("raw+orig"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLD_R_A_W+O_R_I_G.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"Getting rid of RAW BRIKS because we now have timeshifted BRIKS")
                        xnatmaster.add_to_log(logpath,"RAW BRIK existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLD_R_A_W+O_R_I_G.' + str(count) + '.delete')
                        count = count + 1
	return prov_list

def dcm2nii(dicom_dir,logpath,prov_list):
        xnatmaster.add_to_log(logpath,"Running dcm2nii on the DTI/DWI")
        count=0
        for filename in os.listdir(dicom_dir):
                if filename.endswith("nii.gz"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLDNIFTI.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"NIFTI existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLDNIFTI.' + str(count) + '.delete')
                        count = count + 1       
                if filename.endswith("bvec"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLDBVEC.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"BVEC existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLDBVEC.' + str(count) + '.delete')
                        count = count + 1
                if filename.endswith("bval"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLDBVAL.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"BVAL existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLDBVAL.' + str(count) + '.delete')
                        count = count + 1
        xnatmaster.run_process('/import/monstrum/Applications/mricron2013/dcm2nii -d N -a Y -p Y -d N -e N -f Y -g Y -i N -v N -o ' + dicom_dir + ' ' + dicom_dir + '*.dcm',logpath) 
	prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/mricron2013/dcm2nii','1 April 2010','-d N -a Y -p Y -d N -e N -f Y -g Y -i N -v N -o ' + dicom_dir + ' ' + dicom_dir + '*.dcm')
	return prov_list

def runTo3d(nvols, slices, TR, dicom_dir, logpath, prov_list):
        count=0
        for filename in os.listdir(dicom_dir):
                if filename.startswith("raw"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLD_R_A_W.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"RAW BRIK existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLD_R_A_W.' + str(count) + '.delete' )
                        count = count + 1
        if int(slices) % 2 == 1:
                xnatmaster.add_to_log(logpath,"Odd number of slices" )
                #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/to3d -time:zt ' + slices + ' ' + nvols + ' ' + TR + ' alt+z -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm' ,logpath)
		xnatmaster.run_process('/import/monstrum/Applications/afni/to3d -time:zt ' + slices + ' ' + nvols + ' ' + TR + ' alt+z -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm' ,logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/to3d','AFNI_2011_05_26_1457 (Nov 10 2011) [64-bit]','-time:zt ' + slices + ' ' + nvols + ' ' + \
		TR + ' alt+z -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm')        
	else:
                xnatmaster.add_to_log(logpath,"Even number of slices")
                #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/to3d -time:zt ' + slices + ' ' + nvols + ' ' + TR + ' alt+z2 -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm' ,logpath)
		xnatmaster.run_process('/import/monstrum/Applications/afni/to3d -time:zt ' + slices + ' ' + nvols + ' ' + TR + ' alt+z2 -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm' ,logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/to3d', 'AFNI_2011_05_26_1457 (Nov 10 2011) [64-bit]','-time:zt ' + slices + ' ' + nvols + ' ' + \
		TR + ' alt+z2 -session ' + dicom_dir + ' -prefix raw ' + dicom_dir + '*.dcm')
	return prov_list

def deoblique(voxels, dicom_dir, logpath, prov_list):
        xnatmaster.add_to_log(logpath,"Deoblique now")     
        count=0
        for filename in os.listdir(dicom_dir):
                if filename.startswith("reorient"):
                        os.rename(dicom_dir + filename, dicom_dir + 'TOLDRO_R_A_W.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"Trans Reoriented BRIK existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'TOLDRO_R_A_W.' + str(count) + '.delete')
                        count = count + 1
        if timeshifted:
                #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dWarp -deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + 'traw*',logpath)
		xnatmaster.run_process('/import/monstrum/Applications/afni/3dWarp -deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + 'traw*',logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dWarp','AFNI_2011 [64-bit]', \
		'-deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + 'traw*')        
	else:
               # xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dWarp -deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + '*raw*HEAD',logpath)
		xnatmaster.run_process('/import/monstrum/Applications/afni/3dWarp -deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + '*raw*HEAD',logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dWarp','AFNI_2011 [64-bit]', \
		'-deoblique -verb -prefix ' + dicom_dir + 'reorient_traw -newgrid ' + voxels + ' ' + dicom_dir + '*raw*HEAD')
	return prov_list

def resample(dicom_dir, seqname, logpath, scanid2, prov_list):
        xnatmaster.add_to_log(logpath,"Resampling and Converting")
        count=0
        for filename in os.listdir(dicom_dir):
                if filename.endswith("nii.gz"):
                        os.rename(dicom_dir + filename, dicom_dir + 'OLDNIFTI.' + str(count) + '.delete')
                        xnatmaster.add_to_log(logpath,"NIFTI existed, old file: " + dicom_dir+filename + " Will become: " + dicom_dir + 'OLDNIFTI.' + str(count) + '.delete')
                        count = count + 1
        if timeshifted:
                #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*traw+orig',logpath)
        	xnatmaster.run_process('/import/monstrum/Applications/afni/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*traw+orig',logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dresample','Version 1.9 <April 27, 2009>', \
		'-orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*traw+orig')
	elif oblique_okay:
                #xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*reorient_traw+orig.BRIK*',logpath)
        	xnatmaster.run_process('/import/monstrum/Applications/afni/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*reorient_traw+orig.BRIK*',logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dresample','Version 1.9 <April 27, 2009>', \
		'-orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*reorient_traw+orig.BRIK*')
	else: 
               # xnatmaster.run_process('/import/monstrum/Applications/afni_64bit/afni_src/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*raw*HEAD',logpath)
		xnatmaster.run_process('/import/monstrum/Applications/afni/3dresample -orient RPI -prefix ' + scanid2+'_' + formname +'.nii.gz -inset ' + dicom_dir + '*raw*HEAD',logpath)
		prov_list = xnatmaster.track_provenance(prov_list,'/import/monstrum/Applications/afni/3dresample','Version 1.9 <April 27, 2009>', \
		'-orient RPI -prefix ' + scanid2+'_'+formname +'.nii.gz -inset ' + dicom_dir + '*raw*HEAD')

	return prov_list 

def cleanup_dir(dir,logpath):
        xnatmaster.add_to_log(logpath,"Cleaning up " + dir )
        for filename in os.listdir(dir):
                if fnmatch.fnmatch(filename, '*.nii.gz') or fnmatch.fnmatch(filename, '*.bvec') or fnmatch.fnmatch(filename, '*.bval'):
                        pass
                elif fnmatch.fnmatch(filename,'*.delete') or fnmatch.fnmatch(filename, '*.dcm'):
                        os.unlink(dir + filename)

def unknown(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
        xnatmaster.add_to_log(logpath, "Error: This is an unknown sequence type. I don't know what to do yet with " + seq_id)
	xnatmaster.add_to_log(logpath, "End of the line pal.")
		

def mprage(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
	prov_list = []
	niftifound = 0
	if findexisting == '1':
		xnatmaster.add_to_log(logpath, "Checking for existing Nifti - MPRAGE/T2 sequence: " + seq_id)	
		niftifound = xnatmaster.existing_nifti(expr_id,seq_id,central)
		if niftifound > 0:
			if download == '1':
				xnatmaster.get_nifti(expr_id, seq_id, outdir, central, proj_name, subj_id)	
				xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + outdir)
			else:
				xnatmaster.get_nifti(expr_id, seq_id, tmpdir, central, proj_name, subj_id)      
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + tmpdir)
	if findexisting == '0' or str(niftifound) == '0':
		if str(niftifound) == '0':
			xnatmaster.add_to_log(logpath, "No existing Nifti - MPRAGE/T2 sequence: " + seq_id)
		else:
			xnatmaster.add_to_log(logpath, "Forcing the creation of a new Nifti - MPRAGE/T2 sequence: " + seq_id)
		if not xnatmaster.ensure_dir_exists(tmpdir+str(seq_id)+'_Dicoms') and xnatmaster.ensure_write_permissions(tmpdir+str(seq_id)+'_Dicoms'):
			sys.exit(0)
		dicom_dir = xnatmaster.download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir+str(seq_id)+'_Dicoms/',central)
		try:
                	values = return_needed_values(expr_id, seq_id, central)          
                	volumes = values.get('geometry_nvolumes')
                	TR = values.get('mr_tr')
        	        slices = values.get('geometry_nz')
 	                voxel_size = values.get('geometry_dz')
	        except IndexError, e:
        	        xnatmaster.add_to_log(logpath, e + ' - Stopping here for this sequence because all the neccessary stats could not be pulled from XNAT')
	
        	print_stats(volumes, TR, slices, voxel_size,logpath)

        	prov_list = runTo3d(volumes, slices, TR, dicom_dir,logpath,prov_list)
        	if oblique_okay == 1:
                	prov_list = deoblique(voxel_size, dicom_dir,logpath,prov_list)
        	prov_list = resample(dicom_dir, seqname,logpath,expr_id,prov_list)
	       	niftiname = expr_id+'_'+formname+'.nii.gz'
		cleanup_dir(dicom_dir,logpath)
	        if download == '1':
			xnatmaster.move(dicom_dir,outdir,niftiname)
			xnatmaster.move(os.path.dirname(logpath)+'/',outdir,os.path.basename(logpath))
			if upload == '1':
				xnatmaster.add_to_log(logpath,"Now saving into XNAT.")	
				niftipath = outdir+niftiname
				logpath = outdir+os.path.basename(logpath)
				xnatmaster.slice_it_up(niftipath,'mprage_nifti',logpath,outdir+expr_id+'_mprage_nifti_QA.png','')
				#Do upload here
				thetype="bbl:nifti"
				assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
				assname=assname.replace(".","_")
                        	assname=assname.replace("-","_")
				myproject=central.select('/projects/'+proj_name)
				assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
				if assessor.exists():
                                        print "Found original run..."
					assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
					assname=assname.replace(".","_")
                        		assname=assname.replace("-","_")
					myproject=central.select('/projects/'+proj_name)
					assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname) 
				assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
				xnatmaster.extract_provenance(assessor,prov_list)
				assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
				assessor.out_resource('QAIMAGE').file('1.png').put(outdir+expr_id+'_mprage_nifti_QA.png')
				assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)		
	        elif upload == '1':
			niftipath = dicom_dir+niftiname
	                xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
			xnatmaster.slice_it_up(niftipath,'mprage_nifti',logpath,dicom_dir+expr_id+'_mprage_nifti_QA.png','')
			#Do upload here
			thetype="bbl:nifti"
			myproject=central.select('/projects/'+proj_name)
                        assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                        assname=assname.replace(".","_")
                        assname=assname.replace("-","_")
			assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        if assessor.exists():
                               print "Found original run..."
                               assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
			       assname=assname.replace(".","_")
                               assname=assname.replace("-","_")
                               assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
			xnatmaster.extract_provenance(assessor,prov_list)
			assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)                
                        assessor.out_resource('QAIMAGE').file('1.png').put(dicom_dir+expr_id+'_mprage_nifti_QA.png')                
                        assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
		else:
			print "Should never have gotten here. Not doing anything. Make sure either -download 1 or -upload 1"
			sys.exit(0)

def dti(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
        xnatmaster.add_to_log(logpath, "Downloading DTIDWI sequence: " + seq_id)
	prov_list = []
        niftifound = 0
        if findexisting == '1':
                xnatmaster.add_to_log(logpath, "Checking for existing Nifti - DTI sequence: " + seq_id)
                niftifound = xnatmaster.existing_nifti(expr_id,seq_id,central)
                if niftifound > 0:
                        if download == '1':
                                xnatmaster.get_dti_nifti(expr_id, seq_id, outdir, central, proj_name, subj_id)
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + outdir)
                        else:
                                xnatmaster.get_dti_nifti(expr_id, seq_id, tmpdir, central, proj_name, subj_id)
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + tmpdir)
        if findexisting == '0' or str(niftifound) == '0':
                if str(niftifound) == '0':
                        xnatmaster.add_to_log(logpath, "No existing Nifti - DTI sequence: " + seq_id)
                else:
                        xnatmaster.add_to_log(logpath, "Forcing the creation of a new Nifti - DTI sequence: " + seq_id)
                if not xnatmaster.ensure_dir_exists(tmpdir+str(seq_id)+'_Dicoms') and xnatmaster.ensure_write_permissions(tmpdir+str(seq_id)+'_Dicoms'):
                        sys.exit(0)
                dicom_dir = xnatmaster.download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir+str(seq_id)+'_Dicoms/',central)
                try:
                        values = return_needed_values(expr_id, seq_id, central)
                        volumes = values.get('geometry_nvolumes')
                        TR = values.get('mr_tr')
                        slices = values.get('geometry_nz')
                        voxel_size = values.get('geometry_dz')
                except IndexError, e:
                        xnatmaster.add_to_log(logpath, e + ' - Stopping here for this sequence because all the neccessary stats could not be pulled from XNAT')
                print_stats(volumes, TR, slices, voxel_size,logpath)
		prov_list = dcm2nii(dicom_dir,logpath,prov_list)
                cleanup_dir(dicom_dir,logpath)
		bvecfile=""
		bvalfile=""
		niftipath=""
		bvecname=""
                bvalname=""
		niftiname=""
		for filename in os.listdir(dicom_dir):
                        if fnmatch.fnmatch(filename, '*.nii.gz'):
				niftipath=dicom_dir+'/'+filename
				if niftiname=="":
					niftiname=filename
			elif fnmatch.fnmatch(filename, '*.bvec'):
				bvecfile=dicom_dir+'/'+filename
				bvecname=filename
			elif fnmatch.fnmatch(filename, '*.bval'):
				bvalfile=dicom_dir+'/'+filename
				bvalname=filename
		if download == '1':
			if niftiname !="":
                        	xnatmaster.move(dicom_dir,outdir,niftiname)
                        xnatmaster.move(os.path.dirname(logpath)+'/',outdir,os.path.basename(logpath))
			if bvalname != "" and bvecname !="":	
				xnatmaster.move(dicom_dir,outdir,bvalname)
				xnatmaster.move(dicom_dir,outdir,bvecname)
                        if upload == '1':
                                xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                                niftipath = outdir+niftiname
                                logpath = outdir+os.path.basename(logpath)
				if niftiname!="":
                        	        xnatmaster.slice_it_up(niftipath,'nifti',logpath,outdir+expr_id+'_DTI_nifti_QA.png','')
                                #Do upload here
                                thetype="bbl:nifti"
                                assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                                assname=assname.replace(".","_")
                                assname=assname.replace("-","_")
				myproject=central.select('/projects/'+proj_name)
                                assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                if assessor.exists():
                                        print "Found original run..."
                                        assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
                                	assname=assname.replace(".","_")
                        		assname=assname.replace("-","_")
				        myproject=central.select('/projects/'+proj_name)
                                        assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                                xnatmaster.extract_provenance(assessor,prov_list)
				if bvecfile!="" and bvalfile!="":
					assessor.out_resource('BVEC').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bvec').put(bvecfile)
					assessor.out_resource('BVAL').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bval').put(bvalfile)
                                assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                                if niftiname !="":
					assessor.out_resource('QAIMAGE').file('1.png').put(outdir+expr_id+'_DTI_nifti_QA.png')
                                if niftiname !="":
					assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftiname)
	        elif upload == '1':
                        niftipath = dicom_dir+niftiname
                        xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                        xnatmaster.slice_it_up(niftipath,'nifti',logpath,dicom_dir+expr_id+'_mprage_nifti_QA.png','')
                        #Do upload here
                        thetype="bbl:nifti"
			myproject=central.select('/projects/'+proj_name)
                        assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                        assname=assname.replace(".","_")
                        assname=assname.replace("-","_")
			assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        if assessor.exists():
                               print "Found original run..."
                               assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
                               assname=assname.replace(".","_")
                               assname=assname.replace("-","_")
			       assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                        xnatmaster.extract_provenance(assessor,prov_list)
			if bvalfile!="" and bvecfile!="":
				assessor.out_resource('BVEC').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bvec').put(bvecfile)                                
				assessor.out_resource('BVAL').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bval').put(bvalfile)
                        assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                        assessor.out_resource('QAIMAGE').file('1.png').put(dicom_dir+expr_id+'_DTI_nifti_QA.png')
                       	if niftiname !="":	
				assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftiname)
                else:
			print "Should never have gotten here. Not doing anything. Make sure either -download 1 or -upload 1"
                        sys.exit(0)	

def epi(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
        xnatmaster.add_to_log(logpath, "Downloading EPI sequence: " + seq_id)
	prov_list = []
	niftifound = 0
	if findexisting == '1':
		xnatmaster.add_to_log(logpath, "Checking for existing Nifti - EPI sequence: " + seq_id)	
		niftifound = xnatmaster.existing_nifti(expr_id,seq_id,central)
		if niftifound > 0:
			if download == '1':
				xnatmaster.get_nifti(expr_id, seq_id, outdir, central, proj_name, subj_id)	
				xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + outdir)
			else:
				xnatmaster.get_nifti(expr_id, seq_id, tmpdir, central, proj_name, subj_id)      
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + tmpdir)
	if findexisting == '0' or str(niftifound) == '0':
		if str(niftifound) == '0':
			xnatmaster.add_to_log(logpath, "No existing Nifti - EPI sequence: " + seq_id)
		else:
			xnatmaster.add_to_log(logpath, "Forcing the creation of a new Nifti - EPI sequence: " + seq_id)
		if not xnatmaster.ensure_dir_exists(tmpdir+str(seq_id)+'_Dicoms') and xnatmaster.ensure_write_permissions(tmpdir+str(seq_id)+'_Dicoms'):
			sys.exit(0)
		dicom_dir = xnatmaster.download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir+str(seq_id)+'_Dicoms/',central)
		try:
                	values = return_needed_values(expr_id, seq_id, central)          
                	volumes = values.get('geometry_nvolumes')
                	TR = values.get('mr_tr')
        	        slices = values.get('geometry_nz')
 	                voxel_size = values.get('geometry_dz')
	        except IndexError, e:
        	        xnatmaster.add_to_log(logpath, e + ' - Stopping here for this sequence because all the neccessary stats could not be pulled from XNAT')
	
        	print_stats(volumes, TR, slices, voxel_size,logpath)

        	prov_list = runTo3d(volumes, slices, TR, dicom_dir,logpath,prov_list)
        	prov_list = timeshift(dicom_dir,logpath,prov_list)
		if oblique_okay == 1:
                	prov_list = deoblique(voxel_size, dicom_dir,logpath,prov_list)
        	prov_list = resample(dicom_dir, seqname,logpath,expr_id,prov_list)
	       	niftiname = expr_id+'_'+formname+'.nii.gz'
		cleanup_dir(dicom_dir,logpath)
	        if download == '1':
			xnatmaster.move(dicom_dir,outdir,niftiname)
			xnatmaster.move(os.path.dirname(logpath)+'/',outdir,os.path.basename(logpath))
			if upload == '1':
				print "Project is: " +  str(proj_name)
				xnatmaster.add_to_log(logpath,"Now saving into XNAT.")	
				niftipath = outdir+niftiname
				logpath = outdir+os.path.basename(logpath)
				xnatmaster.slice_it_up(niftipath,'nifti',logpath,outdir+expr_id+'_epi_nifti_QA.png','')
				#Do upload here
				thetype="bbl:nifti"
				assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
				assname=assname.replace(".","_")
                                assname=assname.replace("-","_")
				myproject=central.select('/projects/'+proj_name)
				assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
				if assessor.exists():
                                        print "Found original run..."
					assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
					assname=assname.replace(".","_")
                        	        assname=assname.replace("-","_")
					myproject=central.select('/projects/'+proj_name)
					assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname) 
				assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
				xnatmaster.extract_provenance(assessor,prov_list)
				assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
				assessor.out_resource('QAIMAGE').file('1.png').put(outdir+expr_id+'_epi_nifti_QA.png')
				assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)		
	        elif upload == '1':
			print "Project is: " + str(proj_name)
			niftipath = dicom_dir+niftiname
	                xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
			xnatmaster.slice_it_up(niftipath,'nifti',logpath,dicom_dir+expr_id+'_epi_nifti_QA.png','')
			#Do upload here
			thetype="bbl:nifti"
			myproject=central.select('/projects/'+proj_name)
                        assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
			assname=assname.replace(".","_")
			assname=assname.replace("-","_")
                        assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        if assessor.exists():
                               print "Found original run..."
                               assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
		      	       assname=assname.replace(".","_")
                               assname=assname.replace("-","_")
                               assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
			xnatmaster.extract_provenance(assessor,prov_list)
			assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)                
                        assessor.out_resource('QAIMAGE').file('1.png').put(dicom_dir+expr_id+'_epie_nifti_QA.png')                
                        assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
		else:
			print "Should never have gotten here. Not doing anything. Make sure either -download 1 or -upload 1"
			sys.exit(0)


def perfusion(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
        xnatmaster.add_to_log(logpath, "Downloading ASL sequence: " + seq_id)
        prov_list = []
        niftifound = 0
        if findexisting == '1':
                xnatmaster.add_to_log(logpath, "Checking for existing Nifti - Perfusion sequence: " + seq_id)
                niftifound = xnatmaster.existing_nifti(expr_id,seq_id,central)
                if niftifound > 0:
                        if download == '1':
                                xnatmaster.get_nifti(expr_id, seq_id, outdir, central, proj_name, subj_id)
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + outdir)
                        else:
                                xnatmaster.get_nifti(expr_id, seq_id, tmpdir, central, proj_name, subj_id)  
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + tmpdir)
        if findexisting == '0' or str(niftifound) == '0':
                if str(niftifound) == '0':
                        xnatmaster.add_to_log(logpath, "No existing Nifti - Perfusion sequence: " + seq_id)
                else:
                        xnatmaster.add_to_log(logpath, "Forcing the creation of a new Nifti - Perfusion sequence: " + seq_id)
                if not xnatmaster.ensure_dir_exists(tmpdir+str(seq_id)+'_Dicoms') and xnatmaster.ensure_write_permissions(tmpdir+str(seq_id)+'_Dicoms'):
                        sys.exit(0)
                dicom_dir = xnatmaster.download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir+str(seq_id)+'_Dicoms/',central)
                try:
                        values = return_needed_values(expr_id, seq_id, central)
                        volumes = values.get('geometry_nvolumes')
                        TR = values.get('mr_tr')
                        slices = values.get('geometry_nz')
                        voxel_size = values.get('geometry_dz')
                except IndexError, e:
                        xnatmaster.add_to_log(logpath, e + ' - Stopping here for this sequence because all the neccessary stats could not be pulled from XNAT')

                print_stats(volumes, TR, slices, voxel_size,logpath)
                prov_list = runTo3d(volumes, slices, TR, dicom_dir,logpath,prov_list)
                if oblique_okay == 1:
                        prov_list = deoblique(voxel_size, dicom_dir,logpath,prov_list)
                prov_list = resample(dicom_dir, seqname,logpath,expr_id,prov_list)
                niftiname = expr_id+'_'+formname+'.nii.gz'
                cleanup_dir(dicom_dir,logpath)
                if download == '1':
                        xnatmaster.move(dicom_dir,outdir,niftiname)
                        xnatmaster.move(os.path.dirname(logpath)+'/',outdir,os.path.basename(logpath))
                        if upload == '1':
                                xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                                niftipath = outdir+niftiname
                                logpath = outdir+os.path.basename(logpath)
                                xnatmaster.slice_it_up(niftipath,'nifti',logpath,outdir+expr_id+'_perfusion_nifti_QA.png','')
                                #Do upload here
                                thetype="bbl:nifti"
                                assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                                assname=assname.replace(".","_")
                        	assname=assname.replace("-","_")
				myproject=central.select('/projects/'+proj_name)
                                assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                if assessor.exists():
                                        print "Found original run..."
                                        assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
					assname=assname.replace(".","_")
                        		assname=assname.replace("-","_")
                                        myproject=central.select('/projects/'+proj_name)
                                        assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                                xnatmaster.extract_provenance(assessor,prov_list)
                                assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                                assessor.out_resource('QAIMAGE').file('1.png').put(outdir+expr_id+'_perfusion_nifti_QA.png')
                                assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
                elif upload == '1':
                        niftipath = dicom_dir+niftiname
                        xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                        xnatmaster.slice_it_up(niftipath,'nifti',logpath,dicom_dir+expr_id+'_perfusion_nifti_QA.png','')
                        #Do upload here
                        thetype="bbl:nifti"
			myproject=central.select('/projects/'+proj_name)
                        assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                        assname=assname.replace(".","_")
                        assname=assname.replace("-","_")
			assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        if assessor.exists():
                               print "Found original run..."
                               assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
			       assname=assname.replace(".","_")
                               assname=assname.replace("-","_")
                               assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                        xnatmaster.extract_provenance(assessor,prov_list)
                        assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                        assessor.out_resource('QAIMAGE').file('1.png').put(dicom_dir+expr_id+'_perfusion_nifti_QA.png')
                        assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
		else:
			print "Should never have gotten here. Not doing anything. Make sure either -download 1 or -upload 1"
			sys.exit(0)		

def dwi(proj_name, subj_id, expr_id, seq_id, formname, seqname, logpath, findexisting, tmpdir, download, outdir, central, upload):
        xnatmaster.add_to_log(logpath, "Downloading DTIDWI sequence: " + seq_id)
        prov_list = []
        niftifound = 0
        if findexisting == '1':
                xnatmaster.add_to_log(logpath, "Checking for existing Nifti - DWI sequence: " + seq_id)
                niftifound = xnatmaster.existing_nifti(expr_id,seq_id,central)
                if niftifound > 0:
                        if download == '1':
                                xnatmaster.get_dti_nifti(expr_id, seq_id, outdir, central, proj_name, subj_id)
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + outdir)
                        else:
                                xnatmaster.get_dti_nifti(expr_id, seq_id, tmpdir, central, proj_name, subj_id)
                                xnatmaster.add_to_log(logpath, "Downloaded existing nifti to : " + tmpdir)
        if findexisting == '0' or str(niftifound) == '0':
                if str(niftifound) == '0':
                        xnatmaster.add_to_log(logpath, "No existing Nifti - DWI sequence: " + seq_id)
                else:
                        xnatmaster.add_to_log(logpath, "Forcing the creation of a new Nifti - DWI sequence: " + seq_id)
                if not xnatmaster.ensure_dir_exists(tmpdir+str(seq_id)+'_Dicoms') and xnatmaster.ensure_write_permissions(tmpdir+str(seq_id)+'_Dicoms'):
                        sys.exit(0)
                dicom_dir = xnatmaster.download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir+str(seq_id)+'_Dicoms/',central)
                try:    
                        values = return_needed_values(expr_id, seq_id, central)
                        volumes = values.get('geometry_nvolumes')
                        TR = values.get('mr_tr')
                        slices = values.get('geometry_nz')
                        voxel_size = values.get('geometry_dz')
                except IndexError, e:
                        xnatmaster.add_to_log(logpath, e + ' - Stopping here for this sequence because all the neccessary stats could not be pulled from XNAT')
                print_stats(volumes, TR, slices, voxel_size,logpath)
                prov_list = dcm2nii(dicom_dir,logpath,prov_list)
                cleanup_dir(dicom_dir,logpath)
                bvecfile=""
                bvalfile=""
                niftipath=""
		bvecname=""
		bvalname=""
                for filename in os.listdir(dicom_dir):
                        if fnmatch.fnmatch(filename, '*.nii.gz'):
                                niftipath=dicom_dir+'/'+filename
                                niftiname=filename
                        elif fnmatch.fnmatch(filename, '*.bvec'):
                                bvecfile=dicom_dir+'/'+filename
                                bvecname=filename
                        elif fnmatch.fnmatch(filename, '*.bval'):
                                bvalfile=dicom_dir+'/'+filename
                                bvalname=filename
                if download == '1':
                        xnatmaster.move(dicom_dir,outdir,niftiname)
                        xnatmaster.move(os.path.dirname(logpath)+'/',outdir,os.path.basename(logpath))
                        if bvalname!="" and bvecname !="":
				xnatmaster.move(dicom_dir,outdir,bvalname)
                        	xnatmaster.move(dicom_dir,outdir,bvecname)
                        if upload == '1':
                                xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                                niftipath = outdir+niftiname
                                logpath = outdir+os.path.basename(logpath)
                                xnatmaster.slice_it_up(niftipath,'nifti',logpath,outdir+expr_id+'_DWI_nifti_QA.png','')
                                #Do upload here
                                thetype="bbl:nifti"
                                assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                                assname=assname.replace(".","_")
                        	assname=assname.replace("-","_")
				myproject=central.select('/projects/'+proj_name)
                                assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                if assessor.exists():
                                        print "Found original run..."
                                        assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
                                	assname=assname.replace(".","_")
                        		assname=assname.replace("-","_")
				        myproject=central.select('/projects/'+proj_name)
                                        assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                                assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                                xnatmaster.extract_provenance(assessor,prov_list)
				if bvecfile !="" and bvalfile !="":
                        	        assessor.out_resource('BVEC').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bvec').put(bvecfile)
                        	        assessor.out_resource('BVAL').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bval').put(bvalfile)
                                assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                                assessor.out_resource('QAIMAGE').file('1.png').put(outdir+expr_id+'_DWI_nifti_QA.png')
                                assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
                elif upload == '1':
			niftipath = dicom_dir+niftiname
                        xnatmaster.add_to_log(logpath,"Now saving into XNAT.")
                        xnatmaster.slice_it_up(niftipath,'nifti',logpath,dicom_dir+expr_id+'_epi_nifti_QA.png','')
                        #Do upload here
                        thetype="bbl:nifti"
			myproject=central.select('/projects/'+proj_name)
                        assname=str(expr_id) + '_' + str(formname) + '_SEQ0' + str(seq_id)  + '_RUN01'
                        assname=assname.replace(".","_")
                        assname=assname.replace("-","_")
			assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        if assessor.exists():
                               print "Found original run..."
                               assname=xnatmaster.get_new_assessor(expr_id,subj_id,formname,seq_id,proj_name,central)
			       assname=assname.replace(".","_")
                               assname=assname.replace("-","_")
                               assessor=myproject.subject(subj_id).experiment(expr_id).assessor(assname)
                        assessor.create(**{'assessors':thetype,'xsi:type':thetype,thetype+'/date':str(xnatmaster.get_today()),thetype+'/imageScan_ID':str(seq_id),thetype+'/validationStatus':'unvalidated',thetype+'/status':'completed',thetype+'/source_id':str(expr_id)+'_0',thetype+'/id':str(assname),thetype+'/PipelineDataTypeVersion':'1.0',thetype+'/PipelineScriptVersion':'3.0',thetype+'/source01':'DICOMS',thetype+'/SequenceName':formname})
                        xnatmaster.extract_provenance(assessor,prov_list)
			if bvecfile !="" and bvalfile !="":
        	                assessor.out_resource('BVEC').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bvec').put(bvecfile)
        	                assessor.out_resource('BVAL').file(str(expr_id) + '_' +formname + '_SEQ0'+seq_id+'.bval').put(bvalfile)
                        assessor.out_resource('LOG').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.log').put(logpath)
                        assessor.out_resource('QAIMAGE').file('1.png').put(dicom_dir+expr_id+'_DWI_nifti_QA.png')
                        assessor.out_resource('NIFTI').file(str(expr_id) + '_' + formname + '_SEQ0' + seq_id + '.nii.gz').put(niftipath)
                else:
                        print "Should never have gotten here. Not doing anything. Make sure either -download 1 or -upload 1"
                        sys.exit(0)	

cases = { 0 : unknown,
          1 : mprage,
          2 : dti,
          3 : epi,
          4 : perfusion,
          5 : dwi,
	  6 : dti
}

def determine_sequence_type(qluxname):
        print "SEQUENCE NAME: " + str(qluxname)
	if qluxname.lower().find('dti') > -1:
                return 2
        if qluxname.lower().find('dwi') > -1:
                return 5
	if qluxname.lower().find('bold') > -1:
                return 3
	if qluxname.lower().find('mprage_ti1110_ipat2_moco3_um')>-1:
		return 1
	if qluxname.lower().find('mprage_ti1110_ipat2_moco3_nav')>-1:
		return 6
	if qluxname.lower().find('mprage_ti1110_ipat2_moco3')>-1:
		return 1
	if qluxname.lower().find('mprage_navprotocol') > -1:
		return 6
	if qluxname.lower().find('b0map') > -1:
		return 6
	if qluxname.lower().find('ciss') >-1:
		return 6
	if qluxname.lower().find('bulb') >-1:
		return 6
        if qluxname.lower().find('mprage') > -1: 
                return 1
        if qluxname.lower().find('ep2d') > -1:
                return 4
	if qluxname.lower().find('pcasl') >-1:
		return 4
        if qluxname.lower().find('asl') > -1:
                return 4
        if qluxname.lower().find('bbl1_') > -1:
                return 3
	if qluxname.lower().find('no1back') > -1:
		return 3
        if qluxname.lower().find('pitt1_') > -1:
                return 3
        if qluxname.lower().find('t2_') > -1:
                return 1
	if qluxname.lower().find('epi_single') >-1:
		return 1
	if qluxname.lower().find('bold') > -1:
                return 3
        return 0

'''
Input Processing:
'''
parser = argparse.ArgumentParser(description='Python Pipeline Dicoms 2 Processed NiFti Action Script');

group = parser.add_argument_group('Required')
group.add_argument('-scanid', action="store", dest='scanid', required=True, help='MR Session (ScanID) of the Dicoms to Convert')
group.add_argument('-download',action="store", dest='download', required=True, help='Should this download the NifTi or just put it back into XNAT? 1 to download or 0 to not download')

optgroup = parser.add_argument_group('Optional')
optgroup.add_argument('-upload',action="store", dest='upload', required=False, help='Should this NifTi be uploaded into XNAT? 1 to upload, 0 to keep locally. Default: 0', default='0')
optgroup.add_argument('-outdir',action="store", dest='outdir', required=False, help='Name of the output directory if downloading the NiFTi', default='')
optgroup.add_argument('-tmpdir',action="store", dest='tmpdir', required=False, help='Name of the temporary directory to cache DICOMS', default='/import/monstrum/tmp/NIFTI')
optgroup.add_argument('-scantype',action="store", dest='scantype', required=False, help='Enter the type of scan, currently available options are MPRAGE, T2, DTI, DWI, EPI, ASL', default='')
optgroup.add_argument('-sequence_id',action="store", dest='sequence_id', required=False, help='Probably for internal XNAT pipeline use only', default='-1')
optgroup.add_argument('-force_unmatched',action="store", dest='force_unmatched', required=False, help='Should unmatched sequences be converted to nifti? Set as 1 to force unmatched conversion.', default='0')
optgroup.add_argument('-seqname',action="store",dest='seqname',required=False, help='What is the name of the sequence to convert? Eg. restbold, frac2back, idemo, etc.', default='-1')
optgroup.add_argument('-skip_oblique',action="store",dest='skipoblique',required=False,help='Do you want to skip a Sequence if it is oblique. 1 for yes, 0 for no. Default 1', default='1')
optgroup.add_argument('-configfile',action="store",dest='configfile',required=False, help='Enter path to your XNAT config file if desired.', default='X')
optgroup.add_argument('-check_existing',action="store",dest='findexisting',required=False,help='Just download Nifti if it already exists. 1 if yes, 0 to force a new nifti to be made.', default='1')
optgroup.add_argument('-download_example_dicom',action="store",dest='dldicom',required=False,help='Download Example dicom.', default='1')
optgroup.add_argument('-download_dicoms',action="store",dest='dlalldicoms',required=False,help='Download All Dicoms.', default='0')

parser.add_argument('-version', action='version', version='%(prog)s 3.0')
version='_d2n_v3_0'
inputArguments = parser.parse_args()
global skip_obl
logging_sessionid = inputArguments.scanid
download = inputArguments.download
outdir = inputArguments.outdir
force_unmatched = inputArguments.force_unmatched
tmpdir = inputArguments.tmpdir
sessionid=logging_sessionid
scantype = inputArguments.scantype
sid = inputArguments.sequence_id
upload = inputArguments.upload
sn = inputArguments.seqname
skip_obl = inputArguments.skipoblique
configfile = inputArguments.configfile
findexisting = inputArguments.findexisting
scanid = inputArguments.scanid
dldicom = inputArguments.dldicom
dlalldicoms = inputArguments.dlalldicoms

'''
End Input Processing:
'''
if dldicom == '1' and dlalldicoms == '1':
	print "Since Download Example Dicom is default and you selected Download All Dicoms, the download example dicom flag is being overridden"
	dldicom=0
if scantype != '' and int(sid) != -1:
        print "Got both scantype and sequence_id specified; sequence_id takes priority"
scantype = scantype.upper()

if outdir == '' and download == '1':
        sys.exit(1)

if download == '0' and upload == '0':
        print "Please specify either -download 1 and/or -upload 1, otherwise this script has no real purpose"
        sys.exit(1)

if outdir == '':
	outdir = tmpdir

scanid_array = xnatmaster.parse_scanids(scanid)

central = xnatmaster.setup_xnat_connection(configfile)

corrected_scanid_array = []

for i in range(0,len(scanid_array)):
	corrected_scanid_array.append(xnatmaster.add_zeros_to_scanid(scanid_array[i],central))
	print str(scanid_array[i]) + ' is valid.'

print corrected_scanid_array

'''
Check that we can create all neccessary files and directories 
'''
tmpdir = xnatmaster.append_slash(tmpdir)
tmpuuid = uuid.uuid4()
tmpdir = tmpdir + str(tmpuuid) + '/'
if not xnatmaster.ensure_dir_exists(tmpdir) and xnatmaster.ensure_write_permissions(tmpdir):
	sys.exit(1)

if str(download) == '1':
	outdir = xnatmaster.append_slash(outdir)
	if not xnatmaster.ensure_dir_exists(outdir) and xnatmaster.ensure_write_permissions(outdir):
        	sys.exit(1)

'''
Done creating neccessary directories
'''
global timeshifted
global oblique_okay
for i in corrected_scanid_array:
	print "Now dealing with scanid: " + str(i) + '.'
	newtmpdir = tmpdir + str(i) + '/'
	#newoutdir = outdir + str(i) + '/'
	newlogdir = newtmpdir + 'logs/'
	#if not xnatmaster.ensure_dir_exists(newoutdir) and xnatmaster.ensure_write_permissions(newoutdir) and not xnatmaster.ensure_dir_exists(newtmpdir) and xnatmaster.ensure_write_permissions(newtmpdir):
        #	sys.exit(1)
	if not xnatmaster.ensure_dir_exists(newlogdir) and xnatmaster.ensure_write_permissions(newlogdir):
        	sys.exit(1)
	tstamp = xnatmaster.do_tstamp()
	logpath = newlogdir + str(i) + str(version) + str(tstamp) + '.log'
	otherparams = '-upload ' + str(upload) + ' -download ' + str(download) + ' -outdir ' + str(outdir) + ' -tmpdir ' + str(tmpdir) + ' -scantype ' + str(scantype) + ' -sequence_id ' + str(sid) + \
 	' -force_unmatched ' + str(force_unmatched) + ' -seqname ' + str(sn) + ' -configfile ' + str(configfile) 
	xnatmaster.print_all_settings('dicoms2nifti.py',version, i, tstamp, otherparams , logpath)
	
	if force_unmatched == '0':
                matched_sequences = xnatmaster.find_matched_sequences(i,scantype,sid,sn,central) 
        elif force_unmatched == '1':
                matched_sequences = xnatmaster.find_matched_and_unmatched_sequences(i,scantype,sid,sn,central)
        else:
                matched_sequences = xnatmaster.find_matched_sequences(i,scantype,sid,sn,central)
	dicomdirectory = ""
	for line in matched_sequences:
		try:
			print line
			flagged_bad = 0
                        oblique_okay = 0
                        timeshifted = 0
			subj_id = line.get('subject_id')
                        seqname = line.get('qlux_qluxname')
                        sessid = line.get('session_id')
                        proj_name = line.get('project')
                        scandate = line.get('date')
                        seq_id = line.get('imagescan_id')
                        imgorient = line.get('mr_imageorientationpatient')
                        formname = line.get('mr_seriesdescription')
                        if formname == 'MoCoSeries':
				formname = 'ep2d_se_pcasl_PHC_1200ms_moco'
			formname = formname.replace("(","_")
			formname = formname.replace(")","_")
			formname = formname.replace(" ","_")
			nonzeroi = str(i).lstrip('0')
			nonzerosubid = str(subj_id).lstrip('0')
			newoutdir = outdir + str(nonzerosubid) + '_' + str(nonzeroi) + '/' + str(seq_id) + '_' + str(seqname)+'/nifti/'
			if dldicom == '1' or dlalldicoms == '1':
				dicomdirectory = outdir + str(nonzerosubid) + '_' + str(nonzeroi) + '/' + str(seq_id) + '_' + str(seqname)+'/dicoms/'
				xnatmaster.ensure_dir_exists(dicomdirectory)
				xnatmaster.ensure_write_permissions(dicomdirectory)
			if not xnatmaster.ensure_dir_exists(newoutdir) and xnatmaster.ensure_write_permissions(newoutdir) and not xnatmaster.ensure_dir_exists(newtmpdir) and xnatmaster.ensure_write_permissions(newtmpdir):
				sys.exit(1)
			print "Form: " + str(formname);
		except IndexError, e:
			xnatmaster.add_to_log(logpath,e)
		if skip_obl == '1' and xnatmaster.isOblique(imgorient):
                        print "Oblique Found - Stopping now on this sequence."
                        flagged_bad = 1 
                elif skip_obl =='0' and xnatmaster.isOblique(imgorient):
                        print "Oblique Found - Proceeding."
                        oblique_okay = 1
                if seqname != "" and flagged_bad == 0:  
                        mutable_sequencename = seqname
		if dlalldicoms == '1':
			xnatmaster.download_dicoms(proj_name,subj_id,i,seq_id,dicomdirectory,central)
		if dldicom == '1':
			xnatmaster.download_one_dicom(proj_name,subj_id,i,seq_id,dicomdirectory,central)
		cases[determine_sequence_type(seqname)](proj_name, subj_id, i, seq_id, formname, seqname, logpath, findexisting, newtmpdir, download, newoutdir, central, upload)
sys.exit(0)
