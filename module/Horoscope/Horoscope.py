#! /usr/bin/env python
# coding: utf8
"""
Chamot V2.0
Horoscope Module

Creator: Harrygiel
"""

from __future__ import unicode_literals

import sys, requests
from BeautifulSoup import BeautifulSoup

sys.path.append('module')
from BotModule import BotModule

class Horoscope(BotModule):
    """ Class: Horoscope Module Class"""
    def __init__(self, parent, default_module_node):
        super(Horoscope, self).__init__(parent, default_module_node)

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False:
            return
        msg = self.argument[1]
        target = self.argument[2]
        url = "http://www.mon-horoscope-du-jour.com/horoscopes/quotidien/"
        data_horoscope = msg.split(" ")
        url += data_horoscope[1][0:20].lower() +".htm"
        headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        page = requests.get(url, headers=headers)
        if page.status_code >= 300:
            self.c.privmsg(target, "Un problème est survenu en tentant d'acceder au site astrologique. Contactez Harrygiel")
            return None

        soup = BeautifulSoup(page.text, convertEntities=BeautifulSoup.HTML_ENTITIES)
        horoscope_text = soup.findAll("p", {"class" : "sp_left sp_right"})

        if len(horoscope_text) > 0 and horoscope_text[0].find(text=True) != None:

            horoscope_text = horoscope_text[0].find(text=True)
            self.c.privmsg(target, "Horoscope: " + ''.join(horoscope_text))
        else:
            self.c.privmsg(target, "Un problème est survenu en tentant de lire la page astrologique. Verifiez l'orthographe du signe")
