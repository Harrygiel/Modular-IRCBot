#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
ServerWorker Calling ChannelWorker

Creator: Harrygiel
"""

import sys, time, threading, time
import irc.bot, irc.strings

sys.path.append('core')
import ChannelWorker
from module.AdminModule import AdminModule

import JaracoBuffer as buffer
irc.client.ServerConnection.buffer_class = buffer.LenientDecodingLineBuffer

class Worker(irc.bot.SingleServerIRCBot):
    """ Class: ServerWorker Class """
    def __init__(self, server_node):
        self.url = server_node.get("url")
        self.nickname = server_node.xpath("botinfo")[0].get("name")
        self.password = server_node.xpath("botinfo")[0].get("password")
        self.server_node = server_node
        self.channel_dict = {}
        self.admin_module_object = AdminModule(self)
        self.thread = threading.Thread(target=self._main, name=self.url)
        self.thread.daemon = True
        irc.bot.SingleServerIRCBot.__init__(self, [(self.url, int(server_node.get("port")))], self.nickname, self.nickname)

    def run(self):
        self.thread.start()

    def _main(self):
        self.start()


    def stop(self):
        for channel_object in self.channel_dict.values():
            channel_object.stop()
        self.die()

    def on_nicknameinuse(self, c, e):
        del e
        c.nick(c.get_nickname() + "_")

    def on_connect(self, c, e):
        del c, e

    def on_welcome(self, c, e):
        del e
        self.c = c
        self.admin_module_object.run(c)
        for channel in self.server_node.xpath("salon"):
            self.join_chan(channel)
        time.sleep(1)
        self.c.privmsg("Themis", u"IDENTIFY " + self.password)
        c.mode("Chamot", "+B")
        print("[" + self.url + "] identified as " + self.nickname + " and as a bot")

    def on_privnotice(self, c, e):
        del c, e

    def on_privmsg(self, c, e):
        del c
        if self.admin_module_object.call in e.arguments[0]:
            self.admin_module_object.argument = [e.source, e.arguments[0], e.source]
            self.admin_module_object.callEvent.set()
            return None

        for channel_name, channel_object in self.channel_dict.items():
            if channel_name.lower() in e.arguments[0]:
                channel_object.argument = [e.source, e.arguments[0], channel_name.lower()]
                channel_object.callEvent.set()

    def on_pubmsg(self, c, e):
        del c
        for channel_name, channel_object in self.channel_dict.items():
            if channel_name == e.target:
                channel_object.argument = [e.source, e.arguments[0], e.target]
                channel_object.callEvent.set()

    def on_kick(self, c, e):
        self.c.join(e.target)
        del c

    def join_chan(self, channel_node):
        channel_worker_object = ChannelWorker.Worker(self.c, channel_node, self)
        channel_worker_object.run()
        self.channel_dict.update({channel_node.get("name"): channel_worker_object})

    def part_chan(self, channel_name):
        self.channel_dict[channel_name].stop()
        self.channel_dict.pop(channel_name, None)
        self.c.part(channel_name)

    def update_module_list(self):
        for channel_object in self.channel_dict.values():
            channel_object.update_module_list()
