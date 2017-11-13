#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Cafe Module

Creator: Harrygiel
"""

from modules.BotModule import BotModule

class Cafe(BotModule):
    """ Class: Cafe Module Class"""
    def __init__(self, parent):
        super(Cafe, self).__init__(parent)

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
            self.c.privmsg(target, "{:.20s} se prépare un e-café bien chaud. Enfin prêt pour la journée !".format(sender.nick))
        else:
            self.c.privmsg(target, "{:.20s} offre un e-café bien chaud à {:.20s}. Préparé avec amour !".format(sender.nick, splited_msg[1]))
