# Modular IRCBot

[Features](https://github.com/Harrygiel/Modular-IRCBot#features)

[WARNING](https://github.com/Harrygiel/Modular-IRCBot#warning) 
   
[Getting Started](https://github.com/Harrygiel/Modular-IRCBot#getting-started) 

----[Prerequisites](https://github.com/Harrygiel/Modular-IRCBot#prerequisites) 
   
----[Installing the script](https://github.com/Harrygiel/Modular-IRCBot#installing-the-script)
   
----[Using the script](https://github.com/Harrygiel/Modular-IRCBot#using-the-script) 
   
----[Updating the script](https://github.com/Harrygiel/Modular-IRCBot#updating-the-script)
   
[Questions](https://github.com/Harrygiel/Modular-IRCBot#questions)

[Changelog](https://github.com/Harrygiel/Modular-IRCBot#changelog)

[To Do](https://github.com/Harrygiel/Modular-IRCBot#to-do)

[Authors](https://github.com/Harrygiel/Modular-IRCBot#authors)

[License](https://github.com/Harrygiel/Modular-IRCBot#license)

##Features

##WARNING

This script is for now a one-man made project. Some weird bug can be found. Be warned that I can't give you any warranty except "It work for me".  
Because the bot is created for a french server, a lot of native module will have french strings. However, the log system and the administation module are fully in english.

## Getting Started

### Prerequisites

We need to differenciate core and module prerequistes. You will NEED to install core prerequistes to launch the bot. On the other hand, module prerequiste are only linked to the module you use. A list of native module prerequistes will however be given here.

#### For the core

You will need Python 3
You will need modules irc, lxml

```
sudo apt-get install python3 python3-irc python3-lxml
```

#### For the modules

Every module can have his own dependency

For HTML request, used by horoscope,dictionary and youtube module, you will need modules requests and beautifulsoup4

```
sudo apt-get install python3-requests python3-bs4
```

### Installing the script

For now, no installation are needed. You will just have to execute the Master script (Master.py in the root of the project)

You will need to create your own configuration file, following the example one. Because of the developpement speed and the fact that I'm working alone, it CAN happen that I frogot to update the configuration file with the new parameter. If you have a problem with botConfObject, you can PM me and I will update the example

### Using the script

#### Start the script

to launch the script, simply go to the root of the project and call:

```
python3 Master.py conf/<your_configuration_file_name>
```

#### Command

Every module have his set of command. Every module should have a !help <module> call, but if it's not the case... well... good luck.
Because the bot is created for a french server, a lot of native module will have french strings. For now, no module translation is planned.

The administation module is fully in english
Here's a list of command set by the administration module, and a description. Commands are case sensitive.

"!admin connect <channel>":
Allow channel connexion

"!admin disconnect <channel>":
Allow channel disconnexion

"!admin start <module> <channel>":
Add a module to the said channel

"!admin stop <module> <channel>":
Remove a module to the said channel

"!admin addAdmin <pseudo!~realname@host> <level> <range>":
Add an (COMPLETE) admin mask on the said range at the said level (if level = 0, remove the admin)

"!admin delAdmin <pseudo!~realname@host> <range>":
Remove an (COMPLETE) admin mask on the said range at the said level

"!admin saveConf <xml_file>":
Allow to save the bot configuration as a file WARNING, you can erease the actual configuration file !

"!admin list <info> <range>"
Allow an admin to get an infomation about the said range

"!admin dump":
Print the full configuration IN MEMORY to the bash

"!admin reload <range>":
Alow to reload everything under the said range (servers, channels, modules)

#### Adding a module

To add a module, you will have to:
1) Create a new folder and put the module .py in this folder. The .py, the folder and the module sub-class in the file need to have the EXACT SAME NAME.
2) Add a line MANUALLY in the configuration file in the defaultconf node with the name of the folder. 
3) Restart the bot. One day you will be able to reload the configuration, or even look if a folder given in argument exist in "module/". But not now, sadly.

### Updating the script

You should be able to simple replace old file by new one. if any information about incompatibility is found, you will see it in the changelog or here.

## Questions

```
Q: The script is not working !
```
A: Read this file COMPLETELY first, then if nothing work, post an issue or/and contact me.


```
Q: I have a perfect idea for the script or for a module!
```
A: 2 solutions: Clone the git, create a branch, add your feature, do a CLEAN pull request, with description of your work, and wait. Or ask nicely and maybe one day, somebody will add it for you.

```
Q: I can add a feature, but I don't have any idea!
```
A: Great ! Just ask around, I'm pretty sure some people have great idea.

```
Q: After an update, the script is not working anymore!
```

Have you look at the [Updating the script](https://github.com/Harrygiel/Modular-IRCBot#updating-the-script) part ? If it's still not working, send an issue

```
Q: This script corrupted my user, computer, my house and burnt my dog !
```
A: Wow seriously ? What a powerful bot. No seriously you where prevented that it's a one-man made project and that some bug could be found. send me an issue or/and contact me.

## Changelog

########   V2.1.2

- Corrected Youtube module urllib problem by
using request instead (1 less module to import)
- More call to log
- Every thread now have a unique name linked to
his position in the configuration
- Admin are now able to list module and admin in
a node
- Created a general lib function to check for
info recursively: recursively_scan_node_info
- Replaced is_module_globally_activated and
is_user_globally_admin by the new general function

* V2.1.1

- Corrected Buffer error when the message recieved
was not in UTF-8
- Corrected README.TXT for GitHub display

* V2.1

- Project added on github
- Update from python 2.7 to python 3.5.3
- Bot now auto reconnect from disconnect and kick
- Added login info in XML
- Add basic admin level
- Better and more complete README.TXT

* Before

See Changelog

## To Do

From 0 (least important) to 5 (most important)
                                                      (priority)
- Seen, Spotify, deezer and co modules                     0
- Add Nose to the cover project                            0
- Add warning possibility for desactivated modules         1
- Clear every code smell                                   1
- Allow start module only if module exist                  1
- Allow admin to list every module recursively             1
- Allow admin to list every admin recursively              1
- Allow configuration reload from file                     1
- Allow admin to list recursively                          2
- Add Schedule event possibility                           2
- Comment channel node on disconnection to keep conf       2
- Allow bot name to be changed (code AND /nick)            2
- Send PV message at user connexion (remember)             2
- Allow load by name, and not only if in defaultconf        
(useful to load a module without restarting)               2
- Allow regexp in admin mask                               3
- Allow use of official admin from channel                 3
- Act from bash as superadmin                              3
- Module: Protect from mass AND flood HL                   3
- Add Blacklist                                            3
- Auto check running module and reboot it in case          
of crash                                                   4
- Auto fix and analysis                                    4

## Authors

### import module

The IRC module is fully created by jaraco and contributors at https://github.com/jaraco/irc
The buffer module is fully created by jaraco and contributors at https://github.com/jaraco/jaraco.stream

### Core script

Script core created by Harrygiel and contributors at https://github.com/Harrygiel/Modular-IRCBot (can be found at irc.epiknet.org or sometime at harrygiel [at] gmail [dot] com )

### Modules

The modules are created by their main author. Native modules are created by Harrygiel

Harrygiel: Youtube Dictionary Horoscope Help Love Oracle Ko Cafe Amour

## License

Copyright (C) Harrygiel - All Rights Reserved
Unauthorized use of this file or any file from this project, via any medium is strictly prohibited.

Seriously guys, you just have to ask, I want to know who will use this.
If you send a PM on github AND on my mail, and I didn't answered for more than 1 month, you can take this as an implicit agreement to use my bot for anything except commercial use.