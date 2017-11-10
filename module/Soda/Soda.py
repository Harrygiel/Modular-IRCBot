#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1.2
Soda Module

Creator: MemePasMoi
"""

import sys

sys.path.append('module')
from BotModule import BotModule
import random


class Soda(BotModule):
    """ Class: Soda Module Class"""
    def __init__(self, parent, default_module_node):
        super(Soda, self).__init__(parent, default_module_node)

        self.soda_list = ["Canada Dry",
                          "Champomy",
                          "Coca Zero",
                          "Coca-Cola",
                          "Coca-Cola Cherry",
                          "Coca-Cola Light",
                          "Coca-Cola vanille",
                          "Coca-Cola Zero Cherry",
                          "Fanta",
                          "Fanta Zero",
                          "Ginger Ale",
                          "Minute Maid",
                          "Orangina",
                          "Orangina light",
                          "Pepsi",
                          "Pepsi light",
                          "Red Bull",
                          "Schweppes Agrum",
                          "Schweppes Indian Tonic",
                          "Seven Up",
                          "Sprite",
                          "Sprite Zero",
                          "Taillefine Fiz"
        ]

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
            offre_soda_msg = "{%.20s} offre un " + random.choice(self.soda_list) + " à {%.20s} !!! ATTENTION : L'abus de bubulles est dangereux pour la santé !!!"
            self.c.privmsg(target, offre_soda_msg.format(sender.nick, splited_msg[1]))

        else:
            offre_soda_msg = "{%.20s} s'ouvre une canette de " + random.choice(self.soda_list) + "  !!! ATTENTION : L'abus de bubulles est dangereux pour la santé !!!"
            self.c.privmsg(target, offre_soda_msg.format(sender.nick))
