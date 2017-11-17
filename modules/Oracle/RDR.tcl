 ###############################################################################
#
# Related Differential Report
# v1.21 (17/06/2015)   �2014-2015 Menz Agitat
#
# IRC: irc.epiknet.org  #boulets / #eggdrop
#
# Mes scripts sont t�l�chargeables sur http://www.eggdrop.fr
# Retrouvez aussi toute l'actualit� de mes releases sur
# http://wiki.eggdrop.fr/Utilisateur:MenzAgitat
#
# Remerciements � Galdinx pour les coups de main sur la partie math�matique.
#
 ###############################################################################

#
# Description
#
# Ce script pourvoit l'eggdrop du package Related_Differential_Report 1.21
#
# Le rapport de relation diff�rentielle est une extrapolation du principe de la
# distance de Levenshtein.
#
# Rappelons que la distance de Levenshtein calcule le nombre de caract�res qu'il
# est n�cessaire d'ajouter, modifier, d�placer ou supprimer pour passer d'une
# cha�ne de caract�res � une autre.
#
# Le rapport de relation diff�rentielle (RDR) fait � peu pr�s la m�me chose, �
# ceci pr�s que la position des caract�res n'a aucune importance pour lui.
# Il calcule le taux de diff�rences entre deux cha�nes de caract�res en se
# focalisant sur le nombre de caract�res de chaque type.
# De plus, les caract�res conservant la m�me position entre les deux cha�nes de
# caract�res (en partant du d�but ou de la fin) ajoutent un bonus de similarit�
# qui sera pris en compte dans le r�sultat final.
# Enfin, une p�nalit� est appliqu�e si la longueur des deux cha�nes de
# caract�res pr�sente une trop grande diff�rence.
# La valeur retourn�e est comprise entre 0 et 100, 0 signifiant qu'il n'y a
# aucune diff�rence entre les deux cha�nes de caract�res, et 100 signifiant
# qu'elles sont tr�s dissemblables.
#
 ###############################################################################

#
# Int�r�t
#
# Permet � un correcteur orthographique de faire des suggestions pour tel mot
# mal orthographi�, en proposant d'autres mots dont le RDR par rapport au
# premier est faible.
#
# Permet � une pseudo-IA de type chatterbot d'avoir une tol�rance
# orthographique : si tel mot compar� � tel autre a un RDR inf�rieur � une
# tol�rance donn�e, on peut d�cider qu'il est �quivalent.
#
# Compar� � la m�thode de la distance de Levenshtein, RDR est plus souple en ce
# sens qu'il permettra par exemple de d�tecter deux phrases formul�es
# diff�remment comme �tant la m�me phrase puisque l'ordre des mots importe peu.
#
 ###############################################################################

#
# Syntaxe
#
# ::RDR::RDR [-allchars] <1�re cha�ne de caract�res> <2�me cha�ne de caract�res>
#
# Si l'option -allchars est sp�cifi�e, tous les caract�res seront pris en
# compte. Si elle ne l'est pas, seuls les caract�res alphanum�riques et les
# espaces seront trait�s.
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
# ::RDR::RDR "il fait beau aujourd'hui" "aujourd'hui il fait beau"
#	0.0
#
# ::RDR::RDR "il fera beau aujourd'hui" "aujourd'hui il fait beau"
# 8.637461117131487
#
# ::RDR::RDR "il fera beau aujourd'hui" "aujourd'hui il va pleuvoir"
# 20.935906263026013
#
# ::RDR::RDR "il fera beau aujourd'hui" "cette phrase n'a vraiment rien � voir"
# 55.65136373698695
# Notez que dans l'exemple ci-dessus, le score reste �loign� de 100. C'est d� au
# fait que les deux cha�nes de caract�res comportent un certain nombre de
# caract�res communs.
#
# ::RDR::RDR "abcdefghi" "jklmnopqrstuvwxyz"
# 100.0
#
 ###############################################################################

#
# Changelog
#
# 1.0
#		- 1�re version
# 1.1
#		- Modification de l'algorithme afin de valoriser les caract�res qui
#			conservent la m�me position entre les deux cha�nes, en partant du d�but
#			ou de la fin.
# 1.2
#		- Correction : si les deux cha�nes de caract�res compar�s �taient de
#			longueur diff�rente, le taux de diff�rences retourn� diff�rait selon qu'on
#			comparait string1 � string2 ou string2 � string1.
#		- Modification de la fonction servant � calculer le taux de diff�rences afin
#			d'affiner la pertinence des r�sultats.
#		- Ajout : une p�nalit� est appliqu�e au score final les deux cha�nes de
#			caract�res compar�es sont de longueur diff�rentes.
#		- Ajout : une aide � la syntaxe est donn�e dans l'erreur retourn�e par la
#			commande ::RDR::RDR si elle est utilis�e sans arguments.
#		- Le code a �t� comment� afin d'en faciliter la compr�hension.
#		- Quelques optimisations.
# 1.21
#		- Correction : comparer deux cha�nes de caract�res vides provoquait une
#			erreur.
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

if {[::tcl::info::commands ::RDR::uninstall] eq "::RDR::uninstall"} { ::RDR::uninstall }
# Note pour les programmeurs :
# Dans la version 1.6.19 d'Eggdrop, le num�ro de version affich� par .vbottree
# et [numversion] est incorrect; il affiche 1061800 ou 1061801, ce qui
# correspond � la version 1.6.18. On utilise donc une autre technique pour
# v�rifier le num�ro de version.
namespace eval ::RDR {



 ###############################################################################
### Fin de la configuration
 ###############################################################################



