#
from pyxnat import Interface
from nipype.interfaces import fsl
import gzip
import datetime
import time
import json
import StringIO
import re
import os
import fnmatch
import shutil
import string
import sys
import argparse
import getpass
import gzip
import subprocess
import smtplib

def unpack(s):                                                                  
#### UNZIP DCMS AND NIFTI FROM XNAT       
	if (s.find('.tar.gz') != -1):                   
                os.system("tar -xvvzf " + s)           
        elif (s.find('.tar.bz2') != -1):               
                os.system("tar -xvvjf " + s)        
        elif (s.find('.tar') != -1):               
                os.system("tar -xvvf " + s)
        elif (s.find('.gz') != -1):
                os.system("gunzip -f " + s)                        
        elif (s.find('.zip') != -1):            
                os.system("unzip " + s)
        else: print "Wrong archive or filename" 

def unpack_dir(s):
#### UNZIP DCMS AND NIFTI FROM XNAT       
        print "Unpacking dcm.gz's from " + str(s) 
	os.system("gunzip -f " + s + "*.gz" )

def ensure_dir_exists(dir): 
#### RETURNS TRUE IF PATH EXISTS OR WAS CREATED
	if not os.path.exists(dir):
		try:
			os.makedirs(dir)
			return 1
		except OSError:
			sys.exit(1)
	else:
		return 1
	
def ensure_write_permissions(dir): 
#### RETURNS TRUE IF PATH HAS WRITE PERMISSIONS
	if os.access(dir, os.W_OK):
		return 1
	else:
		return 0 
	
def check_for_valid_scanid(scanid,central): 
#### RETURNS A VALUE GREATER THAN 0 IF SCANID EXISTS
	constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND']
	seqs = central.select('bbl:Sequence',['bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/QLUX_MATCHED', 'bbl:Sequence/date', 'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT']).where(constraints);
	subj_id = 0
	for line in seqs:
		try:
			subj_id = line.get('subject_id')
			if subj_id > 0:
				print "Found subjectid of: " + subj_id
				return subj_id
			else:
				return 0
		except IndexError, e:
			pass

def check_run_by_pipeline(): 
#### RETURNS TRUE IF HOST AND USER ARE XNAT
	if  os.getenv('HOSTNAME') == 'xnat.uphs.upenn.edu' and getpass.getuser()=='xnat':	
		print "Pipeline mode"
        	return 1
	else:
        	print "Non-pipeline mode"
        	return 0

def setup_xnat_connection(configfile): 
#### SETS UP AND RETURNS XNAT CONNECTION
	run_by_pipeline = check_run_by_pipeline()
	homedir = os.getenv("HOME")
	hostname = os.getenv('HOSTNAME')
	if configfile=='X' and run_by_pipeline == 1:
	        configfile='/import/monstrum/Users/xnat/.xnat-localhost.cfg'
  	   	central = Interface(config=configfile)
		return central
	elif hostname == 'xnat.uphs.upenn.edu' and run_by_pipeline == 0:
		if os.path.isfile(homedir+'/.xnat-localhost.cfg'):
                        print "Found ~/.xnat-localhost.cfg on xnat"
                        central = Interface(config=homedir+'/.xnat-localhost.cfg')
                        return central
		else:
        	        print "Login using your XNAT username and password, this will be saved in a configuration file for next time."
        	        try:
               	        	central = Interface(config=configfile)
                	except AttributeError:
                        	central = Interface(server='http://localhost:8080/xnat')
                        	central.save_config(homedir+'/.xnat-localhost.cfg')
			return central
	elif configfile == 'X' and run_by_pipeline == 0:
                if os.path.isfile(homedir+'/.xnat.cfg'):
                        print "Found ~/.xnat.cfg"
                        central = Interface(config=homedir+'/.xnat.cfg')
                        return central
		else:
                        print "Login using your XNAT username and password, this will be saved in a configuration file for next time."
                        try:
                                central = Interface(config=configfile)
                        except AttributeError:
                                central = Interface(server='https://xnat.uphs.upenn.edu/xnat')
                                central.save_config(homedir+'/.xnat.cfg')
                        return central
	else:
        	try:
               		central = Interface(config=configfile)
        	except AttributeError, e:
                	print "Error with the configfile you specified: " + str(e)
                	sys.exit(1)
	return central

