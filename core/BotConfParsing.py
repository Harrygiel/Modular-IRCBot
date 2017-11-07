#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
Configuration parser for bots

Creator: Harrygiel
"""

from lxml import etree

def parse_conf(conf_file):
    """ Function: parse the XML file to generate the bot configuration """
    try:
        input_file = open(conf_file, 'r')
        bot_conf_object = etree.parse(input_file)
        input_file.close()
        nbr_of_module = len(bot_conf_object.xpath("/botConf/botProprety/defaultConf/module"))
        nbr_of_server = len(bot_conf_object.xpath("/botConf/server"))

        print(u"Configuration loaded. " + str(nbr_of_module) + " module and " + str(nbr_of_server) + " server(s) found !")
        for server in bot_conf_object.xpath("/botConf/server"):
            nbr_of_channel = len(server.xpath("salon"))
            print(u"On " + server.get("name") + " the bot have " + str(nbr_of_channel) + " channel(s) to join")

        return bot_conf_object
    except IOError:
        print(u"The configuration file \"" + conf_file + "\" can't be oppened")
