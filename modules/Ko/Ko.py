#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Dictionary Module

Creator: Harrygiel
"""

import sys

sys.path.append("modules")
from BotModule import BotModule

class Ko(BotModule):
    """ Class: Ko Module Class"""
    def __init__(self, parent):
        super(Ko, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        self.c.privmsg(target, "" + sender.nick + " donne un coup sec sur la tête de " + msg[4:] + " ! La chute est violente, c'est un KO !")
