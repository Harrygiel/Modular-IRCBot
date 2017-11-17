#!/usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.3.4
Administrator Module Class

Creator: Harrygiel
"""

import threading, os, traceback
from lxml import etree

import core.ModuleCoreSystem as MCS

class AdminModule(threading.Thread):
    """ Administrator class to create a special administrator module for the bot """
    def __init__(self, parent):
        super(AdminModule, self).__init__()
        self.callEvent = threading.Event()
        self.c = None
        self.name = parent.url + "/AdminModule"
        self.prefix = "[{:.100s}] ".format(self.name)
        self.is_running = True
        self.call = "!admin"
        self.thread = None
        self.argument = ["", "", ""]
        self.parent = parent

    def run(self, c):
        """ Method: start the module thread """
        self.c = c
        self.thread = threading.Thread(target=self._main, name=self.name)
        self.thread.start()
        return

    def _main(self):
        """ Method: module loop waiting for module event"""

        MCS.append_log("Module Started")
        try:
            while self.is_running:
                self.callEvent.wait()
                self.analyse_sender_permission()
                self.callEvent.clear()
            return
        except Exception as e:
            MCS.append_log("{:.100s} Need to reboot... Exception: {:.100s}".format(self.name, str(e)))
            traceback.print_exc()
            print("[" + self.name + "] rebooting...")
            self.parent.restart_admin_module()
        return

    def analyse_sender_permission(self):
        """analyse_sender_permission"""

        splited_msg = self.argument[1].split()
        splited_msg = [argument for argument in splited_msg if argument != ""]
        node_name = splited_msg[-1]

        off_admin = False
        if node_name[0] != "#":
            node_name = self.parent.url
        else:
            try:
                off_admin = self.parent.channels[node_name].is_oper(self.argument[0].nick)
            except KeyError:
                pass

        base_node = MCS.get_first_real_root(self.parent.url, node_name)
        root_node_path = MCS.botConfObject.getpath(base_node[0])

        admin_node = MCS.recursively_scan_node_info(root_node_path, "admin", "mask", self.argument[0], False)

        is_bot_admin = admin_node is not False and admin_node is not None
        is_off_admin_and_used = off_admin is True and self.parent.channel_dict[node_name].useoffadmin is True
        if is_off_admin_and_used or is_bot_admin:
            MCS.append_log(self.argument[0] + " call: " + self.argument[1])
            self.execute_admin_order(self.argument[1])
        else:
            MCS.append_log(self.argument[0] + " tried to call: " + self.argument[1] + " but wasn't admin")
            self.c.privmsg(self.argument[0].nick, self.prefix + self.argument[0] + " is not admin from " + node_name + " or upper!")

    def stop(self):
        self.is_running = False
        self.callEvent.set()

    def execute_admin_order(self, msg):
        """ Method: execute when the module event is raised and every prerequist are met """
        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if msg.startswith("!admin connect") and self.command_checker(splited_msg, 3, "!admin connect <channel>"):
            self.connect_chan(splited_msg[2])

        elif msg.startswith("!admin disconnect") and self.command_checker(splited_msg, 3, "!admin disconnect <channel>"):
            self.disconnect_chan(splited_msg[2])

        elif msg.startswith("!admin start") and self.command_checker(splited_msg, -4, "!admin start <module> <channel>"):
            self.change_module_node_state(splited_msg[2:-1], splited_msg[-1], "true")

        elif msg.startswith("!admin stop") and self.command_checker(splited_msg, -4, "!admin stop <module> <channel>"):
            self.change_module_node_state(splited_msg[2:-1], splited_msg[-1], "false")

        elif msg.startswith("!admin edit") and self.command_checker(splited_msg, -4, "!admin edit <info> [attr=value attr2=value2...] <range>"):
            self.edit_recursive_node(splited_msg[2], splited_msg[-1], splited_msg[3:-1])

        elif msg.startswith("!admin saveConf") and self.command_checker(splited_msg, 3, "!admin saveConf <xml_file>"):
            MCS.set_save_conf(splited_msg[2])

        elif msg.startswith("!admin list") and self.command_checker(splited_msg, 4, "!admin list <info> <range>"):
            self.list_info(splited_msg[2], splited_msg[3])

        elif msg.startswith("!admin dump") and self.command_checker(splited_msg, 2, "!admin dump"):
            self.dump_xml()

        elif msg.startswith("!admin reload") and self.command_checker(splited_msg, 3, "!admin reload <range>"):
            self.update_conf(splited_msg[2])

        return

    def command_checker(self, splited_msg, nbr_argument_asked, command_format_msg):
        """ Method: check if the command sent to bot have the good number of argument
        and print the good format if not """
        if nbr_argument_asked > 0:
            if len(splited_msg) != nbr_argument_asked:
                self.c.privmsg(self.argument[0].nick, self.prefix + "Format commande: " + command_format_msg)
                return False
            else:
                return True
        else:
            if len(splited_msg) < -nbr_argument_asked:
                self.c.privmsg(self.argument[0].nick, self.prefix + "Format commande: " + command_format_msg)
                return False
            else:
                return True


    def connect_chan(self, channel_name):
        """ Method: connect the bot to a new chan """
        if channel_name in self.parent.channel_dict:
            self.c.privmsg(self.argument[0].nick, self.prefix + "Already on the channel " + channel_name + " !")
        else:
            new_channel_node = MCS.get_new_channel_node(channel_name)
            MCS.botConfObject.xpath("server[@url='" + self.parent.url + "'] ")[0].append(new_channel_node)
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
            self.c.privmsg(self.argument[0].nick, self.prefix + "Not connected on the channel " + channel_name + " !")

    def change_module_node_state(self, module_names, node_name, state):
        """ Method: change module state for node_name if in the node """
        for module_name in module_names:
            is_changed = False
            module_root_xpath = MCS.get_node_root_path(node_name, self)
            if module_root_xpath is not False:
                is_changed = MCS.change_module_node_by_activation(module_root_xpath, module_name, state)
            else:
                self.c.privmsg(self.argument[0].nick, self.prefix + "Not connected on the channel " + node_name + " !")

            if is_changed:
                MCS.append_log(module_name + " on " + node_name + " changed to: " + state  + " !")
                self.c.privmsg(self.argument[0].nick, self.prefix + module_name + " on " + node_name + " changed to: " + state  + " !")
                if node_name[0] == "#":
                    self.parent.channel_dict[node_name].update_module_list()
                else:
                    self.parent.update_module_list()
            else:
                self.c.privmsg(self.argument[0].nick, self.prefix + module_name + " not changed to: " + state + " !")

    def edit_recursive_node(self, info, range_name, attr_list_text):

        is_changed = False

        root_path = MCS.get_node_root_path(range_name, self)
        if root_path is False:
            self.c.privmsg(self.argument[0].nick, self.prefix + "Can't access range: " + range_name + " !")
            return

        # We already know that the sender is an admin, but is it a upper range admin ?

        sender_level = self.sender_relative_admin_power(range_name)

        try:
            attr_dict = dict([ i.split("=") for i in attr_list_text])
        except ValueError:
            self.c.privmsg(self.argument[0].nick, self.prefix + "Attribute wrongly formated: <attr=value> !")
            return

        is_valid = True

        if info.lower() == "blacklisted":
            if not "mask" in attr_dict:
                is_valid = False
                self.c.privmsg(self.argument[0].nick, self.prefix + "You need to specify a mask!")
            if is_valid == True:
                new_node = MCS.get_new_node("blacklisted", attr_dict, ["mask", "remove"])
                etree.dump(new_node)
                is_changed = MCS.merge_node(new_node, root_path, ["mask", attr_dict["mask"]],{"remove":"true"})
        elif info.lower() == "admin":
            if not "mask" in attr_dict:
                is_valid = False
                self.c.privmsg(self.argument[0].nick, self.prefix + "You need to specify a mask!")
            if not "level" in attr_dict:
                is_valid = False
                self.c.privmsg(self.argument[0].nick, self.prefix + "You need to specify a level!")

            if not attr_dict["level"].isnumeric():
                self.c.privmsg(self.argument[0].nick, self.prefix + "level is not a number!")
                is_valid = False
            if sender_level >= 0 and int(attr_dict["level"]) > sender_level:
                self.c.privmsg(self.argument[0].nick, self.prefix + "new admin can't be higher than you: {:d}".format(sender_level))
                is_valid = False

            if is_valid == True:
                new_node = MCS.get_new_node("admin", attr_dict, ["mask", "level", "remove"])
                is_changed = MCS.merge_node(new_node, root_path, ["mask", attr_dict["mask"]],{"remove":"true", "level":"0"})
        elif info.lower() == "channel":
            if not "name" in attr_dict:
                is_valid = False
                self.c.privmsg(self.argument[0].nick, self.prefix + "You need to specify a name!")

            if is_valid == True:
                new_node = MCS.get_new_node("salon", attr_dict, ["name", "blacklist", "useoffadmin"])
                is_changed = MCS.merge_node(new_node, root_path, ["name", attr_dict["name"]],{})

        else:
            self.c.privmsg(self.argument[0].nick, self.prefix + "{:.50s} unknown".format(info))

        if is_changed:
            MCS.append_log("{:.50s} edited in {:.50s}".format(info, range_name))
            self.c.privmsg(self.argument[0].nick, self.prefix + "{:.50s} edited in {:.50s}".format(info, range_name))
        else:
            self.c.privmsg(self.argument[0].nick, self.prefix + "{:.50s} not edited in {:.50s}".format(info, range_name))

    def sender_relative_admin_power(self, range_name):
        root_path = MCS.get_node_root_path(range_name, self)
        sender_node = MCS.recursively_scan_node_info(root_path, "admin", "mask", self.argument[0], False)
        is_bot_admin = sender_node is not False and sender_node is not None

        if is_bot_admin:
            # remove 1 in depth because of the <admin> depth
            if MCS.range_depth(range_name) > MCS.node_depth(sender_node)-1:
                return -1
            else:
                return int(sender_node.get("level"))
        else:
            return 5

    def list_info(self, info_name, node_name):
        node_root_xpath = MCS.get_node_root_path(node_name, self)

        if info_name == "admin":
            if node_root_xpath is False:
                self.c.privmsg(self.argument[0].nick, self.prefix + "No conf for " + node_name + " !")
            else:
                node_root_xpath = node_root_xpath + "/admin"
                node_list = MCS.botConfObject.xpath(node_root_xpath)
                if len(node_list) >0:
                    for node in node_list:
                        self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Admin: " + node.get("mask") + " is level: " + node.get("level"))

        elif info_name == "module":
            if node_name.lower() == "installed":
                module_set = set([name for name in os.listdir("modules") if os.path.isdir(os.path.join("modules", name)) and name[0] is not "_"])
                self.c.privmsg(self.argument[0].nick, self.prefix + "Modules installed: " + ", ".join(module_set))
            elif node_root_xpath is False:
                self.c.privmsg(self.argument[0].nick, self.prefix + "No conf for " + node_name + " !")
            else:
                node_root_xpath = node_root_xpath + "/module"
                node_list = MCS.botConfObject.xpath(node_root_xpath)
                if len(node_list) >0:
                    for node in node_list:
                        self.c.privmsg(self.argument[0].nick, "[" + self.name + "] Module: " + node.get("name") + " is at state: " + node.get("activated"))
        else:
            self.c.privmsg(self.argument[0].nick, self.prefix + "Info: " + info_name + " unknown !")
            return

    def update_conf(self, range_name):
        real_node = MCS.get_first_real_root(self.parent.url, range_name)[0]

        if MCS.node_depth(real_node) == 0:
            self.c.privmsg(self.argument[0].nick, self.prefix + "Not working for now !")
        elif MCS.node_depth(real_node) == 1:
            self.parent.update_server_node()
            self.c.privmsg(self.argument[0].nick, self.prefix + "Server updated !")
        elif MCS.node_depth(real_node) == 2:
            self.parent.channel_dict[range_name].update_server_node()
            self.c.privmsg(self.argument[0].nick, self.prefix + "Channel updated !")


    def dump_xml(self):
        etree.dump(MCS.botConfObject.getroot())
