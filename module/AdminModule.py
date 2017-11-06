#! /usr/bin/env python
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Chamot V2.0
Administrator Module Class

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys, threading
from lxml import etree

sys.path.append('core')
import ModuleCoreSystem as MCS

class AdminModule(threading.Thread):
    """ Administrator class to create a special administrator module for the bot """
    def __init__(self, parent):
        super(AdminModule, self).__init__()
        self.callEvent = threading.Event()
        self.c = None
        self.name = parent.url + "/AdminModule"
        self.is_running = True
        self.call = "!admin"
        self.thread = None
        self.argument = ["", "", ""]
        self.parent = parent

    def run(self, c):
        """ Method: start the module thread """
        self.c = c
        self.thread = threading.Thread(target=self._main)
        self.thread.start()
        return

    def _main(self):
        """ Method: module loop waiting for module event """
        MCS.append_log("Module Started")
        while self.is_running:
            self.callEvent.wait()

            splited_msg = self.argument[1].split()
            splited_msg = [argument for argument in splited_msg if argument != ""]
            base_node = MCS.get_first_existing_node_by_channel_name(self.parent.url, splited_msg[len(splited_msg)-1])
            admin_parent_node = MCS.is_user_globally_admin(self.argument[0], base_node[0])
            if admin_parent_node is not False:
                MCS.append_log(self.argument[0] + " call: " + self.argument[1])
                self.execute_admin_order(self.argument[1], admin_parent_node)
            else:
                MCS.append_log(self.argument[0] + "tried to call: " + self.argument[1])
                print("Not an admin")

            self.callEvent.clear()
        return

    def stop(self):
        self.is_running = False
        self.callEvent.set()

    def execute_admin_order(self, msg, admin_parent_node):
        """ Method: execute when the module event is raised and every prerequist are met """
        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if msg.startswith("!admin connect") and self.command_checker(splited_msg, 3, "!admin connect <channel>"):
            self.connect_chan(splited_msg[2])

        elif msg.startswith("!admin disconnect") and self.command_checker(splited_msg, 3, "!admin disconnect <channel>"):
            self.disconnect_chan(splited_msg[2])

        elif msg.startswith("!admin start") and self.command_checker(splited_msg, 4, "!admin start <module> <channel>"):
            self.change_module_node_state(splited_msg[2], splited_msg[3], "true")

        elif msg.startswith("!admin stop") and self.command_checker(splited_msg, 4, "!admin stop <module> <channel>"):
            self.change_module_node_state(splited_msg[2], splited_msg[3], "false")

        elif msg.startswith("!admin addAdmin") and self.command_checker(splited_msg, 4, "!admin addAdmin <pseudo!~realname@host> <channel>"):
            self.change_admin_level(splited_msg[2], splited_msg[3], "1")

        elif msg.startswith("!admin delAdmin") and self.command_checker(splited_msg, 4, "!admin delAdmin <pseudo!~realname@host> <channel>"):
            self.change_admin_level(splited_msg[2], splited_msg[3], "0")

        elif msg.startswith("!admin saveConf") and self.command_checker(splited_msg, 3, "!admin saveConf <xml_file>"):
            MCS.set_save_conf(splited_msg[2])

        elif msg.startswith("!admin dump") and self.command_checker(splited_msg, 2, "!admin dump"):
            self.dump_xml()

        elif msg.startswith("!admin reloadModule") and self.command_checker(splited_msg, 2, "!admin reloadModule"):
            self.parent.update_module_list()

        return

    def command_checker(self, splited_msg, nbr_argument_asked, command_format_msg):
        """ Method: check if the command sent to bot have the good number of argument
        and print the good format if not """
        if len(splited_msg) != nbr_argument_asked:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Format commande: " + command_format_msg)
            return False
        else:
            return True

    def connect_chan(self, channel_name):
        """ Method: connect the bot to a new chan """
        if channel_name in self.parent.channel_dict:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Already on the channel " + channel_name + " !")
        else:
            new_channel_node = MCS.get_new_channel_node(channel_name)
            MCS.botConfObject.xpath("server[@url='" + self.parent.url + "'] ")[0].append(new_channel_node)################################# NOT APPENDING: OUT OF RANGE
            MCS.append_log(self.parent.nickname + " connected to: " + channel_name)
            self.parent.join_chan(new_channel_node)

    def disconnect_chan(self, channel_name):
        """ Method: disconnect the bot from a chan """
        if channel_name in self.parent.channel_dict:
            MCS.append_log(self.parent.nickname + " disconnected from: " + channel_name)
            chan_xpath_expr = "/botConf/server[@url='" + self.parent.url + "']/salon[@name='" + channel_name + "']"
            chan_node = MCS.botConfObject.xpath(chan_xpath_expr)[0]
            chan_node.getparent().remove(chan_node)
            self.parent.part_chan(channel_name)
        else:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Not connected on the channel " + channel_name + " !")

    def change_module_node_state(self, module_name, node_name, state):
        """ Method: change module state for node_name if in the node """
        is_changed = False
        module_root_xpath = MCS.get_node_root_path(node_name, self)
        if module_root_xpath is not False:
            is_changed = MCS.change_module_node_by_activation(module_root_xpath, module_name, state)
        else:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Not connected on the channel " + node_name + " !")

        if is_changed:
            MCS.append_log(module_name + " on " + node_name + " changed to: " + state  + " !")
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] " + module_name + " on " + node_name + " changed to: " + state  + " !")
            if node_name[0] == "#":
                self.parent.channel_dict[node_name].update_module_list()
            else:
                self.parent.update_module_list()
        else:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] " + module_name + " not changed to: " + state + " !")


    def change_admin_level(self, admin_mask, node_name, level):
        """ Method: change admin state in node_name """
        is_changed = False
        admin_root_xpath = MCS.get_node_root_path(node_name, self)
        if admin_root_xpath is not False:
            is_changed = MCS.change_admin_level(admin_root_xpath, admin_mask, level)
        else:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Not connected on the channel " + node_name + " !")

        if is_changed:
            MCS.append_log(admin_mask + " now level: " + level + " on " + node_name)
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] " + admin_mask + " now level: " + level + " on " + node_name)
        else:
            self.c.privmsg(self.argument[0].nick, "[" + self.name + "] " + admin_mask + " not changed to: " + level + " !")

    def dump_xml(self):
        etree.dump(MCS.botConfObject.getroot())
