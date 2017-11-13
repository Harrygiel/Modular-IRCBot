#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
The Module

Creator: Harrygiel, MemePasMoi
"""

import random, sys

sys.path.append("modules")
from BotModule import BotModule

class The(BotModule):
    """ Class: The Module Class"""
    def __init__(self, parent):
        super(The, self).__init__(parent)
        self.The_msg_list_duo = ["{:.20s} offre un thé vert bien chaud à {:.20s}",
                                 "{:.20s} apporte un thé noir tout chaud à {:.20s}",
                                 "{:.20s} offre un thé bien chaud à {:.20s}. Thé vert, thé noir ?"]

        self.The_msg_list_solo = ["{:.20s} s'offre un thé vert bien chaud",
                                  "{:.20s} s'apporte un thé noir tout chaud",
                                  "{:.20s} s'offre un thé bien chaud. Thé vert, thé noir ?"]

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
            self.c.privmsg(target, random.choice(self.The_msg_list_duo).format(sender.nick, splited_msg[1]))
            return

        else:
            self.c.privmsg(target, random.choice(self.The_msg_list_solo).format(sender.nick))
            return