def do_tstamp(): 
####RETURNS A PRETTY PRECISE TIMESTAMP
	FORMAT = '%Y%m%d%H%M%S'
	tstamp = datetime.datetime.now().strftime(FORMAT)
	print "Started on: " + str(tstamp)
	return tstamp

def get_today(): 
####RETURNS YYYY-MM-DD FORMAT FOR PROVENANCE
	FORMAT = '%Y-%m-%d'
	today = datetime.datetime.now().strftime(FORMAT)
	return today

def add_zeros_to_scanid(scanid,central): 
####ADDS ZEROS TO SCANID IF NECCESSARY
	if check_for_valid_scanid(scanid,central):
                return scanid
        elif check_for_valid_scanid("0"+scanid,central):
                scanid="0"+scanid
		return scanid
        elif check_for_valid_scanid("00"+scanid,central):
                scanid="00"+scanid
    		return scanid
	else:
                print "Couldn't find Session with scanid: " + scanid
                sys.exit(1)

def append_slash(dir): 
####ADDS A SLASH IF USER FORGOT ONE
	if not str(dir).endswith('/'):
                return str(dir) + '/'	
	else:
		return str(dir)

def add_to_log(logpath, txt): 
####PUTS ANY TEXT INTO THE SPECIFIED LOGFILE
	print txt
	logfile = open(logpath,'a')
	logfile.write(str(txt)+'\r\n')
	logfile.close()

def create_log(fullpath): 
####CREATES SPECIFIED LOGFILE
	logfile = open(fullpath,'w')
	logfile.write('\r\n')
	logfile.close()
	if not os.path.isfile(fullpath):
		print "Could not create log at " + fullpath
		sys.exit(1)
	else:
		print "Log created at " + fullpath
		return 1

def print_all_settings(scriptname, scriptversion, scanid, tstamp, otherparameters, logpath): 
####FORMATS AND PRINTS LOGFILE PROVENANCE INFO
	verbose_log = str(scriptname) + ' ' + str(scriptversion) + ' run at ' + str(tstamp) + ' on host: ' + str(os.getenv('HOSTNAME')) + ' with scanid ' + \
	str(scanid) + ' and other options: ' + otherparameters
	if not os.path.isfile(logpath):
		create_log(logpath)
	add_to_log(logpath, verbose_log)

def parse_scanids(scanids):
####PARSES A COMMA SEPARATED LIST OF SCANIDS TO RETURN ARRAY
	scanid_array = scanids.split(',')
	for i in range(0,len(scanid_array)):
		print scanid_array[i]
	return scanid_array

def get_new_assessor(scanid,subj_id,formname,seq_id,proj,central):
####RETURNS A NEW ASSESSOR NAME FOR MULTIPLE RUNS      
	myproject=central.select('/projects/'+proj)
        for i in range(2,20):
                hex= scanid + '_' + formname + '_SEQ0' + seq_id + '_RUN0'+str(i)
                assessor=myproject.subject(subj_id).experiment(scanid).assessor(hex);
                if assessor.exists():
                        pass
                else:
                        return hex 
        sys.exit(0)

def extract_provenance(assessor,prov_list2):
####PUTS PROVENANCE INTO ASSESSOR	
	for i in prov_list2:
                prov = {'program':i.get('program'),
		        'timestamp':i.get('timestamp'),
                        'user':i.get('user'),
                        'machine':i.get('machine'),
                        'compiler':i.get('compiler'),
                        'platform':i.get('platform'),
                        'program_version':i.get('program_version'),
                        'program_arguments':i.get('program_arguments'),
		        }
		assessor.provenance.set(prov)	

