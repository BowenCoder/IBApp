#!/bin/bash
#指定libwebP的版本号
version=${1:-1.0.0}
#cocoaPods master中的git地址
oldSource="https://chromium.googlesource.com/webm/libwebp"
#替换为Github上的新地址
newSource="https://github.com/webmproject/libwebp.git"

echo -e '\033[36mFinding the path, please wait for a moment... \033[0m'

path=$(find ~/.cocoapods/repos/master -iname libwebp)
path=$path"/"$version"/libwebp.podspec.json"

if [ ! -f $path ];then
	echo -e '\033[31mError:libwebp.podspec does not exist. Please check the path:'$path '\033[0m'
else 
	oldSource=${oldSource//\//\\/}
	newSource=${newSource//\//\\/}
	sed -i '' 's/'$oldSource'/'$newSource'/g' $path
	echo -e '\033[32mOPERATION SUCCESS. \033[0m'
fi


<<!
 **********************************************************
 * Filename      : webp.sh
 * Description   : 自动替换cocoaPods中master下的webp仓库git地址
 * *******************************************************
!
