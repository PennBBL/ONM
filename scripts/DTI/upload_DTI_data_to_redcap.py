import redcap
import csv
import pandas as pd

project = redcap.Project('https://banshee.uphs.upenn.edu/redcap_v6.1.2/API/', '35428CEDDECC45882ED0DBDB93EFB85E','p1',False)

#DTI QA
csvdf=pd.DataFrame.from_csv('/import/monstrum/ONM/group_results/DTI/ONM_qa_results.txt',header=0,sep=' ',index_col=0)
response = project.import_records(csvdf)
print response
