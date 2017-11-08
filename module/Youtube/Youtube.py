#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
Youtube Module

Creator: Harrygiel
"""

import sys, re, requests
from bs4 import BeautifulSoup

sys.path.append('module')
from BotModule import BotModule

class Youtube(BotModule):
    """ Class: Youtube Module Class"""
    def __init__(self, parent, default_module_node):
        super(Youtube, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        msg = self.argument[1]
        if msg.find("www.youtube.com/") != -1 or msg.find("youtu.be/") != -1:
            raw_regexp = r'http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&amp;?[\w\?=]*)?'
            my_link = re.search(raw_regexp, msg)
            if my_link is not None:
                headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
                page = requests.get(my_link.group(0), headers=headers)
                soup = BeautifulSoup(page.text, "lxml")
                my_title = soup.find(id="eow-title")
                if my_title is not None:
                    my_title = my_title.find(text=True)
                    self.c.privmsg(self.argument[2], "Youtube: " + ''.join(my_title[5:-3]))
        return None
