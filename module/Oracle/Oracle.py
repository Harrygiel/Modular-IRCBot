#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
Cafe Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys, random

sys.path.append('module')
from BotModule import BotModule


class Oracle(BotModule):
    """ Class: Oracle Module Class"""
    def __init__(self, parent, default_module_node):
        super(Oracle, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        target = self.argument[2]

        answer_list = ["Oui",
                       "Non",
                       "Peut être",
                       "Désolé, je n'ai pas le temps pour des questions si futiles !",
                       "Ce n'est pas impossible ..."]
        random_choice = random.randint(0, len(answer_list)-1)
        self.c.privmsg(target, "" + answer_list[random_choice])
        return answer_list[random_choice]
