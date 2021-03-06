#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.4
Oracle TCL Module

Creator: Harrygiel
"""
import time
from modules.TclModule import TclModule

class Oracle(TclModule):
    """ Class: Oracle Module Class"""
    def __init__(self, parent):
        super(Oracle, self).__init__(parent)
        self.load_list = ["VirtualEgg.tcl", "HaploPhone.tcl", "RDR.tcl", "Oracle.tcl"]


    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return

        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        cmd = "::Oracle::ask_oracle {:.50s} {:.50s} \"{:.50s}\"".format(sender.nick, target, msg)
        self.c.privmsg(target, self.tcl_interpreter.eval(cmd))