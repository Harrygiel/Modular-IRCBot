#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.4
ChannelWorker Calling ModuleWorker

Creator: Harrygiel
"""

import os, threading, imp, queue
import core.ModuleCoreSystem as MCS


class Worker(threading.Thread):
    """ Class: ChannelWorker Class """
    def __init__(self, c, channel_node, parent):
        threading.Thread.__init__(self)
        self.callEvent = threading.Event()
        self.c = c
        self.parent = parent
        self.node = channel_node
        self.channel_name = self.node.get("name").lower()
        self.blacklist = MCS.get_node_attr_to_bool(self.node, "blacklist")
        self.useoffadmin = MCS.get_node_attr_to_bool(self.node, "useoffadmin", False)
        self.name = parent.url + "/" + self.channel_name
        self.is_running = True
        self.module_dict = {}
        self.thread = None
        self.argument_queue = queue.Queue()

        c.join(self.channel_name)

        self.update_module_list()

    def run(self):
        self.thread = threading.Thread(target=self._main, name=self.name)
        self.thread.start()

    def _main(self):
        MCS.append_log(self.name + " started")
        while self.is_running:
            self.callEvent.wait()
            if self.is_running:
                while not self.argument_queue.empty():
                    arguments = self.argument_queue.get()
                    for module_object in self.module_dict.values():
                        for call_text in module_object.call_set:
                            if call_text.lower() in arguments[1].lower():
                                module_object.argument = arguments
                                module_object.callEvent.set()
                    self.argument_queue.task_done()
            self.callEvent.clear()

    def stop(self):
        self.is_running = False
        for module_object in self.module_dict.values():
            module_object.stop()
        MCS.append_log(self.name + " stopped")
        self.callEvent.set()

    def update_module_list(self):
        channel_path = MCS.botConfObject.getpath(self.node)
        module_set = set([name for name in os.listdir("modules")
                         if os.path.isdir(os.path.join("modules", name)) and name[0] is not "_"])
        for module_node in MCS.botConfObject.xpath(MCS.DEFAULTCONFPATH + "/module"):
            module_set.update([module_node.get("name")])
        for module_name in module_set:
            module_path = "module[@name='" + module_name + "']"
            scan_result = MCS.recursively_scan_node_info(channel_path, module_path, "activated", "true", True)
            if scan_result is None or scan_result is not False:
                self.start_module(module_name)
            else:
                #stop or do nothing
                self.stop_module(module_name)

    def start_module(self, module_name):
        try:
            if module_name in self.module_dict:
                #Module already activated
                return
            base_path = "./modules/" + module_name + "/"
            module_path = base_path + module_name + ".py"
            class_ = getattr(imp.load_source(module_name, module_path), module_name)
            new_module_class = class_(self)
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
            module_object.stop()
            del module_object
            return True
        else:
            return False

    def restart_module(self, module_name):
        self.stop_module(module_name)
        self.start_module(module_name)
