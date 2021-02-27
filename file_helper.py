#!/usr/bin/env python
# -*- coding: utf-8 -*-
# coding: utf-8
import requests
import os
import sys
defaultencoding = 'utf-8'

if sys.getdefaultencoding() != defaultencoding:
    reload(sys)
    sys.setdefaultencoding(defaultencoding)
    
token = "your token"
base = "http://dsm.flutter.fit"

save_path = (os.path.split(os.path.realpath(__file__))[0] + "/wechat_file/").encode("utf-8")

def report(file):
    url = base + "/file/report?token="+token + "&file_id=" + str(file['id'])
    data = requests.get(url = url).json()
    if data['code']==1:
        print("download success:" + save_path + file['file_name'].encode("utf-8"))

def download(file):
    print("downloading:"+file['file'])
    url = file['file']
    data = requests.get(url = url)
    if not os.path.exists(save_path):
        os.makedirs(save_path)
    if data.status_code == 200:
        with open(save_path + file['file_name'].encode("utf-8"),"wb") as code:
            code.write(data.content)
        report(file)
    else:
        print("download failed")


if __name__ == "__main__":
    url = base + '/file/files?token='+token
    response = requests.get(url = url).json()
    if response['code']==1 :
        if len(response['data']) == 0:
        	print("no file to download")
        for file in response['data']:
            download(file)