def return_bblid_from_scanid(scanid,central):
	seqs = central.select('xnat:mrSessionData',['xnat:mrSessionData/SUBJECT_ID']).where([('xnat:mrSessionData/SESSION_ID','=',str(scanid)),'AND'])
	for line in seqs:
		bblid = line['subject_id']
		return bblid

def return_project_from_scanid(scanid,central):
	seqs = central.select('xnat:mrSessionData',['xnat:mrSessionData/PROJECT']).where([('xnat:mrSessionData/SESSION_ID','=',str(scanid)),'AND'])
	for line in seqs:
		project = line['project']
		return project

def track_provenance(prov_list2,program,program_version,program_arguments):
####ADDS TO A LIST OF PROVENANCES	
	prov = {'program':program,
	        'timestamp':get_today(),
 	        'user':getpass.getuser(),
       		'machine':os.getenv('HOSTNAME'),
        	'compiler':'lx24-amd64',
        	'platform':'RHEL_Linux_64bit',
        	'program_version':program_version,
        	'program_arguments':program_arguments,
		}
	prov_list2.append(prov)
	return prov_list2

def find_matched_sequences(scanid,scantype,seq_id, sname,central):
####RETURNS XNAT LIST OF QLUXMATCHED SEQUENCES BY SEQUENCE_ID, SCANTYPE, OR SCANNAME
        if str(sname) == '-1' and scantype == '' and str(seq_id) == "-1":
                print "Finding all matched sequences."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%_nav'),'AND']
        elif str(sname) != "-1":
                print "Finding only sequences named " + str(sname)
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike',"%"+str(sname)+"%"),'AND', \
		('bbl:Sequence/qlux/qluxname','not like','pcasl%moco'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%_nav'),'AND']
        elif str(seq_id) != "-1":
                print "Finding only sequence : " + seq_id + " if it is matched."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/IMAGESCAN_ID','=',str(seq_id)),'AND', \
		('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND'] 
        elif scantype == 'DTI' or scantype == 'DWI'  or scantype == 'MPRAGE' or scantype == 'T2' or scantype == 'EPI' or scantype == 'ASL':
                print "Finding only " + scantype
                if scantype == "DWI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DWI%'),'AND']
                if scantype == "DTI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DTI%'),'AND']
                if scantype == "ASL":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%ep2d%'),'AND', \
			('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND' ]
                if scantype == "MPRAGE":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%mprage%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%_nav'),'AND']
                if scantype == "T2":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%t2_%'),'AND']
                if scantype == "EPI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',[('bbl:Sequence/qlux/qluxname','ilike','%bbl1%'),'OR', \
			('bbl:Sequence/qlux/qluxname','ilike','%pitt1%'),'OR',('bbl:Sequence/qlux/qluxname','ilike','%BOLD%'),'OR']]
        else:
                print "Cannot determine scantype from your input. See --help."
                sys.exit(1)
        seqs = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
	 'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION','bbl:Sequence/MR_IMAGEORIENTATIONPATIENT']).where(constraints);
        return seqs

def find_matched_and_unmatched_sequences(scanid,scantype,seq_id, sname, central):
####FINDS MATCHED AND NONMATCHED SEQUENCES BY SEQID, SCANTYPE, OR SCANNAME
        if scantype == '' and str(seq_id) == "-1":
                print "Finding all matched and unmatched sequences."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND']
                print constraints
        elif str(seq_id) != "-1":
                print "Finding only sequence : " + seq_id + " if it is matched or unmatched."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/IMAGESCAN_ID','=',str(seq_id)),'AND',('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND']
        elif scantype == 'DTI' or scantype == 'DWI' or scantype == 'MPRAGE' or scantype == 'T2' or scantype == 'EPI' or scantype == 'ASL':
                print "Finding only " + scantype
                if scantype == "DWI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DWI%'),'AND']
                if scantype == "DTI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DTI%'),'AND']
                if scantype == "ASL":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','ilike','%ep2d%'),'AND',('bbl:Sequence/qlux/qluxname','not like','pcasl%moco%'),'AND']
                if scantype == "MPRAGE":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','ilike','%mprage%'),'AND',('bbl:Sequence/qlux/qluxname','not like','%MPRAGE_NAVprotocol%'),'AND']
                if scantype == "T2":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','ilike','%t2_%'),'AND']
                if scantype == "EPI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',[('bbl:Sequence/qlux/qluxname','ilike','%bbl1%'),'OR', ('bbl:Sequence/qlux/qluxname','ilike','%pitt1%'),'OR']]
        else:
                print "Cannot determine scantype from your input. See --help."
                sys.exit(1)
        seqs = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
	 'bbl:Sequence/PROTOCOL', 'bbl:Sequence/QLUX_MATCHED', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION','bbl:Sequence/MR_IMAGEORIENTATIONPATIENT']).where(constraints);
        return seqs

