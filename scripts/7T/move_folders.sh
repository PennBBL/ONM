for i in /import/monstrum/ONM/7T/data_analysis/[0-9]*

do 

echo $i

id=`echo $i | cut -d "/" -f7`

echo $id

mkdir /import/monstrum/ONM/7T/data_analysis/"$id"

cp -r $i/DR /import/monstrum/ONM/7T/data_analysis/"$id"
cp -r $i/PR /import/monstrum/ONM/7T/data_analysis/"$id"

done
