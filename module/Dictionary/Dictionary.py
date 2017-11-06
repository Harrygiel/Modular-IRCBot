#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Dictionary Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys, requests
from BeautifulSoup import BeautifulSoup

sys.path.append('module')
from BotModule import BotModule


class Dictionary(BotModule):
    """ Class: Dictionary Module Class"""
    def __init__(self, parent, default_module_node):
        super(Dictionary, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return
        msg = self.argument[1]
        target = self.argument[2]

        url = "http://www.larousse.fr/dictionnaires/francais/"
        word_to_find = msg.split(" ")
        url += word_to_find[1].lower() +"/"
        headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        page = requests.get(url, headers=headers)
        if page.status_code >= 300:
            self.c.privmsg(target, "Un problème est survenu en tentant d'acceder au site larousse. Contactez Harrygiel")

        soup = BeautifulSoup(page.text, convertEntities=BeautifulSoup.HTML_ENTITIES)
        definition_array = soup.findAll("li", {"class" : "DivisionDefinition"})
        if len(definition_array) > 0 and definition_array[0].find(text=True) != None:
            definition_text = definition_array[0].find(text=True)
            self.c.privmsg(target, "Définition: " + ''.join(definition_text))
        else:
            self.c.privmsg(target, "Un problème est survenu en tentant de lire la page de définition. Verifiez l'orthographe du mot")