def existing_nifti(scanid, seq_id, central):
####CHECK FOR EXISTING NIFTI
	print "Checking for an already existing nifti with scanid "  + str(scanid) + ', sequence id ' + str(seq_id) 
	F = central.select('bbl:nifti',['bbl:nifti/EXPT_ID','bbl:nifti/imageScan_ID']).where([('bbl:nifti/SESSION_ID', '=', scanid),'AND',('bbl:nifti/imageScan_ID','=',str(seq_id)),'AND'])
	return len(F)

def get_dti_nifti(scanid, seq_id, outdir, central, proj, subj):
####GET NIFTI AND BVEC/BVAL IF THEY EXIST
	print "Downloading existing nifti with scanid " + str(scanid) + ', sequence id ' + str(seq_id) + ', to ' + str(outdir)
        G = central.select('bbl:nifti',['bbl:nifti/EXPT_ID']).where([('bbl:nifti/SESSION_ID', '=', scanid),'AND',('bbl:nifti/imageScan_ID','=',str(seq_id)),'AND'])
        name = ""
        for line in G:
                name = line.get('expt_id')
                print name
        if name != "":
                path = '/projects/'+proj+'/subjects/'+subj+'/experiments/'+scanid+'/assessors/'+name+'/out_resources/files'
                print path
                F = central.select(path)
                for line2 in F:
                        if line2._uri.find('nii') >-1  or line2._uri.find('bvec') >-1 or line2._uri.find('bval') >-1:
                                print line2._urn
                                line2.get(outdir+line2._urn)
                          #      return 1
		return 1
        else:
                print "Something went wrong with getting nifti."
        return 1

def get_nifti(scanid, seq_id, outdir, central, proj, subj):
####GET NIFTI IF IT EXISTS
	print "Downloading existing nifti with scanid " + str(scanid) + ', sequence id ' + str(seq_id) + ', to ' + str(outdir)
	G = central.select('bbl:nifti',['bbl:nifti/EXPT_ID']).where([('bbl:nifti/SESSION_ID', '=', scanid),'AND',('bbl:nifti/imageScan_ID','=',str(seq_id)),'AND'])
	name = ""
	for line in G:
		#print line
		print line
		name = line.get('expt_id')
		print name
	if name != "": 
		path = '/projects/'+proj+'/subjects/'+subj+'/experiments/'+scanid+'/assessors/'+name+'/out_resources/files'
		print path
		F = central.select(path)
		for line2 in F:
			if line2._uri.find('nii')>-1:
				#print line2
				print line2._urn
				line2.get(outdir+line2._urn)
				a = { 'niftipath':outdir+line2._urn , 'fromname' : name }
				return a
	else:
		print "Something went wrong with getting nifti."
	return 1

def download_dicoms_by_dir(proj_name,subj_id,expr_id,seq_id,tmpdir,central):
####DOWNLOAD DICOMS AND UNZIP WHOLE DIR
        print "Downloading Dicoms with scanid " + str(expr_id) + ', sequence id ' + str(seq_id) + ', to ' + str(tmpdir)
        download_rest='/projects/' + proj_name + '/subjects/' + subj_id + '/experiments/' + expr_id + '/scans/' + seq_id + '/resources/DICOM/files'
        try:
                f = central.select(download_rest)
                for i in f:
                        i.get(tmpdir+i._urn)
         	unpack_dir(tmpdir)       
		return tmpdir
        except IndexError, e:
                pass

