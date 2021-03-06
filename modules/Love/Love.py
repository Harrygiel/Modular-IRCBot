#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Love Module

Creator: Harrygiel
"""

import random, datetime, sys

sys.path.append("modules")
from BotModule import BotModule

class Love(BotModule):
    """ Class: Love Module Class"""
    def __init__(self, parent):
        super(Love, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False or "chamot" in self.argument[0].nick.lower():
            return
        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        target_answer_string = ""
        targets = msg.split(" ")
        targets.pop(0)
        targets = [argument for argument in targets if argument != ""]

        target_list_len = len(targets)

        #No name
        if target_list_len == 0:
            target_answer_string = sender.nick + " et sa main"

        #Only 1 name
        elif target_list_len == 1:
            target_answer_string = sender.nick + " et " + targets[0]

        #More than 1 name
        else:
            for i in range(0, target_list_len-1):
                target_answer_string += targets[i] + ", "
            target_answer_string += "et " + targets[target_list_len-1]

        seed = str(datetime.date.today()) + target_answer_string
        random.seed(seed)
        rand_nbr_str = str(random.randint(0, 100))
        self.c.privmsg(target, "Vérification de la compatibilité.... " + target_answer_string + " ont une compatibilité de " + rand_nbr_str + "% !")
