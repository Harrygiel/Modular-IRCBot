#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
ChannelWorker Calling ModuleWorker

Creator: Harrygiel
"""

import sys, threading, imp

sys.path.append('core')
import ModuleCoreSystem as MCS

class Worker(threading.Thread):
    """ Class: ChannelWorker Class """
    def __init__(self, c, channel_node, parent):
        threading.Thread.__init__(self)
        self.callEvent = threading.Event()
        self.c = c
        self.parent = parent
        self.node = channel_node
        self.name = parent.url + "/" + self.node.get("name")
        self.is_running = True
        self.module_dict = {}
        self.thread = None
        self.argument = ["", "", ""]

        c.join(self.node.get("name"))

        self.update_module_list()

    def run(self):
        self.thread = threading.Thread(target=self._main)
        self.thread.start()

    def _main(self):
        print("" + self.name + " called every module and is ready to serve !")
        while self.is_running:
            self.callEvent.wait()
            for module_object in self.module_dict.values():
                for call_text in module_object.call_set:
                    if call_text in self.argument[1]:
                        module_object.argument = self.argument
                        module_object.callEvent.set()
            self.callEvent.clear()

    def stop(self):
        self.is_running = False
        for module_object in self.module_dict.values():
            module_object.stop()
        self.callEvent.set()

    def update_module_list(self):
        for module_node in MCS.botConfObject.xpath(MCS.DEFAULTCONFPATH + "/module"):
            module_name = module_node.get("name")
            if MCS.is_module_globally_activated(module_name, self.node):
                self.start_module(module_node)
            else:
                self.stop_module(module_node.get("name"))

    def start_module(self, module_node):
        try:
            if module_node.get("name") in self.module_dict:
                #Module already activated
                return
            module_name = module_node.get("name")
            module_path = "./module/" + module_name + "/" + module_name + ".py"
            class_ = getattr(imp.load_source(module_name, module_path), module_name)
            #self.node.append(newModule_node)
            new_module_class = class_(self, module_node)
            new_module_class.run()
            self.module_dict.update({module_name: new_module_class})
            return True
        except Exception as e:
            print(u"Can't load " + module_name + u". Exception: ")
            print(e)
            return False

    def stop_module(self, module_name):
        module_object = self.module_dict.pop(module_name, None)
        if module_object != None:
            del module_object
            return True
        else:
            return False
