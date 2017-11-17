 ##############################################################################
#
# HaploPhone      (ex Menz Agitat's Soundex)
# v3.0 (09/06/2015)   �2009-2015 Menz Agitat
#
# IRC: irc.epiknet.org  #boulets / #eggdrop
#
# Mes scripts sont t�l�chargeables sur http://www.eggdrop.fr
# Retrouvez aussi toute l'actualit� de mes releases sur
# http://wiki.eggdrop.fr/Utilisateur:MenzAgitat
#
 ##############################################################################


#
# Description
#
# HaploPhone est un algorithme phon�tique inspir� du fonctionnement de Soundex
# (http://fr.wikipedia.org/wiki/Soundex).
#
# Il est cependant bien plus pr�cis que l'algorithme d'origine car il a �t�
# sp�cifiquement con�u pour tenir compte des r�gles complexes de la
# prononciation fran�aise et retourne une valeur phon�tique simplifi�e plut�t
# qu'une valeur alphanum�rique de longueur fixe.
# Il existe 13 phon�mes simplifi�s diff�rents : A B E I J K L M R S T U et V.
# Reportez-vous � la table de correspondance basique des phon�mes plus bas pour
# savoir � quoi ils correspondent.
#
# Il est possible d'appliquer un certain nombre de filtres et de r�gles, comme
# par exemple de supprimer toutes les voyelles, de ne les supprimer qu'en fin de
# mot, ou encore de g�n�rer une cha�ne de caract�res de longueur fixe.
# De plus, HaploPhone �tant capable de traiter des s�quences de mots en une
# seule fois, vous n'�tes pas oblig� de les lui soumettre un par un.
#
# Ce programme a �t� con�u � force d'exp�rimentations et d'essais / erreurs, et
# ne pr�tend pas avoir une approche scientifique. N�anmoins, de nombreux textes
# et mots lui ont �t� soumis afin d'en parfaire le fonctionnement.
# Il se base sur un nombre cons�quent de r�gles et d'exceptions et non pas sur
# le contexte, ce qui ne lui permettra pas de faire la diff�rence entre
# "couvent" du verbe couver et l'�difice religieux homonyme.
# Certaines concessions ont donc d� �tre faites et en cas de conflit, la
# prononciation la plus courante sera retenue.
#
# L'int�r�t de ce genre d'algorithme est par exemple de comparer 2 phrases
# orthographi�es diff�remment et de pouvoir d�terminer si elles sont
# �quivalentes ou non d'un point de vue phon�tique.
# Ce principe est utilis� par les correcteurs orthographiques, les moteurs de
# recherche qui s'en servent pour faire des suggestions, et pr�sente un
# int�r�t en ce qui concerne l'intelligence artificielle.
#
# Pour son fonctionnement interne, ce script utilise certains caract�res en
# guise de marqueurs. Vous devrez donc veiller � ce qu'ils ne soient jamais
# utilis�s dans les cha�nes de caract�res que vous lui soumettrez.
# Ces cinq caract�res r�serv�s sont les suivants : � � � � �
# 
# Ce script pourvoit l'eggdrop du package HaploPhone 3.0
#
 ###############################################################################

#
# Syntaxe
#
# ::HaploPhone::process [-makespaces] [-keepchars "caract�res � pr�server"] [-filters nnn] [-length n] <cha�ne de caract�res>
#
# -makespaces provoque le remplacement de tous les caract�res qui ne sont pas
# des lettres par des espaces.
#
# -keepchars force le HaploPhone � pr�server les caract�res que vous sp�cifiez.
# Par d�faut, tous les caract�res qui ne sont pas des lettres sont filtr�s.
# Les caract�res que vous excluez doivent �tre proprement �chapp�s si
# n�cessaire, notamment les caract�res suivants : } { ] [ " $ \
#
# -filters permet de d�finir les modes de filtrage.
#	nnn est une succession de 3 chiffres ayant chacun une signification et pouvant
#	prendre plusieurs valeurs.
# 1er chiffre : mode de traitement des voyelles (vaut 1, 2 ou 3).
#		1- Traitement standard des voyelles.
#		2- Toutes les voyelles sont remplac�es par le caract�re g�n�rique "A", �
#			l'exception des E en fin de mot.
#		3- Toutes les voyelles sont supprim�es. Si un mot n'est constitu� que de
#			voyelles, retourne "A".
# 2�me chiffre : mode de traitement des voyelles en fin de mot (vaut 1 ou 2).
#		1- Les "E" sont supprim�s en fin de mot, sauf s'il ne reste qu'une lettre.
#		2- Toutes les voyelles sont supprim�es en fin de mot, sauf s'il ne reste
#			qu'une lettre.
# 3�me chiffre : mode de gestion des successions de voyelles (vaut 1 ou 2).
#		1- Gestion standard des successions de voyelles.
#		2- Si plusieurs voyelles se suivent, on ne conserve que la 1�re.
# En l'absence de l'argument -filters, les valeurs par d�faut sont 111.
#
# -length permet de d�finir une longueur fixe pour la valeur phon�tique
# retourn�e par chaque mot.
# Si length est sp�cifi� et qu'un mot est trop long, il sera tronqu� pour
# atteindre la bonne longueur.
# Si length est sp�cifi� et qu'un mot est trop court, il sera compl�t� par des 0
# pour atteindre la bonne longueur.
# Si length n'est pas sp�cifi� ou vaut 0, la valeur aura une longueur variable
# d�pendant de la longueur du mot.
#
# L'ordre des arguments n'est pas important.
#
# Dans le but d'accro�tre la rapidit� d'ex�cution, la validit� de la syntaxe de
# la commande n'est pas v�rifi�e. Veillez donc � la respecter scrupuleusement,
# sans quoi le script ne fonctionnera pas comme pr�vu et vous n'en serez pas
# explicitement averti.
#
 ###############################################################################

#
# Exemples
#
# Penons un exemple :
#		::HaploPhone::process "ceci est un test qui fonctionne !"
#		-> SESIEATESTKIVAKSIAM
#
#	P�servation du d�coupage :
#		::HaploPhone::process -makespaces "ceci est un test qui fonctionne !"
#		-> SESI E A TEST KI VAKSIAM
#
#	En �crivant n'importe comment, on arrive au m�me r�sultat :
#		::HaploPhone::process -makespaces "seussies aie hein teiste ki fonksione"
#		-> SESI E A TEST KI VAKSIAM
#
# On peut conserver les caract�res qu'on veut :
#		::HaploPhone::process -makespaces -keepchars ",!" "ceci est un test, qui fonctionne !"
#		-> SESI E A TEST, KI VAKSIAM !
#
# Essayons un autre exemple pour voir comment les filtres fonctionnent.
# En l'absence du param�tres -filters, c'est comme si on avait -filters 111,
# ce qui signifie qu'on supprime les E en fin de mot :
#		::HaploPhone::process -makespaces "oui je crache les noyaux moins loin que vous"
#		-> UI J KRAJ L MUAIA MUA LUA K VU
#
# Toutes les voyelles sont remplac�es par le caract�re g�n�rique "A",
# � l'exception des E en fin de mot :
#		::HaploPhone::process -makespaces -filters 211 "oui je crache les noyaux moins loin que vous"
#		-> A J KRAJ L MA MA LA K VA
#
# Toutes les voyelles sont supprim�es. Si un mot n'est constitu� que de
# voyelles, retourne "A" :
#		::HaploPhone::process -makespaces -filters 311 "oui je crache les noyaux moins loin que vous"
#		-> A J KRJ L M M L K V
#
# Toutes les voyelles sont supprim�es en fin de mot, sauf s'il ne reste qu'une
# lettre :
#		::HaploPhone::process -makespaces -filters 121 "oui je crache les noyaux moins loin que vous"
#		-> U J KRAJ L M M L K V
#
# Si plusieurs voyelles se suivent, on ne conserve que la 1�re :
#		::HaploPhone::process -makespaces -filters 112 "oui je crache les noyaux moins loin que vous"
#		-> U J KRAJ L MU MU LU K VU
#
# Longueur fix�e � 4 :
#		::HaploPhone::process -makespaces -length 4 "oui je crache les noyaux moins loin que vous"
#		-> UI00 J000 KRAJ L000 MUAI MUA0 LUA0 K000 VU00
#
 ###############################################################################

#
#	Table de correspondance basique des phon�mes
#
# A = A / O / AN / IN / ON
# B = B / P
# E = E / AI / OE
# I = I
# J = J / CH / TCH
# K = K / GU
# L = L
# M = M / N
# R = R
# S = S / X / Z (dans certains cas seulement pour X, dans les autres cas il �quivaut � KS)
# T = T / D
# U = U / OU
# V = V / F
#
 ###############################################################################

