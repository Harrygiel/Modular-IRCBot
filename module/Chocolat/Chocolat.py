#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Chocolat Module

Creator: Harrygiel, MemePasMoi
"""

import sys

sys.path.append('module')
from BotModule import BotModule
import random


class Chocolat(BotModule):
    """ Class: Chocolat Module Class"""
    def __init__(self, parent, default_module_node):
        super(Chocolat, self).__init__(parent, default_module_node)
        self.Chocolat_msg_list_duo = ["{:.20s} apporte un chocolat bien chaud et crémeux à {:.20s}",
                                      "{:.20s} fait chauffer un bon chocolat chaud pour {:.20s}"]

        self.Chocolat_msg_list_solo = ["{:.20s} se sers un chocolat bien chaud et crémeux",
                                       "{:.20s} se fait chauffer un bon chocolat chaud"]

    def call_handle(self):
        """ Method: executed when Chocolat module event is raised """
        if self.start_with_call_set() is False:
            return
        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if len(splited_msg) < 2 or sender in splited_msg[1]:
            self.c.privmsg(target, random.choice(self.Chocolat_msg_list_duo).format(sender.nick, splited_msg[1]))
        else:
            self.c.privmsg(target, random.choice(self.Chocolat_msg_list_solo).format(sender.nick))

