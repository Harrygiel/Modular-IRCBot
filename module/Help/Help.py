#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Help Module

Creator: Harrygiel
"""

from __future__ import unicode_literals
import sys

sys.path.append('module')
from BotModule import BotModule

class Help(BotModule):
    """ Class: Help Module Class"""
    def __init__(self, parent, default_module_node):
        super(Help, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False or "chamot" in self.argument[0].nick.lower():
            return
        target = self.argument[2]

        command_list = ""
        for module_name, module_object in self.parent.module_dict.iteritems():
            if len(module_object.call_set) > 0 and list(module_object.call_set)[0][0].isalnum() is False:
                command_list = command_list + list(module_object.call_set)[0] + " "
            else:
                command_list = command_list + module_name + " "

        #print("Liste des commandes du bot: " + command_list)
        self.c.privmsg(target, "Liste des commandes du bot: " + command_list)
