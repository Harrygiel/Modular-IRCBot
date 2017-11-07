#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
The core of the module system: look for module, activate or desactivate them, etc...

Creator: Harrygiel
"""

import os.path, datetime, threading
from lxml import etree

botConfObject = etree.Element("root")
conf_lock = threading.Lock()
log_lock = threading.Lock()
DEFAULTCONFPATH = "/botConf"

def is_module_globally_activated(module_name, conf_node):
    """ Function: is the module activated in the XML Tree """
    module_path = "module[@name='" + module_name + "']"
    root_node = conf_node
    while root_node != None:
        module_node = root_node.xpath(module_path)
        if len(module_node) > 0:
            # useful sometime: print("[MCS] Module " + module_name + u" configured in " + root_node.tag)
            return is_module_locally_activated(module_node[0])
        root_node = root_node.getparent()
    return False

def is_module_locally_activated(module_node):
    """ Function: is the module activated in the XML Node """
    if module_node.get("activated").lower() == "true":
        return True
    else:
        return False

def is_user_globally_admin(user_name, conf_node):
    """ Function: is the module activated in the XML Tree """
    root_node = conf_node
    return_node = False
    while root_node != None:
        admin_nodes = root_node.xpath("admin")
        if len(admin_nodes) > 0:
            for admin_node in admin_nodes:
                if is_user_locally_admin(user_name, admin_node):
                    return_node = admin_node
        root_node = root_node.getparent()

    return return_node

def is_user_locally_admin(user_name, admin_node):
    """ Function: is the module activated in the XML Node """
    if admin_node.get("mask") == user_name:
        return True
    else:
        return False

def get_first_existing_node_by_channel_name(server_url, channel_name):
    """ Function: look for a channel node.
    if the channel doesn't exist, look for the server.
    if the server doesn't exist, get the root """
    base_node = get_channel_node_by_name(server_url, channel_name)
    if len(base_node) == 0:
        base_node = get_server_node_by_name(server_url)
    if len(base_node) == 0:
        base_node = botConfObject.xpath(DEFAULTCONFPATH)
    return base_node

def get_node_root_path(node_name, admin_module):
    """ Function: get the path of the root of a node """
    if node_name[0] == "#" and node_name in admin_module.parent.channel_dict:
        return "/botConf/server[@url='" + admin_module.parent.url + "']/salon[@name='" + node_name + "']"
    # Server-side start module
    elif node_name == admin_module.parent.url:
        return "/botConf/server[@url='" + admin_module.parent.url + "']"
    # Global-side start module
    elif node_name.lower() == "global":
        return "/botConf"
    else:
        return False

def get_server_node_by_name(server_url):
    """ Function: return server node by name """
    xpath_expr = "/botConf/server[@url='" + server_url + "']"
    return botConfObject.xpath(xpath_expr)

def get_channel_node_by_name(server_url, channel_name):
    """ Function: return channel node by name """
    xpath_expr = "/botConf/server[@url='" + server_url + "']/salon[@name='" + channel_name + "']"
    return botConfObject.xpath(xpath_expr)

def get_new_channel_node(channel_name):
    """ Function: create a new channel node """
    channel_node = etree.Element("salon")
    channel_node.set('name', channel_name)
    return channel_node

def get_new_module_node(module_name, state):
    """ Function: create a new module node """
    module_node = etree.Element("module")
    module_node.set('name', module_name)
    module_node.set('activated', state)
    return module_node

def get_new_admin_node(admin_mask, level):
    """ Function: create a new module node """
    module_node = etree.Element("admin")
    module_node.set('mask', admin_mask)
    module_node.set('level', level)
    return module_node

def node_depth(node):
    """ Function: get node depth """
    d = 0
    while node is not None:
        d += 1
        node = node.getparent()
    return d

def set_save_conf(conf_file_name):
    """ Function: save configuration file as conf_file_name """
    try:
        if conf_file_name[0] != "/" and not ".." in conf_file_name:
            with conf_lock:
                output_file = open(os.path.abspath(os.curdir) + "/conf/" + conf_file_name, 'wb')
                output_file.write(etree.tostring(botConfObject, pretty_print=True))
                output_file.close()
            return True
        else:
            append_log("WARNING: Directory traversal detected !")
            print("WARNING: Directory traversal detected !")
            return False
    except IOError:
        print(u"The configuration file \"" + conf_file_name + "\" can't be saved")
        return False

def append_log(log_line):
    """ Function: append a line in the log. Thread safe """
    try:
        bot_nickname =botConfObject.xpath(DEFAULTCONFPATH + "/botinfo")[0].get("name")
        with log_lock:
            output_file = open(os.path.abspath(os.curdir) + "/log/" + bot_nickname + ".log", 'a+')
            output_file.write(str(datetime.datetime.now()) + ": [" + threading.current_thread().name + "] " + log_line + "\r\n")
            output_file.close()
        return True
    except IOError:
        print(u"The log file \"" + "log/" + bot_nickname + ".log" + "\" can't be appended")
        return False

def change_module_activation_state(module_node, state):
    """ Function: change activation state """
    if module_node.get("activated") == state:
        print("[" + threading.current_thread().name + "] Module already on state: " + state + " !")
        return False
    else:
        module_node.set('activated', state)
        print("[" + threading.current_thread().name + "] Module now on state: " + state + " !")
        return True

def change_module_node_by_activation(range_xpath_expr, module_name, state):
    """ Function: look for the range of the new module node and create it if needed"""
    range_nodes = botConfObject.xpath(range_xpath_expr)
    if len(range_nodes) > 0:
        module_nodes = range_nodes[0].xpath("module[@name='" + module_name + "']")
        if len(module_nodes) > 0:
            return change_module_activation_state(module_nodes[0], state)
        else:
            range_nodes[0].insert(0, get_new_module_node(module_name, state))
            return True
    else:
        print("[" + threading.current_thread().name + "] Nothing at: " + range_xpath_expr + " !")
        return False

def change_admin_node_level(admin_nodes, level):
    """ Function: change activation state """
    if admin_nodes.get("level") == level:
        print("[" + threading.current_thread().name + "] Admin already level: " + level + " !")
        return False
    else:
        if int(level) > 0:
            admin_nodes.set('level', level)
            print("[" + threading.current_thread().name + "] Admin now level: " + level + " !")
        else:
            admin_nodes.getparent().remove(admin_nodes)
            print("[" + threading.current_thread().name + "] Admin now removed !")
        return True

def change_admin_level(range_xpath_expr, admin_mask, level):
    """ Function: look for the range of the new module node and create it if needed"""
    range_nodes = botConfObject.xpath(range_xpath_expr)
    if len(range_nodes) > 0:
        admin_nodes = range_nodes[0].xpath("admin[@mask='" + admin_mask + "']")
        if len(admin_nodes) > 0:
            return change_admin_node_level(admin_nodes[0], level)
        else:
            if int(level) > 0:
                range_nodes[0].insert(0, get_new_admin_node(admin_mask, level))
            else:
                print("[" + threading.current_thread().name + "] Already level 0 or under")
            return True
    else:
        print("[" + threading.current_thread().name + "] Nothing at: " + range_xpath_expr + " !")
        return False