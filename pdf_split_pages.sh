#!/bin/bash

if [ "x" == "x$1" ] ; then
  echo "Must give pdf file name" >&2
  exit 1
fi
filename=$1

if [ "x" == "x$2" ] ; then
  echo "Must say number of pages" >&2
  exit 1
fi
num_pages=$2

base=`echo $filename | sed 's/.pdf$//'`

if [ ! -d $base ] ; then
  mkdir $base
fi

for i in `seq 1 $num_pages`; do 
  gs -sDEVICE=pdfwrite -sOutputFile=$base/$base-$i.pdf -dFirstPage=$i -dLastPage=$i -dNOPAUSE -dBATCH $filename
done

# END
