#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Modular-IRCBot V2.5
Dictionary Module

Creator: Harrygiel
"""

import requests
from bs4 import BeautifulSoup

from modules.BotModule import BotModule

class Dictionary(BotModule):
    """ Class: Dictionary Module Class"""
    def __init__(self, parent):
        super(Dictionary, self).__init__(parent)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return
        msg = self.argument[1]
        target = self.argument[2]

        splited_msg = msg.split(" ")
        splited_msg = [argument for argument in splited_msg if argument != ""]

        url = "http://www.larousse.fr/dictionnaires/francais/"
        word_to_find = msg.split(" ")
        if len(splited_msg) > 1:
            url += splited_msg[1].lower() +"/"
        else:
            self.c.privmsg(target, "Format : !dico <mot>")
            return
        headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        page = requests.get(url, headers=headers)
        if page.status_code >= 300:
            self.c.privmsg(target, "Un problème est survenu en tentant d'acceder au site larousse. Contactez Harrygiel")
            return

        soup = BeautifulSoup(page.text, "lxml")
        definition_array = soup.findAll("li", {"class" : "DivisionDefinition"})
        if len(definition_array) > 0 and definition_array[0].find(text=True) != None:
            definition_text = definition_array[0].find(text=True)
            self.c.privmsg(target, "Définition: {:.300s}".format(definition_text))
        else:
            self.c.privmsg(target, "Un problème est survenu en tentant de lire la page de définition. Verifiez l'orthographe du mot")
