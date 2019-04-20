#!/bin/bash
export LANG=en_US.UTF-8

cat << EOF

usage:
./build.sh git_branch build_type [mail_group]

build_type: [FaceShop | FaceShopED | FaceShopER | FaceShopST]
mail_group: [develop | product]

example:
./build.sh Devolop FaceShop develop

EOF

if [ "$#" -lt 2 ]; then
	echo "wrong paramters count, exit"
    exit
fi

git_branch=$1
build_type=$2

mail_group=$3
if [ -z $3 ]; then
	mail_group='develop'
fi

echo ${mail_group}

# working path
pushd `dirname $0` > /dev/null
working_path=`pwd`
popd > /dev/null

cd ${working_path}

# git
git reset --hard
git clean -dxf
git pull
git checkout ${git_branch}
git pull origin ${git_branch}

# log
git_log=`git --no-pager log --pretty=format:"%an%x09%ad%x09%s" --date=format:'%m/%d %H:%M' --after="yesterday"`
echo "●●●●●●●●●●●●●●●●●●●●  git_log:  ●●●●●●●●●●●●●●●●●●●●"
echo "${git_log}"

# pod
sh ./update_pods.sh

# unlock keychain
LOGIN_KEYCHAIN=~/Library/Keychains/login.keychain
LOGIN_PASSWORD=`cat ~/app_builder/scripts/ios/local_password.txt`
security unlock-keychain -p ${LOGIN_PASSWORD} ${LOGIN_KEYCHAIN}

# build
fastlane build git_branch:${git_branch} build_type:${build_type} mail_group:${mail_group}