#
#	Changelog
#
# 1.0
#		- 1�re version
# 1.01
#		- Compression des double phon�mes cons�cutifs apr�s suppression des espaces.
#		- Correction d'une incoh�rence sur les phon�mes de classe "CH", ils �taient
#			ignor�s (merci � Artix de me l'avoir signal�).
#		- Am�lioration de la rapidit� de 2 regexp, merci � Artix (encore).
# 1.02
#		- Diff�renciation des phon�mes sifflants S X Z C G J et des phon�mes
#			gutturaux GA GO GU QU Q K et C (si C n'est pas suivi par E/I/Y).
# 2.0
#		- Ajout d'une option -keepspaces.
#		- Ajout d'une option -keepchars <caract�res non-alphanum�riques � pr�server>
#		- Correction d'un bug qui laissait parfois les voyelles en fin de mot.
#		- Le soundex ne retourne plus d'erreur lorsqu'on lui envoie une cha�ne de
#			caract�res ne contenant aucun caract�re alphab�tique.
#		- Prise en compte de nombreux nouveaux phon�mes et cas particuliers.
#		- G et J ont quitt� le groupe phon�tique des S/X/Z pour rejoindre celui
#			des CH.
#		- Le soundex pr�serve d�sormais les sons voyelles riches comme dans "noyau"
#			ou "ouailles".
#		- Les phon�mes ouverts sont maintenant pr�serv�s en fin de mot s'ils se
#			prononcent. Par exemple dans "mis�e" mais pas dans "mise".
#		- Quelques optimisations pour la rapidit�.
# 2.01
#		- Correction d'un probl�me sans cons�quences dans la prise en compte des
#			arguments de la commande.
#		- Passage sous licence Creative Commons.
# 2.1
#		- Les caract�res non alphab�tiques supprim�s lors du filtrage sont d�sormais
#			consid�r�s comme des espaces plut�t que comme rien.
#			Par exemple, "porte-cl�" �tait remplac� par "portecl�" au lieu de
#			"porte cl�", ce qui peut avoir une influence sur la phon�tique dans
#			certains cas.
# 2.2
#		- Correction : les chiffres ne sont plus consid�r�s comme valeurs de soundex
#			lors du traitement, et sont d�sormais pr�serv�s.
#		- Correction : l'option -keepchars ne supportait pas les "@".
#		- Correction : la pr�servation des sons voyelles riches ne fonctionnait que
#			pour la 1�re occurrence.
# 3.0
#		- Le terme "soundex" d�signant un algorithme sp�cifique qui n'a plus rien
#			� voir avec ce que fait ce script, ce dernier change de nom pour
#			HaploPhone.
#		- Modification radicale du fonctionnement du script en vue de le rendre
#			plus pr�cis et plus fiable. La plupart des exceptions et subtilit�s de
#			prononciation de la langue fran�aise sont maintenant prises en compte.
#		- Le script ne retourne d�sormais plus une valeur num�rique mais une valeur
#			phon�tique simplifi�e.
#		- Les chiffres sont d�sormais filtr�s par d�faut, au m�me titre que les
#			autres caract�res non-alphab�tiques.
#		- Ajout des nouveaux param�tres -makespaces -filters et -length.
#		- Ajout : une aide � la syntaxe est donn�e dans l'erreur retourn�e par la
#			commande ::HaploPhone::process si elle est utilis�e sans arguments.
#		- Le param�tre -keepspaces a �t� abandonn� puisque le m�me effet peut �tre
#			obtenu avec -keepchars ou -makespaces
#
 ###############################################################################

#
# Licence
#
#		Cette cr�ation est mise � disposition selon le Contrat
#		Attribution-NonCommercial-ShareAlike 3.0 Unported disponible en ligne
#		http://creativecommons.org/licenses/by-nc-sa/3.0/ ou par courrier postal �
#		Creative Commons, 171 Second Street, Suite 300, San Francisco, California
#		94105, USA.
#		Vous pouvez �galement consulter la version fran�aise ici :
#		http://creativecommons.org/licenses/by-nc-sa/3.0/deed.fr
#
 ###############################################################################


 #############################################################################
### Initialisation
 #############################################################################

if {[::tcl::info::commands ::HaploPhone::uninstall] eq "::HaploPhone::uninstall"} { ::HaploPhone::uninstall }

namespace eval ::HaploPhone {
	variable scriptname "HaploPhone (ex Menz Agitat's Soundex)"
  variable version "3.0.20150609"
	package provide HaploPhone 3.0
	proc uninstall {args} {
		putlog "D�sallocation des ressources de \002$::HaploPhone::scriptname...\002"
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		package forget HaploPhone
		namespace delete ::HaploPhone
	}
}

 ###############################################################################
### G�n�ration d'une valeur phon�tique � partir d'une cha�ne de caract�res
 ###############################################################################
