#!/bin/sh

#  Script.sh
#  autoResign
#
#  Created by 曹培 on 2019/5/20.
#  Copyright © 2019 曹培. All rights reserved. admin@caopei.cn.

# Resign the given application


# 命令格式【sh resign.sh "cat " "profileName" "iPhone Developer: qianpu gao (RJ5KWURJ6G)" "udid"】
# function cp_resign {


	echo ""
	echo "==========  - 0 - 准备  ==========" 
	# 重签名工程根目录	【/Users/cp/Project/autoResign】
	SRCROOT_DIR=$(pwd)
	echo "重签名工程根目录: $SRCROOT_DIR"

	# .ipa文件路径	【/Users/cp/Project/autoResign/IPA/aaa.ipa】
	IPA_NAME="$1"
	IPA_DIR="${SRCROOT_DIR}/IPA"
	echo ".ipa文件路径: $IPA_DIR/$1.ipa"

	# 动态库文件路径		【/Users/cp/Project/autoResign/DYLIB/bbb.frameworks】
	IPA_DYLIB="${SRCROOT_DIR}/DYLIB"
	echo "动态库文件路径: $IPA_DYLIB"

	# 描述文件路径		【/Users/cp/Project/autoResign/PROVISION/bbb.mobileprovision】
	PROVISION_NAME="$2"
	PROVISION_DIR="${SRCROOT_DIR}/PROVISION"
	echo "描述文件路径: $PROVISION_DIR/$2.mobileprovision"
	
	# adHoc证书名称	【iPhone Developer: Louise Fletcher (XJ9782SXQ4)】
	CERTIFICATE_INFO="$3"
	echo "adHoc证书名称: $CERTIFICATE_INFO"

	# 用户名称	【b57aba0ec39fd3299f80cf5b8cdcfa16f751f095】
	USER_NAME="udid-${4}"
	echo "用户【UDID】: $USER_NAME"


	echo ""
	echo "==========  - 1 - 创建目标文件夹  =========="
	TARGET_DIR="${SRCROOT_DIR}/TARGET/$PROVISION_NAME/$USER_NAME/$IPA_NAME"
	mkdir -p $TARGET_DIR
	echo "✅ 创建目标文件夹: $TARGET_DIR"


	echo ""
	echo "==========  - 2 - 创建临时工作空间  =========="
	WORKSPACE="${SRCROOT_DIR}/TEMP/$PROVISION_NAME/$USER_NAME/$IPA_NAME"
	APP_PATH="$WORKSPACE/Payload/$IPA_NAME.app"
	APP_DYLIB="$APP_PATH/DYLIB"
	APP_FRAMEWORKS="$APP_PATH/Frameworks"
	APP_PLUGINS="$APP_PATH/PlugIns"
	mkdir -p $WORKSPACE
	echo "✅ 创建临时工作空间: $WORKSPACE"

	# 1.1 解压IPA到临时工作空间
	unzip -oqq "$IPA_DIR/$IPA_NAME.ipa" -d "$WORKSPACE"
	echo "✅ 解压 .ipa 至临时工作空间"

	# 1.2 拷贝描述文件到临时工作空间
	cp -rf "$PROVISION_DIR/$PROVISION_NAME.mobileprovision" "$WORKSPACE/$PROVISION_NAME.mobileprovision"
	echo "✅ 拷贝描述文件到临时工作空间"


    echo ""
    echo "==========  - 3 - 注入 动态库文件  =========="
    if [ ! -d "$IPA_DYLIB" ]
    then
        echo "❌ 未发现需注入的动态库文件"

    else
        for framework in "$IPA_DYLIB"/*
        do
            if [[ ! -d "$framework" ]]
            then
                echo "❌ 未发现需注入的动态库文件"

            else
                # 转移动态库
                # 找到 IPA_DYLIB 下的 .framework 和 .dylib 文件
                if [[ "$framework" == *.framework || "$framework" == *.dylib ]]
                then
                    # dylib=$(basename $framework)
                    dylib=${framework##*/}
                    dylib_name=${dylib%.*}
                    # echo $APP_DYLIB/$dylib/$dylib_name
                    echo "✅ 发现需注入的动态库: $dylib/$dylib_name"
                    if [[ ! -d $APP_DYLIB ]]
                    then
                        mkdir -p $APP_DYLIB
                    fi

                    # 拷贝动态库文件 .app 内
                    cp -rf $framework $APP_DYLIB/$dylib
                    
                    # 往 Info.plist 里注入当前所属开发者账号信息
                    /usr/libexec/PlistBuddy -c "Add :AppleAccount string $PROVISION_NAME" $APP_PATH/info.plist
                    /usr/libexec/PlistBuddy -c "Add :AppleUDID string $USER_NAME" $APP_PATH/info.plist
                    echo "✅ 往 Info.plist 里注入当前所属开发者账号信息: $PROVISION_NAME"

                    # 注入动态库
                    /usr/local/bin/insert_dylib "$APP_DYLIB/$dylib/$dylib_name" "$APP_PATH/$IPA_NAME" --all-yes
                    mv "$APP_PATH/$IPA_NAME""_patched" "$APP_PATH/$IPA_NAME" 
                    /usr/bin/install_name_tool -change "$APP_DYLIB/$dylib/$dylib_name" @executable_path/DYLIB/$dylib/$dylib_name "$APP_PATH/$IPA_NAME"

                    echo "✅ 注入动态库文件: $dylib/$dylib_name"
                  fi 
            fi
        done
    fi


    echo ""
    echo "==========  - 4 - 重签名 Frameworks 文件夹  =========="
    if [ -d "$APP_FRAMEWORKS" ];
    then
        echo "Resigning embedded frameworks using certificate: '$CERTIFICATE_INFO'"
        # 遍历 Framework 文件夹
        for framework in "$APP_FRAMEWORKS"/*
        do
            # 找到 APP_FRAMEWORKS 下的 .framework 和 .dylib 文件
            if [[ "$framework" == *.framework || "$framework" == *.dylib ]]
            then
                # 重签名
                /usr/bin/codesign -fs "$CERTIFICATE_INFO" "$framework"
            else
                echo "Ignoring non-framework: $framework"
            fi
        done
    fi
    echo "✅ 重签名 Frameworks 文件夹"


    echo ""
    echo "==========  - 5 - 重签名 Plugins 文件夹  =========="
    if [[ -d "$APP_PLUGINS" ]];
    then
        echo "Resigning embedded frameworks using certificate: '$CERTIFICATE_INFO'"
         # 遍历 Plugins 文件夹
        for plugin in "$APP_PLUGINS"/*
        do
            # 找到 APP_PLUGINS 下的 .appex 文件
            if [[ "$plugin" == *.appex ]]
            then
                # 重签名
                /usr/bin/codesign -fs "$CERTIFICATE_INFO" "$plugin"
            else
                echo "Ignoring non-plugin: $plugin"
            fi
        done
    fi
    echo "✅ 重签名 Plugins 文件夹"


    echo ""
    echo "==========  - 6 - 重签名 DYLIB 文件夹  =========="
    if [[ -d "$APP_DYLIB" ]];
    then
        echo "Resigning embedded frameworks using certificate: '$CERTIFICATE_INFO'"
        # 遍历 DYLIB 文件夹
        for framework in "$APP_DYLIB"/*
        do
            # 找到 APP_DYLIB 下的 .framework 和 .dylib 文件
            if [[ "$framework" == *.framework || "$framework" == *.dylib ]]
            then
                # 重签名
                /usr/bin/codesign -fs "$CERTIFICATE_INFO" "$framework"
            else
                echo "Ignoring non-framework: $framework"
            fi
        done
    fi
    echo "✅ 重签名 DYLIB 文件夹"


    echo ""
    echo "==========  - 7 - 重签名根目录其它 MachO 文件  =========="
    for obj in "$APP_PATH"/*
    do
        if [[ "$obj" == *.framework || "$obj" == *.dylib || "$obj" == *.appex ]]
        then
            # 重签名
            /usr/bin/codesign -fs "$CERTIFICATE_INFO" "$obj"
        fi
    done
    echo "✅ 重签名根目录其它 MachO 文件"


    echo ""
    echo "==========  - 8 - 构造授权文件  =========="
    # 从描述文件中提取授权文件
    /usr/bin/security cms -D -i "$WORKSPACE/$PROVISION_NAME.mobileprovision" > "$WORKSPACE/temp.plist"
    /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' "$WORKSPACE/temp.plist" > "$WORKSPACE/entitlements.plist"
    echo "✅ 从描述文件中提取授权文件"


    echo ""
    echo "==========  - 9 - 重签名app包  =========="
    # 3.1 拷贝描述文件到.app文件夹内
    cp -rf "$WORKSPACE/$PROVISION_NAME.mobileprovision" "$APP_PATH/embedded.mobileprovision"
    echo "✅ 拷贝描述文件到.app文件夹内"

    # 3.2 拷贝授权文件到.app同级目录
    cp -rf "$WORKSPACE/entitlements.plist" "$WORKSPACE/Payload/entitlements.plist"
    echo "✅ 拷贝授权文件到.app同级目录"

    # 3.3 重签名
    /usr/bin/codesign -fs "$CERTIFICATE_INFO" --entitlements $WORKSPACE/Payload/entitlements.plist $APP_PATH
    echo "✅ 重签名app包"

    # 3.4 删除.app同级目录下的授权文件
    rm -rf "$WORKSPACE/Payload/entitlements.plist"
    echo "✅ 删除.app同级目录下的授权文件"

    # 3.5 压缩成目标.ipa文件
    cd "$WORKSPACE"
    echo "开始压缩......"
    zip -r "$IPA_NAME.ipa" "Payload"
    echo "✅ 压缩成目标.ipa文件"

    # 3.6 转移目标.ipa文件到目标路径
    cp -rf "$WORKSPACE/$IPA_NAME.ipa" "$TARGET_DIR/$IPA_NAME.ipa"
    echo "✅ 转移目标.ipa文件到目标路径"


    echo ""
    echo "==========  - 10 - 清理工作空间  =========="
    # 清理工作空间
    rm -rf "$WORKSPACE"
    echo "✅ 清理工作空间"
# }
