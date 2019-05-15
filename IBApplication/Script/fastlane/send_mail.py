# encoding: utf-8
"""
File:       make_adhoc
Author:     bowen
Date:       2017/01/12 17:57
Desc:
"""

import sys
import time
from smtplib import SMTP
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

FT_NAME_DIC = {
    'architecture':'重构拆分',
    'bpc':'基础产品中心',
    'boc':'内容与商业化中心',
    'cbc':'内容与商业化中心',
    'game':'游戏直播',
    'sdk':'音视频团队',
    'test':'QA团队',
    'master':'主版仓库',
    'build_automation':'自动构建调试',
    'video':'短视频团队',
    'city':'城市频道',
}

BUILD_TYPE_DIC = {
    'bowen':'线上环境',
    'bowen_test':'测试环境',
    'bowen_enterprise':'企业版线上环境',
    'bowen_enterprise_test':'企业版测试环境',
    'bowen_store':'应用商店',
}

def send_mail(config):
    print 'Sending Mail...'

    message = MIMEMultipart()
    message["Accept-Charset"] = "ISO-8859-1,utf-8"
    message['From'] = config['from']

    msgto = ''
    for addr in config['to']:
        msgto += addr
        msgto += ','

    print msgto

    message['To'] = msgto
    message['Reply-To'] = config['from']
    message['Subject'] = config['subject']
    message['Date'] = time.ctime(time.time())
    message['X-Priority'] = '3'
    message['X-MSMail-Priority'] = 'Normal'
    print message['Date']
    if config['text']:
        text = MIMEText(config['text'], _charset="utf-8")
        print text
        message.attach(text)

    print 'Logining...'
    smtp = SMTP()
    smtp.connect(config['server'], config['port'])
    smtp.starttls()
    smtp.login(config['username'], config['password'])
    print 'Login OK'

    print 'Sending...',
    smtp.sendmail(config['from'], config['to'], message.as_string())
    print 'Send Mail OK'

    smtp.quit()
    time.sleep(1)

def send_mail_by_client_build(mail_subject, mail_msg, recivers):
    send_mail({
        'server': 'mail.bowen.cn',
        'port': 25,
        'username': 'bowen\\client_build',
        'password': 'buzhidao',
        'from': "client_build@bowen.cn",
        'to': recivers,
        'subject': mail_subject,
        'text': mail_msg,
        }
    )

def send_mail_to_some(some, title, message):
    recivers = some.split(',')

    send_mail_by_client_build(title, message, recivers)

def send_mail_to_test(title, message):
    recivers = [
        '1214569257@qq.com',
    ]

    send_mail_by_client_build(title, message, recivers)

def send_mail_to_product(title, message):
    recivers = [
        'bpccpyy@bowen.cn',
        'jccpzx@bowen.cn',
    ]

    send_mail_by_client_build(title, message, recivers)


def send_mail_to_develop(title, message):
    recivers = [
        'ios@bowen.cn',
        'zlbz@bowen.cn',
    ]

    send_mail_by_client_build(title, message, recivers)

def send_mail_to_ent(title, message):
    recivers = [
        'bpccpyy@bowen.cn',
        'jccpzx@bowen.cn',
    ]

    send_mail_by_client_build(title, message, recivers)

def send_mail_to_debug(title, message):
    recivers = [
        '1214569257@qq.com',
    ]

    send_mail_by_client_build(title, message, recivers)

def make_title(ft_name, build_type):
    return 'iOS | {0} | {1}'.format(ft_name, build_type)

def make_message(ft_name, git_branch, build_type, adhoc_url, local_url, git_log):
    template = '''
来自:{FT_NAME}
分支:{GIT_BRANCH}
类型:{BUILD_TYPE}

下载地址:
{ADHOC_URL}

内网共享:
afp://x.x.x.x
用户名/密码:buzhidao
路径:{LOCAL_PATH}

使用说明:
https://x.x.x.x/ClientDev/sharing/wiki/iOS构建机使用说明

更新日志:
{GIT_LOG}
'''

    message = template.format(FT_NAME=ft_name, GIT_BRANCH=git_branch, BUILD_TYPE=build_type, ADHOC_URL=adhoc_url, LOCAL_PATH=local_url, GIT_LOG=git_log)
    return message

if __name__ == '__main__':
    argvs = sys.argv
    if len(argvs) < 8:
        raise  Exception('wrong params count!')

    adhoc_url   = argvs[1]
    local_url   = argvs[2]
    git_log     = argvs[3]
    ft_name     = argvs[4]
    git_branch  = argvs[5]
    build_type  = argvs[6]
    mail_group  = argvs[7]

    ft_name = FT_NAME_DIC[ft_name]
    build_type = BUILD_TYPE_DIC[build_type]
    title = make_title(ft_name, build_type)

    message = make_message(ft_name, git_branch, build_type, adhoc_url, local_url, git_log)

    if mail_group == 'product':
        send_mail_to_product(title, message)
    elif mail_group == 'develop':
        send_mail_to_develop(title, message)
    elif mail_group == 'enterprise':
        send_mail_to_ent(title, message)
    elif mail_group == 'test':
        send_mail_to_test(title, message)
    else:
        send_mail_to_some(mail_group, title, message)