def download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir,central):
####DOWNLOAD DICOMS
#	print "Testing!!"
	print "Downloading Dicoms with scanid " + str(expr_id) + ', sequence id ' + str(seq_id) + ', to ' + str(tmpdir)
	#time.sleep(20)
	#return tmpdir
	download_rest='/projects/' + proj_name + '/subjects/' + subj_id + '/experiments/' + expr_id + '/scans/' + seq_id + '/resources/DICOM/files'
	print str(download_rest)
	try:
                f = central.select(download_rest)
        	for i in f:
			print str(tmpdir) + str(i._urn)
			i.get(tmpdir+i._urn)
			unpack(tmpdir+i._urn)
		return tmpdir
	except IndexError, e:
                pass	

def download_one_dicom(proj_name,subj_id,expr_id,seq_id,tmpdir,central):
####DOWNLOAD DICOMS
        print "Downloading 1 Dicom with scanid " + str(expr_id) + ', sequence id ' + str(seq_id) + ', to ' + str(tmpdir)
        download_rest='/projects/' + proj_name + '/subjects/' + subj_id + '/experiments/' + expr_id + '/scans/' + seq_id + '/resources/DICOM/files'
        try:
                f = central.select(download_rest)
                for i in f:
	             i.get(tmpdir+i._urn)
	             unpack(tmpdir+i._urn)
                     return tmpdir
        except IndexError, e:
                pass

def run_process(inputstr,logpath):
####START A NEW PROCESS NOT COVERED BY NIPY
	proc = subprocess.Popen('/bin/bash',
               cwd = os.getcwd(),
               stdin = subprocess.PIPE,
               stdout = subprocess.PIPE,
               stderr = subprocess.PIPE)
	out, err = proc.communicate(inputstr)
	add_to_log(logpath,inputstr)
	add_to_log(logpath,out)
	add_to_log(logpath,err)	

def move(frompath,topath,filename):
####MOVE A FILE AND WRITE ABOUT IT
	print "Now moving: " + frompath+filename + ' to: ' + topath+filename
	shutil.copyfile(frompath+filename,topath+filename)

def slice_it_up(input,input_type,logpath,outfile,arguments): 
####INVOKE SLICER FOR QA PURPOSES
        slice = fsl.Slicer()
        slice.inputs.in_file = input
        if input_type == 'mprage_nifti':
                slice.inputs.image_width = 1200
		slice.inputs.sample_axial = 7 
        	slice.inputs.out_file = outfile
		res = slice.run()
		add_to_log(logpath, "Sliced at : " + outfile)
	elif input_type == 'nifti':
                slice.inputs.image_width = 800
                slice.inputs.all_axial = True
        	slice.inputs.out_file = outfile
        	res = slice.run()
		add_to_log(logpath, "Sliced at : " + outfile)
	
def isOblique(imgorient):
####CHECK IF IMAGE IS OBLIQUE FROM XNAT
        print "Checking obliqueness " + str(imgorient)
        S=imgorient.split('\\')
        A=round(float(S[0]),4)
        B=round(float(S[1]),4)
        C=round(float(S[2]),4)
        D=round(float(S[3]),4)
        E=round(float(S[4]),4)
        F=round(float(S[5]),4)  
        up=round(float('0.0002'),4)
        down=round(float('0.9800'),4)
        realdown=round(float('-0.0002'),4)
        realup=round(float('1.0002'),4) 
        if A > up and A < down or A < realdown or A > realup :  
                print "oblique found " + str(A)
                return 1
        elif B > up and B < down or B < realdown or B > realup :
                print "oblique found " + str(B)
                return 1
        elif C > up and C < down or C < realdown or C > realup :
                print "oblique found " + str(C)
                return 1
        elif D > up and D < down or D < realdown or D > realup :
                print "oblique found " + str(D)
                return 1
        elif E > up and E < down or E < realdown or E > realup : 
                print "oblique found " + str(E)
                return 1
        elif F > up and F < down or F < realdown or F > realup :
                print "oblique found " + str(F)
                return 1 
        else:
                return 0

