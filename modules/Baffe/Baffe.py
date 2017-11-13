#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Baffe Module

Creator: MemePasMoi
"""

import random
from modules.BotModule import BotModule

class Baffe(BotModule):
    """ Class: Baffe Module Class"""
    def __init__(self, parent):
        super(Baffe, self).__init__(parent)
        self.Baffe_msg_list_duo = ["{:.20s} offre une collection complète de baffes à {:.20s}",
                                   "{:.20s} baffe {:.20s} dans un aller et retour cinglant",
                                   "{:.20s} sort la tronçonneuse et découpe {:.20s} en tranches bien propres. C'est mieux qu'une baffe !",
                                   "{:.20s} triple baffe {:.20s}. Pfiou ça soulage !"]

        self.Baffe_msg_list_solo = ["{:.20s} s'offre une collection complète de baffes.",
                                    "{:.20s} s'auto baffe dans un aller et retour cinglant",
                                    "{:.20s} sort la tronçonneuse et se découpe en tranches bien propres. C'est mieux qu'une baffe !",
                                    "{:.20s} s'auto triple baffe. Si ca fait mal c'est que c'est bon !"]


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
            self.c.privmsg(target, random.choice(self.Baffe_msg_list_solo).format(sender.nick))
        else:
            self.c.privmsg(target, random.choice(self.Baffe_msg_list_duo).format(sender.nick, splited_msg[1]))
