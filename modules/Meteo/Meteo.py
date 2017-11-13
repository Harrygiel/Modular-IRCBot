#! /usr/bin/env python3
# coding: utf8
"""
Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited

Seriously guys, you just have to ask, I want to know who will use this.

Chamot V2.5
Meteo Module

Creator: Harrygiel

YOU WILL NEED A www.wunderground.com API KEY !!!
"""

from lxml import etree
import sys

import core.ModuleCoreSystem as MCS
sys.path.append("modules")
from BotModule import BotModule

class Meteo(BotModule):
    """ Class: Meteo Module Class"""
    def __init__(self, parent):
        super(Meteo, self).__init__(parent)
        self.api_key = MCS.botConfObject.xpath(MCS.DEFAULTCONFPATH + "/module[@name='Meteo']")[0].text

    def call_handle(self):
        """ Method: executed when the module event is raised """
        if self.start_with_call_set() is False or "chamot" in self.argument[0].nick.lower():
            return
        sender = self.argument[0]
        msg = self.argument[1]
        target = self.argument[2]

        splited_msg = msg.split(" ")
        splited_msg.pop(0)
        splited_msg = [argument for argument in splited_msg if argument != ""]

        if len(splited_msg) == 0 or splited_msg[0].lower == "help":
            self.c.privmsg(target, "Meteo: !meteo <ville> [pays]")
            return

        if len(splited_msg) == 1:
            splited_msg.append("FR")
        url = "http://api.wunderground.com/api/{:.20s}/forecast/lang:FR/q/{:.20s}/{:.20s}.xml".format(self.api_key, splited_msg[1], splited_msg[0].lower())
        api_xml = etree.parse(url)

        if len(api_xml.xpath("/response/result")) > 0:
            self.c.privmsg(target, "Meteo: Plusieurs résultats ont été trouvé pour ce lieu. veuillez affiner votre recherche")
            return
        elif len(api_xml.xpath("/response/error")) > 0:
            self.c.privmsg(target, "Meteo: {:.100s}".format(api_xml.xpath("/response/error/description")[0].text))
            return

        forecastday = api_xml.xpath("/response/forecast/txt_forecast/forecastdays/forecastday/period[text()='0']/..")
        if len(forecastday) > 0:
            forecast = forecastday[0].xpath("fcttext_metric")
            forecast_txt = forecast[0].text

        self.c.privmsg(self.argument[2], "Meteo à {:.20s}: {:.100s}".format(splited_msg[0], forecast_txt))
