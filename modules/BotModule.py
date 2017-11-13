#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot v2.3
Generic Module Class

Creator: Harrygiel
"""

import threading, traceback

import core.ModuleCoreSystem as MCS

class BotModule(threading.Thread):
    """ Generic class to create a module for the bot """
    def __init__(self, parent):
        threading.Thread.__init__(self)
        self.callEvent = threading.Event()
        self.parent = parent
        self.c = parent.c
        self.name = parent.name + "/" + self.__class__.__name__
        self.is_running = True
        self.call_set = self.get_call_set(parent.node)
        self.thread = None
        self.argument = ["", "", ""]

    def run(self):
        """ Method: start the module thread """
        self.thread = threading.Thread(target=self._main, name=self.name)
        self.thread.start()
        return

    def _main(self):
        """ Method: module loop waiting for module event """
        MCS.append_log("Module Started")
        try:
            while self.is_running:
                self.callEvent.wait()
                if self.is_running:
                    MCS.append_log(self.name + " called by " + self.argument[0] + "with: " + self.argument[1])
                    self.call_handle()
                self.callEvent.clear()
        except Exception as e:
            MCS.append_log("{:.100s} Need to reboot... Exception: {:.100s}".format(self.name, str(e)))
            traceback.print_exc()
            print("[" + self.name + "] rebooting...")
            self.parent.restart_module(self.__class__.__name__)
        return

    def call_handle(self):
        """ Method: executed when the module event is raised """
        print("[BotModule] Main called")

    def stop(self):
        MCS.append_log("Module Stopped")
        self.is_running = False
        self.callEvent.set()

    def start_with_call_set(self):
        """ Method: look if the message in argument[1] start with a string in the set call_set """
        if not self.argument[0] == "":
            msg_lowered = self.argument[1].lower()
            for call_text in self.call_set:
                if msg_lowered.startswith(call_text.lower()):
                    return True
        return False

    def get_call_set(self, channel_node):
        """ Method: get a set of string who will call the module if found in a message
        look in chan, then server, then global module conf"""
        call_set = set(["!" + self.__class__.__name__])
        module_call_path = "module[@name='" + self.__class__.__name__ + "']/call"
        root_node = channel_node
        while root_node != None:
            module_call_nodes = root_node.xpath(module_call_path)
            if len(module_call_nodes) > 0:
                for call_node in module_call_nodes:
                    call_set.add(call_node.text.lower())
            root_node = root_node.getparent()
        return call_set
