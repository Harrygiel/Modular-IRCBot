#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Fesse Module

Creator: MemePasMoi
"""

import sys

sys.path.append('module')
from BotModule import BotModule
import random


class Fesse(BotModule):
    """ Class: Fesse Module Class"""
    def __init__(self, parent, default_module_node):
        super(Fesse, self).__init__(parent, default_module_node)
        self.Fesse_msg_list_duo = ["{:.20s} baisse le pantalon de {:.20s} et lui donne une fessée magistrale, devant tout le monde !",
                                   "{:.20s} fesse violemment {:.20s} avec des orties fraîches",
                                   "{:.20s} punit  {:.20s}  avec une fessée dont le souvenir restera gravé dans sa mémoire",
                                   "{:.20s} fout une fessée de la mort qui tue à {:.20s}"]

        self.Fesse_msg_list_solo = ["{:.20s} baisse son pantalon et se donne une fessée magistrale, devant tout le monde !",
                                   "{:.20s} se fesse violemment avec des orties fraîches",
                                   "{:.20s} se punit avec une fessée dont le souvenir restera gravé dans sa mémoire",
                                   "{:.20s} se fout une fessée de la mort qui tue"]

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
            self.c.privmsg(target, random.choice(self.Fesse_msg_list_solo).format(sender.nick))
        else:
            self.c.privmsg(target, random.choice(self.Fesse_msg_list_duo).format(sender.nick, splited_msg[1]))
