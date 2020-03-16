#!/bin/env python3
# -*- coding: utf8 -*-
import os
task = open("task.txt", 'r', encoding='utf8')
appid1 = ["sb4Byw1tZ1w40mxWHRUxAXRqkG5xs9Qp", "-oN-sAYVHTkKkIJfWqitu-A2KVC4HQhF"]
appid2 = ["1DDCthBdeHsHdpl1VfUSc2xdcLnc2vh5", "0xc8oFtZYgsvW699EdoLl-tSg1tp8yRT"]
appid3 = ["lvOp5HoHLRi2OvjD-vkFCr6zLcLmvnaN", "wefnGz441EklE5vCbI4y1-Wbw2PdZF6q"]
appid4 = ["Pne6MDRMyGaKmHcBJYS6S_8w1GjNaKYF"]
while 1:
    line = task.readline()
    if not line:
        break
    else:
        line = ''.join(line).strip('\n')
        count = 0
        for fn in os.listdir(line):
            count = count+1
        print(line, count)
        os.system("python3 tinyImages.py -i %s -a %s -r" % (line, appid1[1]))
task.close()