proc ::HaploPhone::process {args} {
	if { $args eq "" } {
		error "wrong # args: should be \"[::tcl::info::level 0] ?-makespaces? ?-keepchars chars? ?-filters nnn? ?-length n? string\""
	}
	# Options par d�faut
	set keepchars ""
	set vowel_mode 1
	set end_vowel_mode 1
	set vowel_sequence_mode 1
	set fixed_length 0
	set replace_non_alpha_chars_by_spaces 0
	# Prise en compte des arguments en ligne de commande
	set skip 0 ; set counter 0
	foreach argument $args {
		switch -- $argument {
			"-filters" - "-filter" {
				lassign [split [lindex $args $counter+1] ""] vowel_mode end_vowel_mode vowel_sequence_mode
				set skip 1
			}
			"-length" {
				set fixed_length [lindex $args $counter+1]
				set skip 1
			}
			"-keepchars" {
				set keepchars [lindex $args $counter+1]
				set skip 1
			}
			"-makespaces" {
				set replace_non_alpha_chars_by_spaces 1
			}
			default {
				if { $skip } {
					set skip 0
					incr counter
					continue
				} else {
					set data $argument
				}
			}
		}
		incr counter
	}
	# Neutralisation des caract�res de $keepchars pouvant avoir une signification
	# particuli�re pour les expressions r�guli�res.
	if { $keepchars ne "" } {
		regsub -all {\W} $keepchars {\\&} keepchars
	}
	# Prise en compte des accents significatifs et suppression des autres.
	set data [::tcl::string::toupper [::tcl::string::map -nocase {
		"�" "a" "�" "a" "�" "a" "�" "a" "�" "a" "�" "a" "�" "a" "�" "a" "�a" "eha"
		"�i" "ehi" "�u" "ehu" "�" "e" "�" "e" "�" "e" "gu�" "ku" "�" "e" "�" "i"
		"�" "y" "�" "i" "�" "i" "�" "i" "�" "o" "�" "o" "�" "o" "�" "o" "�" "o"
		"�" "o" "�" "u" "�" "u" "�" "u" "�" "u" "�" "y" "�" "y" "�" "s" "�" "d"
		"�" "n" "�" "s" "�" "z"
	} $data]]
	# Elimination de tous les caract�res qui ne sont ni des lettres, ni des
	# caract�res pr�serv�s au moyen du param�tre keepchars, ni des espaces.
	regsub -all "\[^a-zA-Z$keepchars\\s\]" $data "�" data
	# Si � ce stade on n'a plus rien, inutile d'aller plus loin.
	if { $data eq "" } {
		return $data
	}
	# Ajout d'un marqueur de d�but/fin � chaque mot.
	# Remarque : l'ajout de marqueurs permet de s'affranchir du besoin d'utiliser
	# les expressions r�guli�res, qui sont beaucoup plus lentes � traiter que les
	# remplacements par string map.
	regsub -all {(^|[^[:alpha:]])([[:alpha:]]+)(?![[:alpha:]])} $data {\1�\2�} data
	# Traitement du cas particulier "TION" en fin de mot.
	set data [::tcl::string::map {
		"TION�" "tION�"
	} $data]
	# Traitement des exceptions et des terminaisons dans lesquelles le S final est
	# important.
	set data [::tcl::string::map {
		"�ES�" "�E�" "ROMPS�" "RA�" "�LONGTEMPS�" "�LATA�" "TEMPS�" "TA�"
		"CORPS�" "KAR�" "�AUXQUELS�" "�AKEL�" "�DESDITS�" "�TETI�"
		"�DESDITES�" "�TETITT�" "�DESQUELS�" "�TEKEL�" "�DESQUELLES�" "�TEKEL�"
		"�HAUTBOIS�" "�ABUA�" "�LESDITS�" "�LETI�" "�LESDITES�" "�LETITT�"
		"�LESQUELS�" "�LEKEL�" "�LESQUELLES�" "�LEKEL�" "�MESDAMES�" "�METAM�"
		"�MESDEMOISELLES�" "�METEMUASEL�" "�MESSIEURS�" "�MESI�" "�LAPS�" "�LABSS�"
		"�PEPS�" "�BEBSS�" "�CHIPS�" "�JIBSS�" "�BICEPS�" "�BISEBSS�"
		"�FORCEPS�" "�VARSEBSS�" "�SCHNAPS�" "�JMABSS�" "�TRICEPS�" "�TRISEBSS�"
		"�REPS�" "�REBSS�" "�PRINCEPS�" "�BRASEBS�" "�TURNEPS�" "�TURMEBSS�"
		"�ROLLMOPS�" "�RALMABSS�" "�QUADRICEPS�" "�KATRISEBSS�"
		"�TRICERATOPS�" "�TRISERATABSS�" "�CRAPS�" "�KRABSS�" "�MIPS�" "�MIBSS�"
		"�OUPS�" "�UBS�" "�PEPS�" "�BEBSS�" "�RELAPS�" "�RELABSS�"
		"�AGNUS�" "�AKMUSS�" "�CRAIGNOS�" "�KREMIOSS�" "�GNEISS�" "�KMESS�"
		"�SENS�" "�SA�" "�WINDOWS�" "�UIMDAHUSS�" "�INTERVIEWS�" "�IMTERVIUSS�"
		"�MARSHMALLOWS�" "�MARJMALOHUSS�" "�NEWS�" "�MIUSS�" "�HAS�" "�ASS�"
		"�FILS�" "�VISS�" "�POULS�" "�PU�" "�MARS�" "�MARSS�" "�MOEURS�" "�MERSS�"
		"�OURS�" "�URSS�" "�GERS�" "�JERSS�" "�GARS�" "�KA�" "�ALIAS�" "�ALIASS�"
		"�ATLAS�" "�ATLASS�" "�MAS�" "�MASS�" "�NAS�" "�MASS�" "�SAS�" "�SASS�"
		"�PATARAS�" "�BATARASS�" "�ALOES�" "�ALAHESS�" "�CACATOES�" "�KAKATAHESS�"
		"�DAMOCLES�" "�DAMAKLESS�" "�FACIES�" "�VASIESS�" "�HERPES�" "�ERBESS�"
		"�PALMARES�" "�BALMARESS�" "�XERES�" "�KSERESS�" "�ADONIS�" "�ATAMISS�"
		"�AGROSTIS�" "�AKRASTISS�" "�ANIS�" "�AMISS�" "�AXIS�" "�AKSISS�"
		"�BIS�" "�BISS�" "�BRAHMS�" "�BRAMSS�" "�CANNABIS�" "�KAMABISS�"
		"�CASSIS�" "�KASISS�" "�FRANCIS�" "�VRASISS�" "�CLITORIS�" "�KLITARISS�"
		"�EXTREMIS�" "�EKSTREMISS�" "�GRATIS�" "�KRATISS�" "�IBIS�" "�IBISS�"
		"�IRIS�" "�IRISS�" "�IRSATIS�" "�IRSATISS�" "�JADIS�" "�JATISS�"
		"�LYCHNIS�" "�LIKNISS�" "�MAYS�" "�MAHISS�" "�MAXIS�" "�MAKSISS�"
		"�METIS�" "�METISS�" "�MYOSOTIS�" "�MIASATISS�" "�ORCHIS�" "�ARKISS�"
		"�OXALIS�" "�AXALISS�" "�PELVIS�" "�BELVISS�" "�PENIS�" "�BEMISS�"
		"�PRAXIS�" "�BRAKSISS�" "�PUBIS�" "�BUBISS�" "�PYROSIS�" "�BIRASISS�"
		"�REGIS�" "�REJISS�" "�TENNIS�" "�TEMISS�" "�TOURNEVIS�" "�TURMEVISS�"
		"�VIS�" "�VISS�" "ASIS�" "ASISS�" "ASTIS�" "ASTISS�" "BILIS�" "BILISS�"
		"ESIS�" "ESISS�" "PHILIS�" "VILISS�" "PSIS�" "BSISS�"
		"�ALBATROS�" "�ALBATRASS�" "�ALBINOS�" "�ALBIMASS�" "�AMNIOS�" "�AMIASS�"
		"�CALVADOS�" "�KALVATASS�" "�LAOS�" "�LASS�" "�OS�" "�ASS�"
		"�PATHOS�" "�BATASS�" "�RHINOCEROS�" "�RIMASERASS�" "�TETANOS�" "�TETAMASS�"
		"�THERMOS�" "�TERMASS�" "�ABRIBUS�" "�ABRIBUSS�" "�AEROBUS�" "�AHERABUSS�"
		"�AIRBUS�" "�ERBUSS�" "�ANGELUS�" "�AJELUSS�" "�ANUS�" "�AMUSS�"
		"�ARGUS�" "�ARKUSS�" "�ASPARAGUS�" "�ASBARAGUSS�" "�AUREUS�" "�AREHUSS�"
		"�AUTOBUS�" "�ATABUSS�" "�BIBLIOBUS�" "�BIBLIABUSS�"
		"�BIFIDUS�" "�BIVITUSS�" "�BLOCKHAUS�" "�BLAKASS�" "�BLOCUS�" "�BLAKUSS�"
		"�BONUS�" "�BAMUSS�" "�BUS�" "�BUSS�" "�CAMPUS�" "�KABUSS�"
		"�CHORUS�" "�KARUSS�" "�CIRRUS�" "�SIRUSS�" "�CITRUS�" "�SITRUSS�"
		"�CLAUSUS�" "�KLASUSS�" "�CONSENSUS�" "�KASASUSS�"
		"�CONTRESENS�" "�KATRESASS�" "�CORPUS�" "�KARBUSS�" "�COSMOS�" "�KASMASS�"
		"�COUSCOUS�" "�KUSKUSS�" "�CRESUS�" "�KRESUSS�" "�CROCUS�" "�KRAKUSS�"
		"�CUNNILINGUS�" "�KUMILAKUSS�" "�DIPLODOCUS�" "�TIBLATAKUSS�"
		"�EUCALYPTUS�" "�EKALIBTUSS�" "�FICUS�" "�VIKUSS�" "�FOETUS�" "�VETUSS�"
		"�FONGUS�" "�VAKUSS�" "�FUCUS�" "�VUKUSS�" "�GUGUS�" "�KUKUSS�"
		"�GUS�" "�KUSS�" "�HIATUS�" "�IATUSS�" "�HIBISCUS�" "�IBISKUSS�"
		"�HUMERUS�" "�UMERUSS�" "�HUMUS�" "�UMUSS�" "�ICTUS�" "�IKTUSS�"
		"�INFARCTUS�" "�AVARKTUSS�" "�LOTUS�" "�LATUSS�" "�MALUS�" "�MALUSS�"
		"�MINIBUS�" "�MIMIBUSS�" "�MINUS�" "�MIMUSS�" "�MORDICUS�" "�MARTIKUSS�"
		"�MOTUS�" "�MATUSS�" "�MUCUS�" "�MUKUSS�" "�MUROS�" "�MURASS�"
		"�NYSTAGMUS�" "�MISTAKMUSS�" "�OCULUS�" "�AKULUSS�" "�OMNIBUS�" "�AMIBUSS�"
		"�OPUS�" "�ABUSS�" "�PAPYRUS�" "�BABIRUSS�" "�PHALLUS�" "�VALUSS�"
		"�PLUS�" "�BLU�" "�PROCESSUS�" "�BRASESUSS�" "�PROSPECTUS�" "�BRASBEKTUSS�"
		"�PROTEUS�" "�BRATEHUSS�" "�PRUNUS�" "�BRUMUSS�" "�REBUS�" "�REBUSS�"
		"�RHESUS�" "�RESUSS�" "�RICTUS�" "�RIKTUSS�" "�SANCTUS�" "�SAKTUSS�"
		"�SPECULAUS�" "�SBEKULASS�" "�STEGOSORUS�" "�STEKASARUS�"
		"�STIMULUS�" "�STIMULUSS�" "�SUS�" "�SUSS�" "�TERMINUS�" "�TERMINUSS�"
		"�THALAMUS�" "�TALAMUSS�" "�THESAURUS�" "�TESARUSS�" "�THYMUS�" "�TIMUSS�"
		"�TITUS�" "�TITUSS�" "�TONUS�" "�TAMUSS�" "�TOURNUS�" "�TURMUSS�"
		"�TOUS�" "�TUSS�" "�TROLLEYBUS�" "�TRALEBUSS�" "�TUMULUS�" "�TUMULUSS�"
		"�TYPHUS�" "�TIVUSS�" "�URANUS�" "�URANUSS�" "�US�" "�USS�"
		"�UTERUS�" "�UTERUSS�" "�VALGUS�" "�VALKUSS�" "�VERSUS�" "�VERSUSS�"
		"�XERUS�" "�KSERUSS�" "CACTUS�" "KAKTUSS�" "CUBITUS�" "KUBITUSS�"
		"CUMULUS�" "KUMULUSS�" "CURSUS�" "KURSUSS�" "FOCUS�" "VAKUSS�"
		"IUS�" "IUSS�" "LAPSUS�" "LABSUSS�" "NIMBUS�" "NABUSS�"
		"NUCLEUS�" "MUKLEHUSS�" "NUCLHEHUS�" "MUKLEHUSS�" "SAURUS�" "SARUSS�"
		"STRATUS�" "STRATUSS�" "SINUS�" "SIMUSS�" "THUS�" "TUSS�"
		"THALAMUS�" "TALAMUSS�" "VIRUS�" "VIRUSS�" "XUS�" "KSUS�" "�LYS�" "�LISS�"
		"�PAYS�" "�BEHI�"
	} $data]
	# Suppression du S �ventuel en fin de mot.
	regsub -all {([[:alpha:]])S(?![[:alpha:]])} $data {\1} data
	# Traitement du cas particulier TION = SION.
	set data [::tcl::string::map -nocase {
		"�CAtION�" "�CATIA�" "�BAStION�" "�BASTIA�" "�COGNAtION�" "�KAKMASIA�"
		"LAtION" "LASIA" "CtION" "KSIA" "CCREtION" "KRESIA" "SECREtION" "SEKRESIA"
		"UJEtION" "UJESIA" "ELEtION" "ELESIA" "PLEtION" "PLESIA"
		"NCREtION" "NKRESIA" "SCREtION" "SKRESIA" "XCREtION" "KSKRESIA"
		"�EDItION" "�ETISION" "EEDItION" "EETISION" "OEDItION" "OHETISION"
		"PEDItION" "BETISION" "SEDItION" "SETISION" "OLItION" "OLISION"
		"UDItION" "UTISION" "DDItION" "TISION" "GNItION" "MISION" "NItION" "MISION"
		"IBItION" "IBISION" "NSItION" "NSISION" "MBItION" "MBISION"
		"TItION" "TISION" "ONDItION" "ADISION" "OSItION" "OSISION"
		"TRADItION" "TRATISION" "QUISItION" "KISISION" "INTUItION" "ATUISION"
		"NUTRItION" "MUTRISION" "PARItION" "BARISION" "ABSTENtION" "ABSTASIA"
		"TTENtION" "TASIA" "NTENtION" "NTENSIA" "ETENtION" "ETASION"
		"UTENtION" "UTASIA" "BTENtION" "BTASIA" "RETENtION" "RETASIA"
		"RAVENtION" "RAVASIA" "REVENtION" "REVASIA" "NVENtION" "NVASIA"
		"ERENtION" "ERASIA" "RVENtION" "RVASIA" "BVENtION" "BVASIA"
		"�MENtION" "�MASIA" "�SUSMENtION" "�SUSMASIA" "ABLUtION" "ABLUSIA"
		"ALBUtION" "ALBUSIA"
	} $data]
	# Traitement des exceptions et particularit�s de prononciation.
	set data [::tcl::string::map {
		"�UN�" "�A�" "�AN�" "�A�" "�C�" "�S�" "�CA�" "�SA�" "�EST�" "�E�"
		"ACCROC�" "AKRA�" "�ANTITABAC�" "�ATITABA�" "�BANC�" "�BA�"
		"�BLANC�" "�BLA�" "�CAOUTCHOUC�" "�KAHUJU�" "�CLERC�" "�KLERR�"
		"�CONVAINC�" "�KAVA�" "�CROC�" "�CRO�" "�ESCROC�" "�ESKRA�"
		"�ESTOMAC�" "�ESTAMA�" "�EUROFRANC�" "�ERAVRA�" "�FLANC�" "�VLA�"
		"�FRANC�" "�VRA�" "JONC�" "JA�" "�KILOFRANC�" "�KILAVRA�" "�MARC�" "�MAR�"
		"�PORC�" "�BAR�" "�TABAC�" "�TABA�" "�TRONC�" "�TRA�" "�VAINC�" "�VA�"
		"�ASPECT�" "�ASB�" "�CIRCONSPECT�" "�SIRKASB�" "�DISTINCT�" "�TISTA�"
		"�INDISTINCT�" "�ATISTA�" "�INSTINCT�" "�ASTA�" "�IRRESPECT�" "�IRESB�"
		"�PROSPECT�" "�BRASB�" "�RESPECT�" "�RESB�" "�SUCCINCT�" "�SUKSA�"
		"�SUSPECT�" "�SUSB�" "�HARENG�" "�ARA�" "�BARLONG�" "�BARLA�"
		"�DUGONG�" "�TUKA�" "�LONG�" "�LA�" "�OBLONG�" "�ABLA�" "�ETANG�" "�ETA�"
		"�RANG�" "�RA�" "�SANG�" "�SA�" "AING�" "A�" "�END�" "�EMT�"
		"�TREND�" "�TREMT�" "�CHALAND�" "�JALA�" "�GLAND�" "�KLA�"
		"�GOELAND�" "�KAHELA�" "LAND�" "LAMT�" "�HAND�" "�AMT�" "�RAND�" "�RAMT�"
		"�STAND�" "�STAMT�" "�SEPT�" "�SETT�" "�EXEMPT�" "�EKSA�" "COMPT" "KAT"
		"BAPT" "BAT" "SCULPT" "SKULT" "ROMPT�" "RA�" "�GALOP�" "�KALA�"
		"�SALOP�" "�SALA�" "�SIROP�" "�SIRA�" "�TROP�" "�TRA�" "COUP�" "KU�"
		"�LOUP�" "�LU�" "�CANTALOUP�" "�KATALU�" "DRAP�" "TRA�" "PIED�" "PIE�"
		"SIED�" "SIE�" "COUD�" "KU�" "MOUD�" "MU�" "ADEQUAT�" "ATEKUATT�"
		"�FAT�" "�VATT�" "�FIAT�" "�VIATT�" "�KUMQUAT�" "�KUMKUATT�"
		"�KHAT�" "�KATT�" "�PAT�" "�BATT�" "�SQUAT�" "�SKUATT�" "�SCAT�" "�SKATT�"
		"�SWAT�" "�SUATT�" "�TRANSAT�" "�TRASATT�" "�ZIGGOURAT�" "�SIKURATT�"
		"�BASKET�" "�BASKETT�" "�CET�" "�SETT�" "�CRICKET�" "�KRIKETT�"
		"�ETHERNET�" "�ETERMETT�" "�EXOCET�" "�EKSASETT�"
		"�EXTRANET�" "�EKSTRAMETT�" "�FRET�" "�VRETT�" "�GADGET�" "�KATJETT�"
		"�INTERNET�" "�ATERMETT�" "�INTRANET�" "�ATRAMETT�" "�MAGNET�" "�MAMIETT�"
		"�NET�" "�METT�" "�NIET�" "�MIETT�" "�NUGGET�" "�MUKETT�"
		"�OFFSET�" "�AVSETT�" "POCKET�" "BAKETT�" "�POUET�" "�BUETT�"
		"�RACKET�" "�RAKETT�" "�ROCKET�" "�RAKETT�" "�SET�" "�SETT�"
		"�SOCKET�" "�SAKETT�" "�SOVIET�" "�SAVIETT�" "�VIET�" "�VIETT�"
		"�WIDGET�" "�UIJETT�" "�COT�" "�KATT�" "�DOT�" "�TATT�" "�HOT�" "�ATT�"
		"�JACKPOT�" "�JAKBATT�" "�PHOT�" "�VATT�" "�SPOT�" "�SBATT�"
		"�AOUT�" "�UTT�" "�AZIMUT�" "�ASIMUTT�" "�BRUT�" "�BRUTT�" "�BUT�" "�BUTT�"
		"�CHUT�" "�JUTT�" "�CUT�" "�KETT�" "�DONUT�" "�TOMUTT�" "�INPUT�" "�IMBUTT�"
		"�LOCKOUT�" "�LAKAHUTT�" "�MAZOUT�" "�MASUTT�" "�OCCIPUT�" "�AKSIBUTT�"
		"�OUT�" "�AHUTT�" "�OUTPUT�" "�AHUTPUTT�" "�PEANUT�" "�BIMETT�"
		"�PROUT�" "�BRUTT�" "�RUNABOUT�" "�RUMABAHUTT�" "�RUT�" "�RUTT�"
		"�SCORBUT�" "�SKARBUTT�" "�SCOUT�" "�SKUTT�" "�STOUT�" "�STAHUTT�"
		"�UMLAUT�" "�UMLATT�" "�UPPERCUT�" "�UBERKUTT�" "�UT�" "�UTT�"
		"�VERMOUT" "�VERMAHUTT" "�ZUT�" "�SUTT�" "�APPART�" "�ABART�"
		"�CLIPART�" "�KLIBART�" "�FART�" "�VART�" "�KART�" "�KART�"
		"�SMART�" "�SMART�" "�SPART�" "�SBART�" "START�" "START�" "ART�" "AR�"
		"�YAOURT�" "�IAHURTT�" "�YOGHOURT�" "�IAKURTT�" "�YOGOURT�" "�YAKURTT�"
		"URT�" "UR�" "PLOMB�" "BLA�" "NOM�" "MA�" "�JEAN�" "�JIM�"
		"�BARMAN�" "�BARMAM�" "�BIZNESSMAN�" "�BISMESMAN�"
		"�BUSINESSMAN�" "�BISMESMAN�" "WOMAN�" "UMAM�" "�BLUESMAN�" "�BLUSMAM�"
		"�BUSHMAN�" "�BUJMAM�" "�CAMERAMAN�" "�KAMERAMAM�" "�CHAMAN�" "�JAMAM�"
		"�CHAN�" "�JAM�" "�CLAPMAN�" "�KLABMAM�" "�CLERGYMAN�" "�KLERJIMAM�"
		"�DAN�" "�TAM�" "�DOBERMAN�" "�TABERMAM�" "�GAGMAN�" "�KAKMAM�"
		"�GENTLEMAN�" "�JEMTLEMAM�" "�JAZZMAN�" "�JASMAM�" "�MAN�" "�MAM�"
		"�PERCHMAN�" "�BERJMAM�" "�POLICEMAN�" "�BALISMAM�"
		"�RECORDMAN�" "�REKARTMAM�" "�RUGBYMAN�" "�RUKBIMAM�" "�SHAMAN�" "�JAMAM�"
		"�SHOWMAN�" "�JAMAM�" "�SPORTSMAN�" "�SBARTSMAM�" "�SUPERMAN�" "�SUBERMAM�"
		"�TAXIMAN�" "�TAKSIMAM�" "�TENNISMAN�" "�TEMISMAM�" "�WALKMAN�" "�UALKMAM�"
		"�YACHTMAN�" "�IATMAM�" "�YACHTSMAN�" "�YATSMAM�" "�YACHT" "�IATT"
		"�YEOMAN�" "�IEHAMAM�" "GIRL" "KERL" "SHIRT�" "JERTT�" "�FLIRT" "�VLERTT"
		"STEAK" "STEK" "SHORT�" "JARTT�" "ORT�" "AR�" "�HIGH�" "�AY�"
		"�INTERVIEW�" "�IMTERVIU�" "�NEW�" "�MIU�" "�STEWARD�" "�STIUARTT�"
		"�SQUAW�" "�SKUA�" "�WINDOW�" "�UIMDAHU�" "BEEF" "BIV" "�BEEN�" "�BIM�"
		"�DUNDEE�" "�TEMTI�" "ENGINEER" "EMJIMIR" "FEED" "VITT"
		"�FRISBEE�" "�VRISBI�" "FEEL" "VIL" "�FREE�" "�VRI�" "�FREESBEE�" "�VRISBI�"
		"�GEEK�" "�KIK�" "�GREEN�" "�KRIM�" "�HALLOWEEN�" "�ALAHUIM�" "JEEP" "JIB"
		"COFFEE�" "KAVI�" "KEEP" "KIB" "�KLEENEX�" "�KLIMEKSS�" "�LYCHEE�" "�LIJI�"
		"MEET" "MITT" "�PEELING�" "�BILIMK�" "�SKEET�" "�SKITT�" "SLEEP" "SLIP"
		"SPEECH" "SPIJ" "�SPLEEN�" "�SBLIM�" "�STEEPLE�" "�STIBEL�" "�TEE�" "�TI�"
		"�TEEN" "�TIM" "�TWEED�" "�TUITT�" "�TWEET" "�TUITT" "�YANKEE�" "�IAMKI�"
		"WEEK" "UIK" "�WEEKEND�" "�UIKEMT�" "�UNDER" "�EMTER" "�FUN�" "�VEM�"
		"�GUN�" "�KEM�" "�GRUNGE�" "�KREMJ�" "UNK�" "EMK�" "UNCH�" "EMJ�"
		"�RANCH�" "�RAMJ�" "�SUN�" "�SEM�" "�SUNDAE�" "�SEMD�"
		"�SUNLIGHT�" "�SEMLAHITT�" "�SWEAT�" "�SUITT�" "BOOT�" "BUTT�"
		"FOOT�" "VUTT�" "�SHOOT�" "�JUTT�" "IGHT�" "AHITT�" "�RAGTIME�" "�RAKTAHIM�"
		"GEAME�" "JAM�" "GEAMMENT�" "JAMA�" "GEANT" "JAT" "GEANTE" "JATT"
		"GEA" "JA" "GEAS" "JAS" "GEAT" "JAT" "GEOT�" "JA�" "�GENTIL�" "�JATI�"
		"�PERSIL�" "�BERSI�" "�FUSIL�" "�VUSI�" "�COUTIL�" "�KUTI�"
		"�OUTIL�" "�UTI�" "�CUCUL�" "�KUKU�" "�CUL�" "�KU�" "�TAPECUL�" "�TABEKU�"
		"�GENTILHOMM" "�JATIAM" "�MONSIEUR�" "�MESI�" "�GOYAVE�" "�KOHIAV�"
		"�TAEKWONDO�" "�TAHEKUAMDA�" "�GYPAETE�" "�JIPAHETT�" "�PHAETON�" "�FAHETA�"
		"�MAES" "�MAHES" "AER" "AHER" "AED" "AHED" "AEL" "AHEL" "�PIQURE�" "�BIKUR�"
		"�OIGNON�" "�AMIA�" "POEL" "PUAL" "OELL" "UAL" "�KILOEURO�" "�KILOHERA�"
		"�CANOHEHIS" "�KAMAHEHIS" "�CAPOEIRA�" "�KABUERA�" "�GEORGE�" "�JARJ�"
		"OECO" "AHEKA" "OECHA" "AHEJA" "OECI" "AHESI" "OECON" "AHEKA"
		"OECLA" "AHEKLA" "OEDIT" "AHETIT" "OEDU" "AHETU" "OEDR" "AHETR" "OEF" "AHEF"
		"OEL" "AHEL" "OEMA" "AHEMA" "OEME" "AHEME" "OEMI" "AHEMI" "OEMO" "AHEMA"
		"OEMP" "AP" "TROEN" "TRAHEM" "OENZ" "AS" "OENER" "AHEMER" "OENTR" "ATR"
		"OENTE" "ATE" "OENDO" "ATA" "OEP" "AHEP" "OEQ" "AHEK" "OER" "AHER"
		"OESI" "AHESI" "OETE" "AHETE" "OETI" "AHETI" "OEV" "AHEV" "OEX" "AHEKS"
		"�OO" "�AHA" "LCOOL" "LKAL" "ZOO" "SA" "OOBL" "ABL" "OOCC" "AK" "OOCT" "AKT"
		"OOPER" "ABER" "OOPT" "ABT" "OORD" "ART" "OORG" "ARK" "OOEST" "AHEST"
		"OOSP" "ASP" "COYNCID" "KASIT" "�FUEL�" "�VIUL�" "�SAOUL�" "�SU�"
		"SAOUL" "SUL" "�FJORD�" "�VIARDD�" "�FJELD�" "�VIELDD�"
		"�ACONCAGUA�" "�AKAKAKUA�" "GUAR�" "KUAR�" "�GUADEL" "�KUATEL"
		"�GUANO" "�KUANA" "�GUARA" "�KUARA" "�GUATEMA" "�KUATEMA" "�IGUA" "�IKUA"
		"LINGUAL" "LAKUAL" "LINGUAUX�" "LAKUA�" "GUA�" "KUA�" "GUAYEN�" "KUEYA�"
		"GUAYENNE�" "KUEYEHN�" "AIGUILL" "EKUI" "AMBIGUI" "ABIKUI"
		"AMBIGUY" "ABIKUI" "GUITE�" "KUITE�" "GUYTE�" "KUITE�" "LINGUIF" "LAKUIV"
		"LINGUIS" "LAKUIS" "�LINGUINE�" "�LAKUIM�" "QUADRA" "KUATRA"
		"QUADRI" "KUATRI" "QUADRU" "KUATRU" "QUID" "KUITT" "�DOIGT�" "�DUA�"
		"�DOIGT" "�DUAT" "�VINGT�" "�VA�" "�VINGT" "�VAT" "PTIA" "PSIA"
		"BATIA" "BASIA" "LBUTIE" "LBUSIE" "LBUTIA" "LBUSIA" "ENTIAL" "ENSIAL"
		"ENTIEL" "ENSIEL" "TANTIAL" "TANSIAL" "ANTIEL" "ANSIEL" "RTIA" "RSIA"
		"RTIEL" "RSIEL" "�ARGUTIE�" "�ARKUSI�" "CRATIE" "KRASIE" "MATIE�" "MASI�"
		"MATIEE�" "MASI�" "TIO�" "SIA�" "OTENTIO" "OTASIO" "RENTIA" "RASIA"
		"NENTIA" "NASIA" "TENTIA" "TASIA" "DENTIA" "DASIA" "ENTIAU" "ENSIAU"
		"�MINUTIE�" "�MIMUSI�" "MINUTIEU" "MIMUSIEU" "TIEUX�" "SIEU�"
		"MATIEN" "MASIEN" "PATIEN" "BASIEN" "ATIEM" "ASIAM" "PETIEN" "BESIEN"
		"NETIEN" "NESIEN" "VETIEN" "VESIEN" "TETIEN" "TESIEN" "ARETIEN" "ARESIEN"
		"HETIEN" "HESIEN" "EOUTIEN" "EHUSIEN" "AOUTIEN" "AHUSIEN" "BOUTIEN" "BUSIEN"
		"IPUTIEN" "IBUSIEN" "ENTIENT�" "ASI�" "ITIENT�" "ISI�" "QUOTIENT" "KASIAT"
		"PATIENT�" "PASIA�" "PATIENT" "PASIAT" "OTIEN" "OSIEN" "PTIEN" "BSIEN"
		"�HAITIEN" "�AHISIEN" "HITIEN" "ISIEN" "ENTIEN" "ENSIEN"
		"�MARTIEN" "�MARSIEN" "NITIEN" "NISIEN" "FACETIE" "VASESIE"
		"OPHETIE" "OFESIE" "IPETI" "IPESI" "SATIA" "SASIA" "SATIET" "SASIET"
		"�RAZ�" "�RA�" "�RIZ�" "�RI�" "�FEZ�" "�VESS�" "�LEZ�" "�LESS�"
		"�PEZ�" "�BESS�" "�TROPEZ�" "�TRABESS�" "�MACH�" "�MAK�"
		"�CETERACH�" "�SETERAK�" "�KRACH�" "�KRAK�" "�CROMLECH�" "�KRAMLEK�"
		"�VARECH�" "�VAREK�" "�TECH�" "�TEK�" "�MUNICH�" "�MUMIK�" "OCH�" "AK�"
		"�ARCH�" "�ARK�" "�ARCHA" "�ARKA" "�CHALD" "�KALT" "CHARIS" "KARIS"
		"YCHA" "YKA" "�TRACHE" "�TRAKE" "�LICHEN�" "�LIKEM�" "�ARCHETY" "�ARKETI"
		"�ARCHEEN" "�ARKEEN" "ACHEEN" "AKEEN" "ACHEO" "AKEO" "YCHET" "YKET"
		"YCHED" "YKED" "RCHEO" "RKEO" "RCHEST" "RKEST" "ISCHE" "ISKE" "ACHIA" "AKIA"
		"ISCHI" "ISKI" "YCHIA" "YKIA" "�CHIRO" "�KIRO" "ORCHID" "ORKID"
		"�ECHID" "�EKID" "CHIOL" "KIOL" "CHITIN" "KITIN" "CHLO" "KLO" "MACHM" "MAKM"
		"RACHM" "RAKM" "TECHN" "TEKN" "ARACHN" "ARAKN" "ICHN" "IKN" "�ECHO�" "�EKA�"
		"�ECHOS" "�EKOS" "�ECHOT" "�EKAT" "�DICHO" "�DIKO" "�TRACHO" "�TRAKO"
		"�TRICHIN" "�TRIKIM" "�ARCHO" "�ARKO" "CHOA" "KOA" "YCHO" "YKO"
		"�ONCHOC" "�ONKOC" "ONCHOG" "ONKOG" "ONCHOI" "ONKOI" "ONCHOP" "ONKOP"
		"ONCHOR" "ONKOR" "ONCHOS" "ONKOS" "ONCHOT" "ONKOT" "HYNCHO" "HAKO"
		"SYNCHO" "SAKO" "ISCHO" "ISKO" "LICHOC" "LIKOC" "RICHOC" "RIKOC"
		"CHOEP" "KOEP" "CHOEU" "KEU" "RICHOM" "RIKOM" "RICHOP" "RIKOP" "CHOG" "KOG"
		"CHOL" "KOL" "NCHOP" "NKOP" "CHOND" "KOND" "�CHORIZO�" "�JARISA�"
		"�CHORBA�" "�JARBA�" "CHOR" "KOR" "�ICHT" "�IKT" "NICHT" "NIKT"
		"DRICHT" "DRIKT" "EICHT" "EIKT" "CHTH" "KTH" "CHTON" "KTON" "CHR" "KR"
		"RACHY" "RAKY" "IACHY" "IAKY" "TACHY" "TAKI" "�MANICH" "�MANIK"
		"�ALMANACH�" "�ALMAMA�" "�WAGON�" "�VAKA�" "�REICH�" "�RAHIJ�"
		"�BEN�" "�BA�" "BEN�" "BENNE�" "�BIGOUDEN�" "�BIKUTA�" "DEN�" "DENNE�"
		"GEN�" "GENNE�" "HEN�" "HENNE�" "KEN�" "KENNE�" "LEN�" "LENNE�"
		"�EXAMEN�" "�ESAMA�" "MEN�" "MENNE�" "PEN�" "PENNE�" "SEN�" "SENNE�"
		"TEN�" "TENNE�" "�YEN�" "�YENNE�" "YEN�" "YA�" "ZEN�" "ZENNE�" "�EMM" "�AM"
		"�JEUN�" "�JA�" "�AUJOURD�" "�AJURDD�" "�GAGEURE�" "�KAJUR�"
		"�MANGEURE�" "�MAJUR�" "�VERGEURE�" "�VERJUR�" "�LUNDI�" "�LATI�"
		"�RUN�" "�REM�" "RUN�" "RA�" "�JUNTE�" "�JATT�" "�JUNGLE�" "�JAKL�"
		"LUN�" "LA�" "�AUCUN�" "�AKA�" "�BUNGALOW�" "�BAKALA�" "�CAJUN�" "�KAJA�"
		"�CHACUN�" "�JAKA�" "MMUN�" "MA�" "OUNT" "OUNT" "UNT" "AT" "�HUN�" "�A�"
		"TUN�" "TA�" "�SHUNT�" "�JA�" "�TABUN�" "�TABA�" "�TRIBUN�" "�TRIBA�"
		"�TUNG" "�TAG" "�HOMUNCULE�" "�AMAKUL�" "PUNCT" "PAKT"
		"�AVUNCULA" "�AVAKULA" "PUNTIQUE�" "PATIK�" "�SECUNDO�" "�SEKATA�"
		"�NEGUNDO�" "�NEKATA�" "�SHOGUN�" "�JAKUM�" "�HUMBLE" "�ABLE"
		"�PARFUM�" "�BARVA�" "�LUMBAGO�" "�LABAKA�" "LUMP" "LAP"
		"�CONSOMPTIBLE" "�KASAPTIBLE" "�RHUMB�" "�RAB�" "�COLUMB" "�KALAB"
		"�GNARD�" "�MIAR�" "�GNANGNAN�" "�MIAMIA�" "�GNAULE�" "�MIAL�"
		"�GNOLE�" "�MIAL�" "�GNIOLE�" "�MIAL�" "�GNOGNOTTE�" "�MIOMIOTT�"
		"�GNIAF�" "�MIAV�" "�GNOCCHI�" "�MIOKI�" "�GNON�" "�MIA�" "�GNOUF�" "�MIUV�"
		"�GNIOUF�" "�MIUV�" "�GN" "�KN" "�AGNAT�" "�AKMA�" "�AGNATIQUE�" "�AKMATIK�"
		"�AGNATHE�" "�AKMATT�" "GNOS" "KNOS" "COGNITI" "KAKMITI" "GNOME�" "KMAM�"
		"GNOMIQUE�" "KMAMIK�" "GNOMIE�" "KMAMI�" "�GNOMON�" "�KMAMAM�"
		"�IGNE�" "�IKM�" "�INEXPUGNABLE�" "�IMESBUKMABL�" "�MAGNAT" "�MAKMA"
		"�MAGNIFICAT�" "�MAKMIVIKATT�" "�MAGNUM�" "�MAKMUM�"
		"�PIGNORATIF�" "�BIKMARATIV�" "�PREGNANCE�" "�BREKMASS�"
		"�PROGNATH" "�BRAKMATH" "�PUGNACE�" "�BUKMASS�" "�REGNICOLE�" "�REKMIKAL�"
		"�SPHAGNALE" "�SFAKMAL" "�STAGN" "�STAKN" "�SYNGNATHE�" "�SAKNATT�"
		"�WAGNER" "�VAKMERR" "GEMMENT�" "JAMA�" "EMMENT�" "AMA�" "OIEMENT�" "UAMA�"
		"MANIEMENT�" "MAMIMA�" "�RENIEMENT�" "�REMIMA�" "�AMER�" "�AMERR�"
		"�ASTER�" "�ASTERR�" "�BLISTER�" "�BLISTERR�"
		"�BLOCKBUSTER�" "�BLAKBUSTERR�" "�BULLDOZER�" "�BULTASERR�"
		"�CANCER�" "�KASERR�" "�CHER�" "�JERR�" "�CHESTER�" "�JESTERR�"
		"�CLUSTER�" "�KLUSTERR�" "�CUILLER�" "�KUIERR�" "�DIESTER�" "�TIESTERR�"
		"�DRAGSTER�" "�TRAKSTERR�" "�ENFER�" "�AFERR�" "ESTER�" "ESTERR�"
		"ESTHER�" "ESTERR�" "ETHER�" "ETERR�" "�FER�" "�VERR�"
		"�FIER�" "�VIERR�" "�FLIPPER�" "�VLIBERR�" "�GANGSTER�" "�KAKSTERR�"
		"�GEYSER�" "�JESERR�" "�HAMSTER�" "�AMSTERR�" "�HIER�" "�IERR�"
		"�HIVER�" "�IVERR�" "�HOLSTER�" "�ALSTERR�" "�INTER�" "�ATERR�"
		"�JUPITER�" "�JUBITER�" "�LEADER�" "�LITERR�" "�LIBER�" "�LIBERR�"
		"�LIEDER�" "�LITERR�" "�LUCIFER�" "�LUSIVERR�" "�MAGISTER" "�MAJISTERR"
		"�MASTER�" "�MASTERR�" "�MER�" "�MERR�" "�MISTER�" "�MISTERR�"
		"�MUNSTER�" "�MASTERR�" "�PODCASTER�" "�BATKASTERR�"
		"�PULLOVER�" "�BULAVERR�" "�REPORTER�" "�REBARTERR�"
		"�REVOLVER�" "�REVALVERR�" "�ROADSTER�" "�RATSTERR�" "�ROLLER�" "�RALERR�"
		"�SCANNER�" "�SKANERR�" "�SETTER�" "�SETERR�" "SPEAKER" "�SBIKERR�"
		"�SPHINCTER�" "�SVAKTERR�" "�SUPER�" "�SUBERR�" "�TER�" "�TERR�"
		"�TOASTER�" "�TASTERR�" "�VER�" "�VERR�" "�VETIVER�" "�VETIVERR�"
		"�WEBMASTER�" "�UEBMASTERR�" "�WINCHESTER�" "�UINJESTERR�"
		"CERF�" "SERR�" "NERF�" "MERR�" "SERF�" "SERR�" "ERT�" "ERR�"
		"�AUXERR" "�ASERR" "�BRUXELL" "�BRUSELL" "�COCCYX�" "�KAKSISS�"
		"�DEUXIEME�" "�TESIEM�" "�DIX�" "�TISS�" "�DIXAIN�" "�TISA�"
		"�DIXIEME�" "�TISIEM�" "�METZ�" "�MESS�" "�SIX�" "�SISS�"
		"�SIXAIN�" "�SISA�" "�SIXIEME�" "�SISIEM�" "�SOIXANTE�" "�SUASATT�"
		"�AULX�" "�A�" "�CRUCIFIX�" "�KRUSIVI�" "FAIX�" "FE�" "�PAIX�" "�BE�"
		"�PERDRIX�" "�BERTRI�" "PRIX�" "BRI�" "�ACCENT�" "�AKSA�"
		"�ACCIDENT�" "�AKSITA�" "�CENT�" "�SA�" "�INNOCENT�" "�IMASA�"
		"�POURCENT�" "�BURSA�" "�VINCENT�" "�VASA�" "�DENT�" "�TA�"
		"�EXCEDENT�" "�EKSETA�" "�INCIDENT�" "�ASITA�" "�OCCIDENT�" "�AKSITA�"
		"�TRIDENT�" "�TRITA�" "�AGENT�" "�AJA�" "�ARGENT�" "�ARJA�" "�GENT�" "�JA�"
		"�REGENT�" "�REJA�" "�SERGENT�" "�SERJA�" "�URGENT�" "�URJA�"
		"�EXCIPIENT�" "�EKSIPIA�" "�GRADIENT�" "�KRATIA�" "�INGREDIENT�" "�AKRETIA�"
		"�ORIENT�" "�ARIA�" "�LENT�" "�LA�" "�RELENT�" "�RELA�" "�TALENT�" "�TALA�"
		"�VIOLENT�" "�VIALA�" "�MENT�" "�MA�" "�ETONNAMENT�" "�ETAMAMA�"
		"�FILAMENT�" "�VILAMA�" "�FIRMAMENT�" "�VIRMAMA�" "�LIGAMENT�" "�LIKAMA�"
		"�MEDICAMENT�" "�METIKAMA�" "�TEMPERAMENT�" "�TABERAMA�"
		"�TESTAMENT�" "�TESTAMA�" "EMENT�" "EMA�" "GMENT�" "KMA�"
		"�BLANCHIMENT�" "�BLAJIMA�" "�CIMENT�" "�SIMA�" "OCIMENT�" "ASIMA�"
		"RCIMENT�" "RSIMA�" "NTIMENT�" "NTIMA�" "RTIMENT�" "RTIMA�"
		"ATIMENT�" "ATIMA�" "�BONIMENT�" "�BAMIMA�" "�COMPLIMENT�" "�KABLIMA�"
		"�CONDIMENT�" "�KATIMA�" "�DETRIMENT�" "�TETRIMA�" "FINIMENT�" "VIMIMA�"
		"�GAIMENT�" "�KEMA�" "�HARDIMENT�" "�ARTIMA�" "�INHERENT�" "�IMERA�"
		"NUTRIMENT�" "MUTRIMA�" "OLIMENT�" "ALIMA�" "�PIMENT�" "�BIMA�"
		"�QUASIMENT�" "�KASIMA�" "�REGIMENT�" "�REJIMA�" "�RUDIMENT�" "�RUTIMA�"
		"�SEDIMENT�" "�SETIMA�" "SENTIMENT�" "SATIMA�" "�VRAIMENT�" "�VREMA�"
		"SOMMENT�" "SAM�" "�DEGAMMENT�" "�TEKAM�"  "GOMMENT�" "KAM�"
		"NOMMENT�" "MAM�" "PROGRAMMENT�" "BRAKRAM�" "ENFLAMMENT�" "AVLAM�"
		"MMENT�" "MA�" "�FROMENT�" "�VRAMA�" "�MOMENT�" "�MAMA�"
		"�SARMENT�" "�SARMA�" "�SERMENT�" "�SERMA�" "�TOURMENT�" "�TURMA�"
		"OLUMENT�" "ALUMA�" "GUMENT�" "KUMA�" "DUMENT�" "TUMA�"
		"CONGRUMENT�" "KAKRUMA�" "NUMENT�" "MUMA�" "�CRUMENT�" "�KRUMA�"
		"�DOCUMENT�" "�TAKUMA�" "�DRUMENT�" "�TRUMA�" "�GOULUMENT�" "�KULUMA�"
		"�INSTRUMENT�" "�ASTRUMA�" "�JUMENT�" "�JUMA�" "�CONTINENT�" "�KATIMA�"
		"�SERPENT�" "�SERBA�" "�FLORENT�" "�FLARA�" "�LAURENT�" "�LARA�"
		"�REFERENT�" "�REVERA�" "�TORRENT�" "�TARA�" "�PRESENT�" "�BRESA�"
		"�SENT�" "�SA�" "�CONTENT�" "�KATA�" "�ONGUENT�" "�AKA�" "�ARPENT�" "�ARBA�"
		"�AUVENT�" "�AVA�" "�AVENT�" "�AVA�" "�EVENT�" "�EVA�"
		"�PARAVENT�" "�BARAVA�" "�SOUVENT�" "�SUVA�" "�VENT�" "�VA�" "ENT�" "�E��"
		"�BIMILLENAIRE�" "�BIMILEMERR�" "�TRILLION�" "�TRILIA�"
		"�QUATRILLION�" "�KUATRILIA�" "�QUINTILLION�" "�KATILIA�"
		"�SEXTILLION�" "�SEKSTILIA�" "�CANCOILLOTE�" "�KAKUAHIATT�"
		"�MAMILLAIRE�" "�MAMILERR�" "�MILLET�" "�MI�" "ANQUILL" "AKIL"
		"APILL" "ABIL" "BACILL" "BASIL" "BILLY" "BILI" "CILLI" "SILI"
		"CYRILL" "SIRIL" "DICILL" "TISIL" "�DISTILL" "�TISTIL" "FIBRILL" "VIBRIL"
		"�GILL" "�JIL" "HILL" "HIL" "IGILL" "IJIL" "�ILL" "�IL" "ILL�" "HIL�"
		"ILLOSE�" "ILASS�" "ILLUS" "ILUS" "LILLI" "LILI" "LILLO" "LILO"
		"�MILLE" "�MILE" "�MILLI" "�MILI" "OILL" "UAL" "PUSILLANIM" "BUSILAMIM"
		"SERPILL" "SERBIL" "SCILL" "SIL" "�STILL" "�STIL" "�VILLA" "�VILA"
		"�CHEVILLE" "�JEVIE" "�RECROQUEVILLE" "�REKRAKVIE" "VILLE" "VILE"
		"VILLIEN" "VILIEN" "VILLISTE" "VILISTE" "WILL" "HUIL" "XILL" "KSIL"
		"ILL" "Y"
	} $data]
	# Fins de mots courantes.
	set data [::tcl::string::map {
		"OING�" "�U��A��" "OINT�" "�U��A��" "OIN" "�U��A��" "OIT�" "�U��A��" "OIX�"
		"�U��A��" "AT�" "�A��" "EAUD�" "�A��" "EAUT�" "�A��" "EAUX�" "�A��"
		"EAU�" "�A��" "AUD�" "�A��" "AUT�" "�A��" "AUX�" "�A��" "AU�" "�A��"
		"AINT�" "�A��" "AIN�" "�A��" "EINT�" "�A��" "EIN�" "�A��" "INT�" "�A��"
		"IN�" "�A��" "AIM�" "�A��" "AMP�" "�A��" "AND�" "�A��" "ANT�" "�A��"
		"AN�" "�A��" "AON�" "�A��" "OND�" "�A��" "ONT�" "�A��" "tION�" "SIO�"
		"ON�" "�A��" "EANT�" "�A��" "END�" "�A��" "ENT�" "�A��" "OT�" "�A��"
		"YM�" "�A��" "ING�" "�I��M��K��" "G�" "�K��" "EAIT�" "�E��" "AIT�" "�E��"
		"ER�" "�E��" "ET�" "�E��" "EZ�" "�E��" "EUD�" "�E��" "EUX�" "�E��"
		"EY�" "E�" "AIL�" "�A��I��" "EIL�" "�E��I��" "OUT�" "�U��" "EUT�" "�E��"
		"UT�" "�U��" "OUX" "�U��" "IT�" "�I��" "RD�" "�R��" "EAUTE�" "�ATE��"
	} $data]
	# Phon�mes communs, 1�re passe.
	set data [::tcl::string::map {
		"GUA" "KA" "GU�A�" "K�A�" "GUEU" "KE" "GUE" "KE" "GU�E�" "K�E�" "GUI" "KI"
		"GU�I�" "K�I�" "GUO" "KA" "GUY" "KY" "QUEU" "KEU"  "QUE" "KE" "QU�E�" "K�E�"
		"QU" "K" "CCH" "K" "GE" "JE" "G�E�" "J�E�" "GI" "JI" "G�I�" "J�I�" "GY" "JY"
		"GN" "HNI" "PH" "V" "CE" "SE" "C�E�" "S�E�" "CI" "SI" "C�I�" "S�I�"
		"CY" "SY"
	} $data]
	# Phon�mes communs, 2�me passe.
	set data [::tcl::string::map {
		"AILLE" "AYE" "�A�ILLE" "�A�YE" "AILL�E�" "AY�E�" "�A�ILL�E�" "�A�Y�E�"
		"AILL" "AY" "�A�ILL" "�A�Y" "EILL" "EY" "�E�ILL" "�E�Y" "OEU" "EU" "�U" "EU"
		"�" "EU" "OE" "EU" "AE" "E" "�" "E" "EOI" "UA" "�E�OI" "�U��A�"
		"EO�I�" "�U��A�" "�E�O�I�" "�U��A�"
	} $data]
	# Phon�mes communs, 3�me passe.
	set data [::tcl::string::map {
		"OIN" "�U��A�" "OI" "�U��A�" "OYA" "�U��A��I�A" "OY�A�" "�U��A��I��A�"
		"OYE" "�U��A��I�E" "OY�E�" "�U��A��I��E�" "OYI" "�U��A�I"
		"OY�I�" "�U��A��I�" "OYO" "�U��A��I�O" "OYU" "�U��A��I�U" "OY" "�A��I�"
		"AMB" "�A�B" "AMP" "�A�P" "EMB" "�A�B" "�E�MB" "�A�B" "EMP" "�A�P"
		"�E�MP" "�A�P" "IMB" "�A�B" "�I�MB" "�A�B" "IMP" "�A�P" "�I�MP" "�A�P"
		"OMB" "�A�B" "OMP" "�A�P" "AIE" "�E�" "AI�E�" "�E�" "EAI" "�E�"
		"�E�AI" "�E�" "EA�I�" "�E�" "�E�A�I�" "�E�" "EUILL" "�E��I�"
		"�E�UILL" "�E��I�" "EUIL" "�E��I�" "�E�UIL" "�E��I�" "UEILL" "�E��I�"
		"UEIL" "�E��I�" "TSCH" "�J�" "TCH" "�J�" "TSH" "�J�" "CHS" "�J�" "SCH" "�J�"
		"SH" "�J�" "CH" "�J�" "TJ" "�J�"
	} $data]
	# R�gles avanc�es ne pr�sentant aucun avantage � �tre d�compos�es en string
	# maps.
	regsub -all {(EIN|[AIO]N)(?!(�)?[AEINOUYH])} $data {�A�} data
	regsub -all {[EY]N(?!(�)?[AEINOUY])} $data {�A�} data
	regsub -all {O{2,}} $data "�U�" data
	# Phon�mes �l�mentaires
	set data [::tcl::string::map {
		"EU" "�E�" "AI" "�E�" "EI" "�E�" "AU" "�A�" "OU" "�U�" "A" "�A�" "O" "�A�"
		"B" "�B�" "P" "�B�" "C" "�K�" "G" "�K�" "K" "�K�" "Q" "�K�" "D" "�T�"
		"T" "�T�" "E" "�E�" "F" "�V�" "V" "�V�" "H" "" "I" "�I�" "Y" "�I�" "J" "�J�"
		"L" "�L�" "M" "�M�" "N" "�M�" "R" "�R�" "S" "�S�" "Z" "�S�" "U" "�U�"
		"W" "�U�" "X" "�K��S�"
	} $data]
	# Suppression des marqueurs de phon�mes
	set data [::tcl::string::map {"�" "" "�" ""} $data]
	# Post-traitement : application des modes de filtrage.
	if { $vowel_mode == 2 } {
		# Les E sont d'abord supprim�s � la fin des mots, puis toutes les voyelles
		# restantes sont remplac�es par le caract�re g�n�rique "A".
		regsub -all {([ABEIJKLMRSTUV])E+�} $data {\1�} data
		set data [::tcl::string::map {"E" "A" "I" "A" "U" "A"} $data]
	} elseif { $vowel_mode == 3 } {
		# Toutes les voyelles sont supprim�es. Si le mot n'est constitu� que de
		# voyelles, retourne "A".
		regsub -all {[AEIU]+} $data {A} data
		set data [::tcl::string::map {"�A�" "�A�" "A" ""} $data]
	}
	if { $vowel_mode != 3 } {
		if { $end_vowel_mode == 2 } {
			# Toutes les voyelles sont supprim�es en fin de mot, sauf s'il ne reste
			# qu'un phon�me.
			regsub -all {([ABEIJKLMRSTUV])[AEIU]+�} $data {\1�} data
		} else {
			# Les "E" sont supprim�s en fin de mot, sauf s'il ne reste qu'un phon�me.
			regsub -all {([ABEIJKLMRSTUV])E+�} $data {\1�} data
		}
	}
	if {
		($vowel_sequence_mode == 2)
		&& ($vowel_mode == 1)
	} then {
		# Si plusieurs voyelles se suivent, on ne conserve que la 1�re
		regsub -all {([AEIU])[AEIU]+} $data {\1} data
	}
	# Traitement des espaces.
	if {
		(![::tcl::string::match "* *" $keepchars])
		&& !($replace_non_alpha_chars_by_spaces)
	} then {
		set data [::tcl::string::map {" " ""} $data]
	}
	if { !$replace_non_alpha_chars_by_spaces } {
		set data [::tcl::string::map {"�" ""} $data]
	} else {
		set data [::tcl::string::map {"�" " "} $data]
	}
	# Post-traitement : application d'une longueur fixe.
	if { $fixed_length != 0 } {
		foreach word [split $data "��"] {
			if { [regexp {^[ABEIJKLMRSTUV]+$} $word] } {
				# Si le mot est trop long, on le tronque.
				if { [set word_length [::tcl::string::length $word]] > $fixed_length } {
					set word [::tcl::string::range $word 0 [expr {$fixed_length - 1}]]
				# Si le mot est trop court, on ajoute des 0
				} elseif { $word_length < $fixed_length } {
					append word [::tcl::string::repeat "0" [expr {$fixed_length - $word_length}]]
				}
			}
			append output $word
		}
	} else {
		# Traitement des marqueurs restants.
		set output [::tcl::string::map {"�" "" "�" ""} $data]
	}
	# On r�duit les occurrences cons�cutives d'un m�me symbole � un seul.
	# Remarque : la m�thode utilis�e est moche mais plus rapide qu'un seul regexp.
	while { [::tcl::string::match *AA* $output] } { set output [::tcl::string::map {AA A} $output] }
	while { [::tcl::string::match *BB* $output] } { set output [::tcl::string::map {BB B} $output] }
	while { [::tcl::string::match *EE* $output] } { set output [::tcl::string::map {EE E} $output] }
	while { [::tcl::string::match *II* $output] } { set output [::tcl::string::map {II I} $output] }
	while { [::tcl::string::match *JJ* $output] } { set output [::tcl::string::map {JJ J} $output] }
	while { [::tcl::string::match *KK* $output] } { set output [::tcl::string::map {KK K} $output] }
	while { [::tcl::string::match *LL* $output] } { set output [::tcl::string::map {LL L} $output] }
	while { [::tcl::string::match *MM* $output] } { set output [::tcl::string::map {MM M} $output] }
	while { [::tcl::string::match *RR* $output] } { set output [::tcl::string::map {RR R} $output] }
	while { [::tcl::string::match *SS* $output] } { set output [::tcl::string::map {SS S} $output] }
	while { [::tcl::string::match *TT* $output] } { set output [::tcl::string::map {TT T} $output] }
	while { [::tcl::string::match *UU* $output] } { set output [::tcl::string::map {UU U} $output] }
	while { [::tcl::string::match *VV* $output] } { set output [::tcl::string::map {VV V} $output] }
	return $output
}

 ###############################################################################
### Commande de test (!test_haplophone)
 ###############################################################################
proc ::HaploPhone::test_HaploPhone {nick host handle chan arg} {
	if { $arg eq "" } {
		puthelp "PRIVMSG $chan :\037Syntaxe\037 : \002!test_haplophone\002 \00314<\003string\00314>\003"
	} else {
		puthelp "PRIVMSG $chan :\00314[::HaploPhone::process -makespaces $arg]\003"
	}
}

 ###############################################################################
### binds
 ###############################################################################
bind evnt - prerehash ::HaploPhone::uninstall
bind pub - !test_haplophone ::HaploPhone::test_HaploPhone


putlog "$::HaploPhone::scriptname v$::HaploPhone::version (�2009-2015 Menz Agitat) a �t� charg�."
