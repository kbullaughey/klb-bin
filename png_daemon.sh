#!/bin/bash

while [ 1 ] ; do
   files=`ls ~/tmp/topng/*.tiff`
   if [ "x$files" != "x" ] ; then
      for f in $files; do 
         newname=`echo $f | sed 's/tiff/png/g'`
         convert $f $newname
         rm $f
         height=`identify $newname | cut -f 3 -d " " | sed 's/[0-9]*x//'`
         width=`identify $newname | cut -f 3 -d " " | sed 's/x[0-9]*//'`
         heightfac=$((height*100/300))
         widthfac=$((width*100/800))
         echo "height=$height, width=$width, heightfac=$heightfac, widthfac=$widthfac"
         if [ $heightfac -gt $widthfac ]; then
            if [ $heightfac -gt 100 ] ; then
               small=`echo $f | sed 's/\.tiff/-sm.png/g'`
               convert -resize x300 $newname $small
            fi
         else 
            if [ $widthfac -gt 100 ] ; then
               small=`echo $f | sed 's/\.tiff/-sm.png/g'`
               convert -resize 800x $newname $small
            fi
         fi
      done
   fi
   sleep 2
done