	 #############################################################################
	### Initialisation
	 #############################################################################
	variable scriptname "Related Differential Report"
	variable version "1.21.20150617"
	package provide Related_Differential_Report 1.21
	# Proc�dure de d�sinstallation (le script se d�sinstalle totalement avant
	# chaque rehash ou � chaque relecture au moyen de la commande "source" ou
	# autre)
	proc uninstall {args} {
		putlog "D�sallocation des ressources de ${::RDR::scriptname}..."
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		package forget Related_Differential_Report
		namespace delete ::RDR
	}
}

 ###############################################################################
### Calcul du rapport de relation diff�rentielle
 ###############################################################################
proc ::RDR::RDR {args} {
	if { [set args [::tcl::string::tolower $args]] eq "" } {
		error "wrong # args: should be \"[::tcl::info::level 0] ?-allchars? string1 string2\""
	} else {
		# Le param�tre -allchars a �t� sp�cifi�, on traite tous les caract�res.
		if { [regexp -- {^-allchars\s} $args] } {
			lassign $args {} string1 string2
		# Le param�tre -allchars n'a pas �t� sp�cifi�, on ne traite que les
		# caract�res alphanum�riques et les espaces.
		} else {
			lassign $args string1 string2
			regsub -all {[^\s[:alnum:]]} $string1 "" string1
			regsub -all {[^\s[:alnum:]]} $string2 "" string2
		}
		# Gestion du cas o� les deux cha�nes de caract�res sont vides.
		if {
			($string1 eq "")
			&& ($string2 eq "")
		} then {
			return 0.0
		}
		# Initialisation des variables.
		set similarity_bonus 0
		set string1_charlist [split $string1 ""]
		set string2_charlist [split $string2 ""]
		set string1_length [::tcl::string::length $string1]
		set string2_length [::tcl::string::length $string2]
		# On parcourt $string1 lettre par lettre.
		set index 0
		foreach char $string1_charlist {
			# Construction d'une table contenant un exemplaire de chaque caract�re
			# utilis� dans $string1, auquel est associ� une valeur. La valeur est
			# incr�ment�e pour chaque occurrence de ce caract�re dans $string1.
			::tcl::dict::incr worklist $char 1
			# Si le caract�re en cours de traitement conserve la m�me position dans
			# $string2 en partant du d�but OU de la fin, on incr�mente un bonus de
			# similarit� qui influera sur le score final.
			# Par exemple, si $string1 est "ARBRES", "E" est la 5�me lettre en partant
			# du d�but, ou la 2�me en partant de la fin; un bonus de similarit� sera
			# accord� si dans $string2 on retrouve un "E" en 5�me ou avant-derni�re
			# position.
			if { $char eq [lindex $string2_charlist $index] } {
				incr similarity_bonus 1
			} elseif { $char eq [lindex $string2_charlist end-[expr {$string1_length - $index - 1}]] } {
				incr similarity_bonus 1
			}
			incr index
		}
		# On parcourt $string2 lettre par lettre.
		set index 0
		foreach char $string2_charlist {
			# D�cr�mentation de la valeur associ�e � chaque caract�re de la table
			# $worklist, pour chaque occurrence dans $string2.
			# Si un caract�re n'existe pas encore dans la table, il y est ajout� et
			# d�cr�ment�.
			::tcl::dict::incr worklist $char -1
		}
		# Gestion du cas particulier o� $string2_length est impair et o� l'on
		# retrouve son caract�re central dans $string1 en m�me position � la fois en
		# partant du d�but ET de la fin du mot (comme le A dans HAMAC et FAT).
		# On compense donc pour �viter que le A ne soit compt� 2 fois dans un sens,
		# et une seule fois dans l'autre.
		if { [expr {($string2_length / 2) * 2}] != $string2_length } {
			set string2_center_index [expr {round($string2_length / 2.0) - 1}]
			set string2_center_char [lindex $string2_charlist $string2_center_index]
			if {
				($string2_center_char eq [lindex $string1_charlist $string2_center_index])
				&& ($string2_center_char eq [lindex $string1_charlist end-$string2_center_index])
			} then {
				incr similarity_bonus -1
			}
		}
		# Calcul du score.
		set length_mismatch_penalty [expr {1 / (0.1 + (3.797 * 1.09**-((abs($string1_length-$string2_length) * 1.0) / max($string1_length,$string2_length) * 100))) - 3.797 + 3.5404}]
		if { !$similarity_bonus } {
			# On compense le fait qu'une fonction asymptotique emp�che d'atteindre la
			# valeur maximum (soit 100).
			set score [expr {((abs([expr [regsub -all -- {-} [join [::tcl::dict::values $worklist] "+"] ""]]) * 100.0) / ($string1_length + $string2_length)) + $length_mismatch_penalty}]
		} else {
			set score [expr {(1 / (1 + exp(((10 * $similarity_bonus) / max($string1_length,$string2_length)) - 5))) * ((abs([expr [regsub -all -- {-} [join [::tcl::dict::values $worklist] "+"] ""]]) * 100.0) / ($string1_length + $string2_length)) + $length_mismatch_penalty}]
		}
		# On arrondit le score aux deux extr�mit�s.
		if { $score >= 100 } {
			set score 100.0
		} elseif { $score <= 1.0e-5 } {
			set score 0.0
		}
		return $score
	}
}

 ###############################################################################
### Binds
 ###############################################################################
bind evnt - prerehash ::RDR::uninstall


putlog "$::RDR::scriptname v$::RDR::version (�2014-2015 Menz Agitat) a �t� charg�."
