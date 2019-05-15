# encoding: utf-8
"""
File:       make_adhoc
Author:     bowen
Date:       2017/01/12 17:57
Desc:
"""

import sys
from os import path
import qrcode
sys.path.append("/Users/appbuilder/app_builder/build_result/ios")
import install_enterprise

WEB_ROOT_PATH                  = 'https://x.x.x.x:8888/ios/'
CA_CERT_PATH                   = 'https://x.x.x.x:8888/tools/certificate/self_ca.cer'
APP_BUNDLE_ID                  = 'com.bowen.shop'
APP_BUNDLE_ID_ADHOC            = 'com.bowen.shop'
APP_BUNDLE_ID_ENTERPRISE       = 'com.bowen.trivia.enterprise'
IS_ENTERPRISE                  = False
MANIFEST_FILE_NAME             = 'manifest.plist'
ADHOC_PAGE_NAME                = 'install.html'
QR_IMAGE_NAME                  = 'qr_addr.png'

MANIFEST_TEMPLATE              = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>{IPA_URL}</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>{BUNDLE_ID}</string>
				<key>bundle-version</key>
				<string>{BUNDLE_VERSION}</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>{TITLE}</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
"""

ADHOC_HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>{TITLE}</title>
        <style>
            h1 {{
                text-align: center;
            }}
            p {{
                text-align: center;
            }}
            .round-button {{
                display:block;
                height:80px;
                width:360px;
                line-height:80px;
                border: 2px solid #f5f5f5;
                border-radius: 10px;
                color:#f5f5f5;
                text-align:center;
                text-decoration:none;
                background: #464646;
                box-shadow: 0 0 3px gray;
                font-size:40px;
                font-weight:bold;
                margin: auto;
            }}
            .round-button:hover {{
                background: #262626;
            }}
        </style>
    </head>
    <body>
        <h1>{MESSAGE}</h1>
        <p><img src="{QR_NAME}"><br></p>
        <p><a href="itms-services://?action=download-manifest&url={MANIFEST_URL}" class="round-button">点击安装</a></p>
        <p><a href="{CA_CER_URL}">首次进入点此安装证书</a></p>
    </body>
</html>
"""

def make_manifest(local_root_path, package_folder, ipa_name, bundle_version):
    ipa_url = path.join(WEB_ROOT_PATH, package_folder, ipa_name)
    title = ""
    if IS_ENTERPRISE :
        title = 'shop企业包安装'
        APP_BUNDLE_ID = APP_BUNDLE_ID_ENTERPRISE
    else:
        title = 'shop Ad-Hoc包安装'
        APP_BUNDLE_ID = APP_BUNDLE_ID_ADHOC

    content = MANIFEST_TEMPLATE.format(IPA_URL=ipa_url, BUNDLE_ID=APP_BUNDLE_ID, BUNDLE_VERSION=bundle_version, TITLE=title)

    manifest_path = path.join(local_root_path, package_folder, MANIFEST_FILE_NAME)
    with open(manifest_path, 'w') as output:
        output.write(content)

def make_qrcode_image(local_root_path, package_folder):
    page_addr = path.join(WEB_ROOT_PATH, package_folder, ADHOC_PAGE_NAME)
    image = qrcode.make(page_addr)
    image_addr = path.join(local_root_path, package_folder, QR_IMAGE_NAME)
    image.save(image_addr)

def make_adhoc_html(local_root_path, package_folder, ipa_name,ft_name):
    ipa_type = ""
    if IS_ENTERPRISE :
        ipa_type = 'shop企业版'
    else:
        ipa_type = 'shop Ad-Hoc 版'

    title = '{0}</p>{1}'.format(ipa_type, ipa_name)
    manifest_url = path.join(WEB_ROOT_PATH, package_folder, MANIFEST_FILE_NAME)

    content = ADHOC_HTML_TEMPLATE.format(TITLE=ipa_type, MESSAGE=title, MANIFEST_URL=manifest_url, QR_NAME=QR_IMAGE_NAME, CA_CER_URL=CA_CERT_PATH)
    html_path = path.join(local_root_path, package_folder, ADHOC_PAGE_NAME)

    with open(html_path, 'w') as output:
        output.write(content)

    if IS_ENTERPRISE:
        image_url = path.join(WEB_ROOT_PATH, package_folder, QR_IMAGE_NAME)
        install_enterprise.make_adhoc_html(local_root_path,ft_name,title,image_url,manifest_url)

if __name__ == '__main__':
    argvs = sys.argv
    if len(argvs) < 5:
        raise  Exception('wrong params count!')

    local_root_path = argvs[1]
    package_folder  = argvs[2]
    ipa_name        = argvs[3]
    bundle_version  = argvs[4]
    ft_name         = argvs[5]

    print ipa_name
    if 'enterprise' in ipa_name:
        IS_ENTERPRISE = True
    else:
        IS_ENTERPRISE = False

    make_manifest(local_root_path, package_folder, ipa_name, bundle_version)
    make_qrcode_image(local_root_path, package_folder)
    make_adhoc_html(local_root_path, package_folder, ipa_name,ft_name)
