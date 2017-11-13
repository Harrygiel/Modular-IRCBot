#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.5
Help Module

Creator: Harrygiel
"""

import sys

sys.path.append("modules")
from BotModule import BotModule

class Help(BotModule):
    """ Class: Help Module Class"""
    def __init__(self, parent):
        super(Help, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False or "chamot" in self.argument[0].nick.lower():
            return
        target = self.argument[2]

        command_list = ""
        for module_name, module_object in self.parent.module_dict.items():
            if len(module_object.call_set) > 0 and list(module_object.call_set)[0][0].isalnum() is False:
                command_list = command_list + list(module_object.call_set)[0] + " "
            else:
                command_list = command_list + module_name + " "

        #print("Liste des commandes du bot: " + command_list)
        self.c.privmsg(target, "Liste des commandes du bot: " + command_list)
