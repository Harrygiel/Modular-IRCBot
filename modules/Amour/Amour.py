#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Amour Module

Creator: Harrygiel
"""

from modules.BotModule import BotModule


class Amour(BotModule):
    """ Class: Amour Module Class"""
    def __init__(self, parent):
        super(Amour, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        if msg[6:] != None and sender in msg[7:]:
            self.c.privmsg(target, "" + sender.nick + " éteint la lumière, allume une bougie, mets une musique douce.... Et sort les paquets de mouchoir ...")
        else:
            amour_text = "" + sender.nick + " éteint la lumière, allume une bougie, met une musique douce.....s'approche doucement de toi, " + msg[7:]+ " te regarde dans les yeux, te déshabille doucement, t'allonge sur le lit et te fait l'amour HuMmMmm.. :3"
            if "Ippo".lower() in sender.lower() or "Wormy".lower() in sender.lower():
                amour_text = amour_text + " Attention aux bébés surprise !"

            self.c.privmsg(target, amour_text)
