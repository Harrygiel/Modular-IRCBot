#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
Dictionary Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys

sys.path.append('module')
from BotModule import BotModule


class Ko(BotModule):
    """ Class: Ko Module Class"""
    def __init__(self, parent, default_module_node):
        super(Ko, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        self.c.privmsg(target, "" + sender.nick + " donne un coup sec sur la tête de " + msg[4:] + " ! La chute est violente, c'est un KO !")
