#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.3.4
Urlreader Module

Creator: Harrygiel
"""

import re, requests
from bs4 import BeautifulSoup

from modules.BotModule import BotModule

class Urlreader(BotModule):
    """ Class: Urlreader Module Class"""
    def __init__(self, parent):
        super(Urlreader, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        msg = self.argument[1]
        target = self.argument[2]
        raw_regexp = r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)'
        my_link = re.search(raw_regexp, msg)
        if my_link is not None:
            url = my_link.group(0)
            if url.startswith("http") is False:
                url = "http://" + url
            headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
            page = requests.get(url, headers=headers)
            soup = BeautifulSoup(page.text, "lxml")
            my_title = soup.title
            if my_title is not None:
                self.c.privmsg(self.argument[2], "URL: {:.200s}".format(my_title.text.strip('\r').strip('\n')))
        return None
