#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Clope Module

Creator: MemePasMoi
"""

import sys

sys.path.append('module')
from BotModule import BotModule
import random


class Clope(BotModule):
    """ Class: Clope Module Class"""
    def __init__(self, parent, default_module_node):
        super(Clope, self).__init__(parent, default_module_node)
        self.Clope_msg_list_duo = ["{%.20s} offre une clope à {%.20s} (faudrait aussi penser à arrêter de fumer !)",
                                   "{%.20s} jette une cigarette en chocolat à {%.20s}",
                                   "{%.20s} offre une cigarette à {%.20s}. Quel brouillard d'un coup !",
                                   "{%.20s} sort un briquet et allume une clope pour {%.20s}. Yeah baby !"]

        self.Clope_msg_list_solo = ["{%.20s} se dégainne une clope (faudrait aussi penser à arrêter de fumer !)",
                                    "{%.20s} s'offre une cigarette en chocolat",
                                    "{%.20s} allume une cigarette. Quel brouillard d'un coup !",
                                    "{%.20s} sort un briquet et allume sa clope. Yeah baby !"]

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
            self.c.privmsg(target, random.choice(self.Clope_msg_list_duo).format(sender.nick, splited_msg[1]))
            return

        else:
            self.c.privmsg(target, random.choice(self.Clope_msg_list_solo).format(sender.nick))
            return
