#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Cafe Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys

sys.path.append('module')
from BotModule import BotModule


class Cafe(BotModule):
    """ Class: Cafe Module Class"""
    def __init__(self, parent, default_module_node):
        super(Cafe, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        if msg[6:] != None and sender in msg[6:]:
            self.c.privmsg(target, "" + sender.nick + " se prépare un e-café bien chaud. Enfin pret pour la journée !")
        else:
            self.c.privmsg(target, "" + sender.nick + " offre un e-café bien chaud à " + msg[6:] + ". Préparé avec amour !")
