#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Chocolat Module

Creator: Harrygiel
"""

import sys

sys.path.append('module')
from BotModule import BotModule


class Chocolat(BotModule):
    """ Class: Chocolat Module Class"""
    def __init__(self, parent, default_module_node):
        super(Chocolat, self).__init__(parent, default_module_node)

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
            self.c.privmsg(target, "" + sender.nick + " se prépare un e-chocolat bien chaud. Enfin prêt pour la journée !")
        else:
            self.c.privmsg(target, "" + sender.nick + " offre un e-chocolat bien chaud à " + splited_msg[1] + ". Préparé avec amour !")