def existing_bias(scanid, seq_id, central):
####CHECK FOR EXISTING BIAS
        print "Checking for an already existing BIAS with scanid "  + str(scanid) + ', sequence id ' + str(seq_id)
        F = central.select('bbl:biascorrection',['bbl:biascorrection/EXPT_ID']).where([('bbl:biascorrection/SESSION_ID', '=', scanid),'AND',('bbl:biascorrection/imageScan_ID','=',str(seq_id)),'AND'])
        return len(F)



def existing_bet(scanid, seq_id, central):
####CHECK FOR EXISTING BET
        print "Checking for an already existing BET with scanid "  + str(scanid) + ', sequence id ' + str(seq_id)
        F = central.select('bbl:bet',['bbl:bet/EXPT_ID','bbl:bet/imageScan_ID']).where([('bbl:bet/SESSION_ID', '=', scanid),'AND',('bbl:bet/imageScan_ID','=',str(seq_id)),'AND'])
        return len(F)

def get_bias(scanid, seq_id, outdir, central, proj, subj):
####GET BIAS IF IT EXISTS
        print "Downloading existing BIAS with scanid " + str(scanid) + ', sequence id ' + str(seq_id) + ', to ' + str(outdir)
        G = central.select('bbl:biascorrection',['bbl:biascorrection/EXPT_ID']).where([('bbl:biascorrection/SESSION_ID', '=', scanid),'AND',('bbl:biascorrection/imageScan_ID','=',str(seq_id)),'AND'])
        name = ""
        for line in G:
        #       print line
                name = line.get('expt_id')
                print name
        if name != "":
                path = '/projects/'+proj+'/subjects/'+subj+'/experiments/'+scanid+'/assessors/'+name+'/out_resources/files'
                print path
                F = central.select(path)
                for line2 in F:
                        if line2._uri.find('nii')>-1:
                                #print line2
                                print line2._urn
                                line2.get(outdir+line2._urn)
                                a = { 'biaspath':outdir+line2._urn , 'fromname' : name }
                                return a
        else:   
                print "Something went wrong with getting bias."
        return 1

def get_bet(scanid, seq_id, outdir, central, proj, subj):
####GET BET IF IT EXISTS
        print "Downloading existing BET with scanid " + str(scanid) + ', sequence id ' + str(seq_id) + ', to ' + str(outdir)
        G = central.select('bbl:bet',['bbl:bet/EXPT_ID']).where([('bbl:bet/SESSION_ID', '=', scanid),'AND',('bbl:bet/imageScan_ID','=',str(seq_id)),'AND'])
        name = ""
        for line in G:
        #       print line
                name = line.get('expt_id')
                print name
        if name != "":
                path = '/projects/'+proj+'/subjects/'+subj+'/experiments/'+scanid+'/assessors/'+name+'/out_resources/files'
                print path
                F = central.select(path)
		gotmask = 0
		gothead = 0
		a={}
                for line2 in F:
                        if line2._uri.find('nii')>-1 and line2._uri.find('mask')>-1:
                                #print line2
                                print line2._urn
                                line2.get(outdir+line2._urn)
        			a['betmask'] = outdir+line2._urn
				a['fromname'] = name
				gotmask = 1
			elif line2._uri.find('mask') < 0 and line2._uri.find('log') < 0 and line2._uri.find('png') < 0:
				print line2._urn
                                line2.get(outdir+line2._urn)
				a['betpath'] = outdir+line2._urn
                                a['fromname'] = name
				gothead = 1
			if gotmask == 1 and gothead == 1:
				return a
	else:
                print "Something went wrong with getting bet."
        return 1
