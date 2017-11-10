#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Compliment Module

Creator: MemePasMoi
"""

import sys, requests
from bs4 import BeautifulSoup

sys.path.append('module')
from BotModule import BotModule


class Compliement(BotModule):
    """ Class: Compliment Module Class"""
    def __init__(self, parent, default_module_node):
        super(Compliement, self).__init__(parent, default_module_node)

    def get_compliment(self):
        try:
            link = "http://insultes.gromweb.com/generateur-d-insultes"
            headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
            page = requests.get(link, headers=headers, verify=False)
            soup = BeautifulSoup(page.text, "lxml").find("div", {"class": "phrasing_content"}).contents
            if len(soup[1]) > 0:
                return str(soup[1]).replace("<p>", '').replace("</p>", "")
            else:
                return ""
        except:
            return ""

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if len(splited_msg) < 2 or sender in splited_msg[1]:
            compliment_msg = "{%.20s} ==> " + self.get_compliment()
            self.c.privmsg(target, compliment_msg.format(splited_msg[1]))
            return
        else:
           compliment_msg = self.get_compliment()
           self.c.privmsg(target, compliment_msg)
           return
