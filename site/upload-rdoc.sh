#! /bin/sh

BFILE=/tmp/urdoc-$$
trap "rm -f $FILE" 0
cp /dev/null $BFILE

find rdoc/ -type d | grep -v \\.svn | \
    (while read dir ; do echo "-mkdir $dir" >> $BFILE ; done)
find rdoc/ -type f | grep -v \\.svn | \
    (while read file ; do echo "-put $file $file" >> $BFILE ; done)
cat $BFILE
sftp -b $BFILE  coar@rubyforge.org:/var/www/gforge-projects/bitstring/