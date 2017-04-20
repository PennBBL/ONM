#!/import/monstrum/Applications/epd-7.1/bin/python
from pyxnat import Interface
#from nipype.interfaces import fsl
import getpass
import gzip
import os
import sys
scanid = sys.argv[1]
outdir = sys.argv[2]
def find_matched_sequences(scanid,scantype,seq_id, sname,central):
####RETURNS XNAT LIST OF QLUXMATCHED SEQUENCES BY SEQUENCE_ID, SCANTYPE, OR SCANNAME
        if str(sname) == '-1' and scantype == '' and str(seq_id) == "-1":
                print "Finding all B0 sequences."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/qlux/qluxname','like','%B0%'),'AND']
        elif str(sname) != "-1":
                print "Finding only sequences named " + str(sname)
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike',"%"+str(sname)+"%"),'AND', \
                ('bbl:Sequence/qlux/qluxname','not like','%moco%'),'AND']
        elif str(seq_id) != "-1":
                print "Finding only sequence : " + seq_id + " if it is matched."
                constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/IMAGESCAN_ID','=',str(seq_id)),'AND', \
                ('bbl:Sequence/qlux/qluxname','not like','%moco%'),'AND'] 
        elif scantype == 'DTI' or scantype == 'DWI'  or scantype == 'MPRAGE' or scantype == 'T2' or scantype == 'EPI' or scantype == 'ASL':
                print "Finding only " + scantype
                if scantype == "DWI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DWI%'),'AND']
                if scantype == "DTI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DTI%'),'AND']
                if scantype == "ASL":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%ep2d%'),'AND', \
                        ('bbl:Sequence/qlux/qluxname','not like','%moco%'),'AND' ]
                if scantype == "MPRAGE":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%mprage%'),'AND']
                if scantype == "T2":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%t2_%'),'AND']
                if scantype == "EPI":
                        constraints = [('bbl:Sequence/imageSession_ID', '=', str(scanid)),'AND',('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',[('bbl:Sequence/qlux/qluxname','ilike','%bbl1%'),'OR', \
                        ('bbl:Sequence/qlux/qluxname','ilike','%pitt1%'),'OR']]
        else:
                print "Cannot determine scantype from your input. See --help."
                sys.exit(1)
        seqs = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION','bbl:Sequence/MR_IMAGEORIENTATIONPATIENT']).where(constraints);
        return seqs

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


def download_dicoms(proj_name,subj_id,expr_id,seq_id,tmpdir,central):
####DOWNLOAD DICOMS
      
	print "Downloading Dicoms with scanid " + str(expr_id) + ', sequence id ' + str(seq_id) + ', to ' + str(tmpdir)
        download_rest='/projects/' + proj_name + '/subjects/' + subj_id + '/experiments/' + expr_id + '/scans/' + seq_id + '/resources/DICOM/files'
        try:
                f = central.select(download_rest)
        	print str(download_rest)
	        for i in f:
			print "f: " + str(f)
			print "i: " + str(i)
			print str(tmpdir+i._urn)
                        if not os.path.isfile(str(tmpdir+i._urn)) and not os.path.isfile(str(tmpdir+i._urn).split(".gz")[0]):
				i.get(tmpdir+i._urn)
                        	unpack(tmpdir+i._urn)
			else:
				print str(tmpdir+i._urn) + " Already exists, Ain't nobody got time for recreating that."
                return tmpdir
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


central = setup_xnat_connection("X") 
scanid = add_zeros_to_scanid(scanid,central)
matched_sequences = find_matched_sequences(scanid,"","-1","-1",central)
if not str(outdir).endswith('/'):
	outdir = outdir+'/'
if str(outdir)=="" or not ensure_dir_exists(outdir) or not ensure_write_permissions(outdir):
	print "Please give appropriate outdir as second argument"
	sys.exit(0)
for line in matched_sequences:
        try:
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
                print "Form: " + str(formname)
		newdir = outdir + str(seq_id) + '_'  + str(seqname) + '/'
		if not ensure_dir_exists(newdir) or not ensure_write_permissions(newdir):
        		print "Error writing to disk"
			sys.exit(0)
		newdir = newdir + 'dicoms/'
		if not ensure_dir_exists(newdir) or not ensure_write_permissions(newdir):
                        print "Error writing to disk"
                        sys.exit(0)
		download_dicoms(proj_name,subj_id,scanid,seq_id,newdir,central)
        except IndexError, e:
                xnatmaster.add_to_log(logpath,e)

