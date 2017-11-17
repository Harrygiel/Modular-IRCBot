#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.4
Generic TCL Module

Creator: Harrygiel
"""

import threading, os, tkinter, traceback

import core.ModuleCoreSystem as MCS
from BotModule import BotModule

class TclModule(BotModule):
    """ Class: TclModule Module Class"""
    def __init__(self, parent):
        super(TclModule, self).__init__(parent)
        self.load_list = ["VirtualEgg.tcl"]
        self.tcl_source = dict()
        self.tcl_interpreter = None

    def _main(self):
        """ Method: module loop waiting for module event """
        MCS.append_log("Module Started")
        try:
            # Load TCL part
            self.tcl_interpreter = tkinter.Tcl()
            for script in self.load_list:
                self.tcl_interpreter.eval("source {:.50s}/{:.50s}".format("modules/" + self.__class__.__name__, script))
        except Exception as e:
            MCS.append_log("{:.100s} Need to reboot... Exception: {:.100s}".format(self.name, str(e)))
            traceback.print_exc()
            print("[" + self.name + "] Can't Load source !")

        super(TclModule, self)._main()
        return
