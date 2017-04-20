#!/import/monstrum/Applications/epd-7.1/bin/python
import sys
from pyxnat import Interface
if (len(sys.argv) > 1):
        scanid = sys.argv[1]
central = Interface(config='/import/monstrum/Users/megq/.xnat.cfg')

subject_dict = {} 
constraints12 = [('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs12 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints12);
for i in seqs12:
	subject_dict[str(i.get('session_id'))]=i.get('subject_id')

mprage_dict = {} 
constraints = [('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%mprage%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints);
for h in seqs:
	mprage_dict[str(h.get('session_id'))]=h.get('subject_id')

B0_dict = {} 
constraints2 = [('bbl:Sequence/qlux/qluxname','ilike','%B0%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs2 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints2);
for j in seqs2:
	B0_dict[str(j.get('session_id'))]=j.get('subject_id')

perf_dict = {} 
constraints3 = [('bbl:Sequence/qlux/qluxname','ilike','%pcasl_se_we%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs3 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints3);
for k in seqs3:
	perf_dict[str(k.get('session_id'))]=k.get('subject_id')

t2bulb_dict = {} 
constraints4 = [('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%t2_BULB%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs4 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints4);
for l in seqs4:
	t2bulb_dict[str(l.get('session_id'))]=l.get('subject_id')


ciss_dict = {} 
constraints5 = [('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%ciss%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs5 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints5);
for m in seqs5:
	ciss_dict[str(m.get('session_id'))]=m.get('subject_id')

dwi_dict = {} 
constraints6 = [('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%dwi%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs6 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints6);
for n in seqs6:
	dwi_dict[str(n.get('session_id'))]=n.get('subject_id')

dti_dict = {} 
constraints7 = [('bbl:Sequence/QLUX_MATCHED','=','1'),'AND',('bbl:Sequence/qlux/qluxname','ilike','%DTI%'),'AND',('bbl:Sequence/PROJECT','=','ONM_816275')]
seqs7 = central.select('bbl:Sequence',['bbl:Sequence/QLUX_QLUXNAME','bbl:Sequence/IMAGESCAN_ID','bbl:Sequence/SUBJECT_ID', 'bbl:Sequence/imageSession_ID', 'bbl:Sequence/date', \
         'bbl:Sequence/PROTOCOL', 'bbl:Sequence/PROJECT','bbl:Sequence/MR_SERIESDESCRIPTION']).where(constraints7);
for o in seqs7:
	dti_dict[str(o.get('session_id'))]=o.get('subject_id')


print "subject,mprage,B0,perf,t2bulb,ciss,dwi,dti,bblid"

for p in subject_dict.keys():
	if mprage_dict.has_key(p):
		x=1
	else:
		x=0
	if B0_dict.has_key(p):
		y=1
	else:
		y=0
	if perf_dict.has_key(p):
		z=1
	else:
		z=0
	if t2bulb_dict.has_key(p):
		w=1
	else:
		w=0
	if ciss_dict.has_key(p):
		v=1
	else:
		v=0
	if dwi_dict.has_key(p):
		a=1
	else:
		a=0
	if dti_dict.has_key(p):
		b=1
	else:
		b=0
	print str(p)+","+str(x)+","+str(y)+","+str(z)+","+str(w)+","+str(v)+","+str(a)+","+str(b)+","+str(subject_dict[p]) 


	
