#! /usr/bin/env python
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.1
Master calling ServerWorker

Creator: Harrygiel
"""

import sys, signal, threading, time, datetime, os.path

sys.path.append('core')
import ServerWorker
import ModuleCoreSystem as MCS
from BotConfParsing import parse_conf

server_dict = {}

def signal_handler(signal_recieved, frame):
    """ Function: handle SIGINT and do a clean stop """
    del signal_recieved, frame
    for server_object in server_dict.values():
        t = threading.Timer(0, server_object.stop)
        t.start()
    time.sleep(1)
    MCS.append_log("Bot stopped")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def main():
    """ Function: Main function of the bot. first one to call """
    start_time = datetime.datetime.now()
    if len(sys.argv) != 2:
        print("Usage: <configurationFile>")
        sys.exit(1)

    MCS.botConfObject = parse_conf(os.path.abspath(os.curdir) + "/" + sys.argv[1])
    MCS.append_log("------------------------------------------------------------")
    MCS.append_log("Bot started at: " + str(start_time))
    MCS.append_log("Configuration loaded")
    for server in MCS.botConfObject.xpath("/botConf/server"):

        server_object = ServerWorker.Worker(server)
        server_dict.update({server.get("url"): server_object})
        server_object.run()

    MCS.append_log("Server(s) launched")
    signal.pause()

if __name__ == "__main__":
    main()
