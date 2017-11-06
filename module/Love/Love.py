#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Love Module

Creator: Harrygiel
"""

from __future__ import unicode_literals
import sys, random, datetime

sys.path.append('module')
from BotModule import BotModule


class Love(BotModule):
    """ Class: Love Module Class"""
    def __init__(self, parent, default_module_node):
        super(Love, self).__init__(parent, default_module_node)

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
