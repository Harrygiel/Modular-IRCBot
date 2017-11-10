#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Calin Module

Creator: MemePasMoi
"""

import sys

sys.path.append('module')
from BotModule import BotModule
import random


class Calin(BotModule):
    """ Class: Calin Module Class"""
    def __init__(self, parent, default_module_node):
        super(Calin, self).__init__(parent, default_module_node)
        self.Calin_msg_list_duo = ["{:.20s} fait un gros câlin et tout plein de poutous à {:.20s}",
                                   "{:.20s} grattouille {:.20s} dans le dos et derrière l'oreille",
                                   "{:.20s} câline gentiment {:.20s}",
                                   "{:.20s} se blottit contre {:.20s} et lui fait un énorme câlin !"]

        self.Calin_msg_list_solo = ["{:.20s} se fait un gros câlin et tout plein de poutous",
                                    "{:.20s} se grattouille dans le dos et derrière l'oreille",
                                    "{:.20s} se câline gentiment ",
                                    "{:.20s} se blottit contre lui même et se fait un énorme câlin !"]

    def call_handle(self):
        """ Method: executed when Calin module event is raised """
        if self.start_with_call_set() is False:
            return
        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if len(splited_msg) < 2 or sender in splited_msg[1]:
            self.c.privmsg(target, random.choice(self.Calin_msg_list_solo).format(sender.nick))
        else:
            self.c.privmsg(target, random.choice(self.Calin_msg_list_duo).format(sender.nick, splited_msg[1]))
