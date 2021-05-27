#!/bin/bash

#/Users/mac/ossutilmac64
#/Applications/LibreOffice.app/Contents/MacOS/soffice

# $1 wenku $2 一级目录 $3 二级目录 $4 带后缀的文件名 $5 文件名
# 1.从oss获取文件
/ossutil64 cp oss://bucket/$1/$2/$3/$4 $4
# 2.把文件转成pdf，然后把PDF转成图片
soffice --invisible --headless --nologo --convert-to pdf --outdir $(pwd) $4
pdftocairo -jpeg $5.pdf

# 3.把多张图片合成一张，并上传到oss
convert -append $(ls *.jpg|head -3) $5.jpg
# 重新命名，计算md5
md5=`md5sum $5.jpg | awk '{ print $1 }'`
/ossutil64 cp $5.jpg oss://bucket/$1/$2/$3/$md5.jpg
rm $4 *.jpg

echo $md5
