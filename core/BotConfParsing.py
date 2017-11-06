#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
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
