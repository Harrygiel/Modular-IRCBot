#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Youtube Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys, re, urllib
from BeautifulSoup import BeautifulSoup

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
                url = urllib.urlopen(my_link.group(0)).read().decode('utf-8')
                soup = BeautifulSoup(url, convertEntities=BeautifulSoup.HTML_ENTITIES)
                my_title = soup.find(id="eow-title")
                if my_title is not None:
                    my_title = my_title.find(text=True)
                    self.c.privmsg(self.argument[2], "Youtube: " + ''.join(my_title[5:-3]))
        return None
