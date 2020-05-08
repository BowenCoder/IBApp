#!/bin/bash
#指定libwebP的版本号
version=${1:-1.0.3}
#cocoaPods master中的git地址
oldSource="https://chromium.googlesource.com/webm/libwebp"
#替换为Github上的新地址
newSource="https://github.com/webmproject/libwebp.git"

echo -e 'Finding the version('$version') path, please wait for a moment...'

path=$(find ~/.cocoapods/repos/master/Specs/1/9/2/ -iname libwebp)
path=$path"/"$version"/libwebp.podspec.json"

if [ ! -f $path ];then
	echo -e 'Error:libwebp.podspec does not exist. Please check the path:'$path ''
else 
	oldSource=${oldSource//\//\\/}
	newSource=${newSource//\//\\/}
	sed -i '' 's/'$oldSource'/'$newSource'/g' $path
	echo -e 'OPERATION SUCCESS.'
fi


<<!
 **********************************************************
 * Filename      : webp.sh
 * Description   : 自动替换cocoaPods中master下的webp仓库git地址
 * *******************************************************
!
