#!/bin/sh

#  xcodebuild.sh

cd ../

#计时
SECONDS=0

#取当前时间字符串添加到文件结尾
now=$(date +"%Y%m%d%H%M%S")

# 获取 setting.plist 文件路径
configPath=./Xcodebuild/Config.plist

# 项目名称
project_name=$(/usr/libexec/PlistBuddy -c "print project_name" ${configPath})

# 项目路径
project_path=$(/usr/libexec/PlistBuddy -c "print project_path" ${configPath})

# 项目版本
project_version=$(/usr/libexec/PlistBuddy -c "print project_version" ${configPath})

# 打包配置plist文件路径 (初始化)
options_path=$(/usr/libexec/PlistBuddy -c "print options" ${configPath})

# scheme名称
scheme_name=$(/usr/libexec/PlistBuddy -c "print scheme" ${configPath})

# 发布地址：蒲公英->pgyer，苹果->APPStore, fir.im->fir
platform=$(/usr/libexec/PlistBuddy -c "print platform" ${configPath})

# 配置打包样式：Release/ad-hoc/Debug/自定义(Enterprise)
configuration=$(/usr/libexec/PlistBuddy -c "print configuration" ${configPath})

# ipa包名称：项目名+版本号+打包类型
ipa_name=$(/usr/libexec/PlistBuddy -c "print scheme" ${configPath})

# ipa包路径
ipa_path="${HOME}/Desktop/ipa/${now}-V${project_version}-${platform}"

# 上传到蒲公英设置
pgyer_user=$(/usr/libexec/PlistBuddy -c "print pgyer_user" ${configPath})
pgyer_api=$(/usr/libexec/PlistBuddy -c "print pgyer_api" ${configPath})
pgyer_pwd=$(/usr/libexec/PlistBuddy -c "print pgyer_pwd" ${configPath})

# 上传fir.im 设置
fir_token=$(/usr/libexec/PlistBuddy -c "print fir_token" ${configPath})

# 开发者账号
apple_account=$(/usr/libexec/PlistBuddy -c "print apple_account" ${configPath})

# 开发者密码
apple_password=$(/usr/libexec/PlistBuddy -c "print apple_password" ${configPath})

# workspace/xcodeproj 路径(根据项目是否使用cocoapod,确定打包的方式)
if [ -d "./${project_name}.xcworkspace" ];then # 项目中存在workspace
    workspace_path="${project_path}/${project_name}.xcworkspace"
else # 项目中不存在 workspace
    workspace_path="${project_path}/${project_name}.xcodeproj"
fi

# 编译build路径
archive_path="${ipa_path}/${ipa_name}.xcarchive"

echo '=============正在清理工程============='
xcodebuild clean -configuration ${configuration} -quiet || exit
echo '=============清理已经完成============='

echo "=======正在编译工程：$configuration======="

# 通过workspace方式打包
if [ -d "./${project_name}.xcworkspace" ];then # 项目中存在workspace
    xcodebuild archive -workspace ${workspace_path} -scheme ${scheme_name} \
-configuration ${configuration} \
-archivePath ${archive_path} -quiet || exit
else #通过xcodeproj 方式打包
    xcodebuild archive -project ${workspace_path} -scheme ${scheme_name} \
    -configuration ${configuration} \
    -archivePath ${archive_path} -quiet || exit
fi

# 检查是否编译成功(build)
if [ -d "$archive_path" ] ; then
    echo '=============项目编译成功============='
else
    echo '=============项目编译失败============='
    exit 1
fi

echo '=============开始ipa打包============='

xcodebuild -exportArchive -archivePath ${archive_path} \
-configuration ${configuration} \
-exportPath ${ipa_path} \
-exportOptionsPlist ${options_path} \
-allowProvisioningUpdates \
-quiet || exit

if [ -e ${ipa_path}/${ipa_name}.ipa ]; then
    echo '=============ipa包导出成功============='
    open $ipa_path
else
    echo '=============ipa包导出失败============'
    exit 1
fi

echo '=============开始发布ipa包============='

if [ ${platform} == "APPStore" ];then # 发布到APPStore
    echo '发布ipa包到 =============APPStore============='
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${ipa_path}/${ipa_name}.ipa -u ${apple_account} -p ${apple_password} -t ios --output-format xml
"$altoolPath" --upload-app -f ${ipa_path}/${ipa_name}.ipa -u ${apple_account} -p ${apple_password} -t ios --output-format xml

if [ $? = 0 ];then
    echo "=============提交AppStore成功 ============="
else
    echo "=============提交AppStore失败 ============="
fi

elif [ ${platform} == "pgyer" ];then # 发布到蒲公英平台
    echo '发布ipa包到 =============蒲公英平台============='
    curl -F "file=@${ipa_path}/${ipa_name}.ipa" -F "uKey=${pgyer_user}" -F "_api_key=${pgyer_api}" -F "password=${pgyer_pwd}" https://www.pgyer.com/apiv1/app/upload

    if [ $? = 0 ];then
        echo "\n=============提交蒲公英成功 ============="

        echo "=============发送消息到钉钉 ============="
        curl 'https://oapi.dingtalk.com/robot/send?access_token=f9ffa7a606603c5001086561dc1340cf16328162a99395ef1662ad7184f58b17' \
        -H 'Content-Type: application/json' \
        -d '
        {"msgtype": "text",
        "text": {
            "content": "iOS新包 https://www.pgyer.com/assassin 密码：123456"
        },
        "at": {
            "atMobiles": [
            "18949171251"
            ],
            "isAtAll": false
        }
    }'

    if [ $? = 0 ];then
        echo "\n=============消息发送到钉钉成功 ============="
    else
        echo "\n=============消息发送到钉钉失败 ============="
    fi

else
    echo "=============提交蒲公英失败 ============="
fi

elif [ ${platform} == "fir" ];then # 发布到fir.im 平台
    echo '发布ipa包到 =============fir.im平台============'
    # 需要先在本地安装 fir 插件,安装fir插件命令: gem install fir-cli
    fir login -T ${fir_token}              # fir.im token
    fir publish  ${ipa_path}/${ipa_name}.ipa

    if [ $? = 0 ];then
        echo "=============提交fir.im成功 ============="
    else
        echo "=============提交fir.im失败 ============="
    fi
else # 未配置发布地址
    echo "=============未发布 ipa包(打包方式:$configuration) 到任何平台============="
fi

# 输出总用时
echo "执行耗时: ${SECONDS}秒"

exit 0


















