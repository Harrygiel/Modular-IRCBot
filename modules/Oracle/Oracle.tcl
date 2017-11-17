 ##############################################################################
#
# Oracle
# v2.31 (14/09/2017)   �2009-2017 MenzAgitat
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
# Posez votre question � l'oracle, il vous r�pondra.
# Il d�tecte plusieurs types de question diff�rents et donne des r�ponses
# appropri�es (la plupart du temps) choisies parmi un total de 615 r�ponses
# r�parties dans 16 cat�gories.
#
# Si la question a d�j� �t� pos�e, la r�ponse restera la m�me.
#
# Oracle utilise un algorithme phon�tique nomm� HaploPhone afin de d�tecter des
# questions identiques m�me si l'orthographe et la ponctuation varient.
# Oracle utilise �galement l'algorithme du Rapport de Relation Diff�rentielle
# afin de tol�rer des variations et de reconna�tre deux questions tr�s
# l�g�rement diff�rentes ou formul�es diff�remment, comme �tant une seule
# et m�me question.
# 
# Les scripts HaploPhone (HaploPhone.tcl) et Related Differential Report
# (RDR.tcl) sont requis par Oracle pour fonctionner.
# Assurez-vous que vous poss�dez bien ces deux scripts et que vous les avez
# ajout�s dans le fichier eggdrop.conf AVANT Oracle.tcl :
#			source scripts/HaploPhone.tcl
#			source scripts/RDR.tcl
#			source scripts/Oracle.tcl
#
# Si vous ajoutez de nouvelles r�ponses, assurez-vous de les placer dans la
# bonne cat�gorie et de les formuler de la bonne fa�on (inspirez-vous des
# r�ponses existantes), sans quoi l'oracle aura l'air d'�tre � c�t� de ses
# pompes.
#
 ###############################################################################

#
# Syntaxe
#
# Pour activer l'Oracle sur un chan, vous devez taper ceci en partyline :
# .chanset #NomDuChan +oracle
# et ceci pour le d�sactiver :
# .chanset #NomDuChan -oracle
#
# Poser une question � l'oracle :
# !oracle <question>
#
# La commande !oracle_db_size permet au propri�taire de l'Eggdrop de compter et
# d'afficher le nombre de r�ponses dans la base de donn�es.
#
 ###############################################################################

#
#	Changelog
#
# 1.0
#		- 1�re version
# 2.0
#		- Le code a �t� en grande partie r��crit, ce qui induit la correction de
#			certains bugs potentiels, plus d'�volutivit�, plus de rapidit�.
#		- Utiliser le script tout seul sur un chan ne provoque plus d'erreur.
#			(merci � panfleto pour l'avoir d�couvert et � Artix pour la solution
#			�l�gante)
#		- La d�tection du type de question est maintenant plus fiable et tol�re une
#			orthographe approximative ainsi que de nombreuses variantes.
#		- Ajout d'un grand nombre de nouvelles r�ponses.
#		- Ajout de plusieurs nouveaux types de r�ponses.
#		- Ajout de la commande !oracle_db_size qui permet de compter et d'afficher
#			le nombre de r�ponses dans la base de donn�es (owner seulement).
#		- L'activation/d�sactivation du script sur chaque chan se fait maintenant
#			au moyen de la commande .chanset #NomDuChan [+/-]oracle (� taper en
#			partyline)
#		- Passage sous licence Creative Commons.
# 2.1
#		- Correction du type de questions "que...." comme dans "que fais-tu ?"
#		- Ajout d'une nouvelle r�ponse (pour un nouveau total de 563).
#		- Am�lioration de la d�tection des packages.
#		- Quelques optimisations mineures du code.
# 2.2
#		- Am�lioration de la d�tection du type de question : d�sormais, moins de
#			questions devraient retourner une r�ponse neutre.
#		- Le nombre de r�ponses directes oui/non a �t� l�g�rement augment�.
#		- Le script requiert maintenant le package MenzAgitat's Soundex v2.1
#		- En raison de la mise � jour du soundex, les caract�res non-alphab�tiques
#			n'influent plus sur la phon�tique et la d�tection de questions d�j� pos�es
#			s'en trouve am�lior�e.
#		- Ajout de 47 nouvelles r�ponses (pour un nouveau total de 610).
# 2.3
#		- Correction : les question du type "Qu'est" �taient parfois mal d�tect�es.
#		- Modification : Le package Related Differential Report v1.1 est d�sormais
#			requis : l'Oracle utilise maintenant le Rapport de Relation Diff�rentielle
#			plut�t que la Distance de Levenshtein pour d�tecter des questions
#			similaires mais �crites ou formul�es diff�remment. (script du m�me auteur
#			� t�l�charger s�par�ment).
#		- Modification : le package Levenshtein n'est d�sormais plus requis.
#		- Modification : Le package HaploPhone v3.0 est d�sormais requis : l'Oracle
#			utilise maintenant HaploPhone, qui est une version am�lior�e de l'ancien
#			package MenzAgitats_Soundex.
#		- Modification : Le package MenzAgitats_Soundex n'est d�sormais plus requis.
#		- Modification : Afin de diminuer la consommation de m�moire, les r�ponses
#			aux questions d�j� pos�es ne seront plus stock�es litt�ralement, mais sous
#			la forme type/index.
#		- Modification : si une question m�moris�e ressemble � une question pos�e de
#			type diff�rent, elle ne sera d�sormais plus consid�r�e comme identique.
#		- Ajout de 5 nouvelles r�ponses (pour un nouveau total de 615).
#		- Nombreuses optimisations du code.
# 2.31
#		- Correction : le script indiquait un probl�me de version lors du chargement
#			sur un Eggdrop v1.8.x
#		- Correction : utiliser la variable $question dans une r�ponse provoquait
#			une erreur.
#
 ###############################################################################

#
# LICENCE:
#		Cette cr�ation est mise � disposition selon le Contrat
#		Attribution-NonCommercial-ShareAlike 3.0 Unported disponible en ligne
#		http://creativecommons.org/licenses/by-nc-sa/3.0/ ou par courrier postal �
#		Creative Commons, 171 Second Street, Suite 300, San Francisco, California
#		94105, USA.
#		Vous pouvez �galement consulter la version fran�aise ici :
#		http://creativecommons.org/licenses/by-nc-sa/3.0/deed.fr
#
 ###############################################################################

if { [::tcl::info::commands ::Oracle::uninstall] eq "::Oracle::uninstall" } { ::Oracle::uninstall }
# Note pour les programmeurs :
# Dans la version 1.6.19 d'Eggdrop, le num�ro de version affich� par .vbottree
# et [numversion] est incorrect; il affiche 1061800 ou 1061801, ce qui
# correspond � la version 1.6.18. On utilise donc une autre technique pour
# v�rifier le num�ro de version.
if { [catch { package require HaploPhone 3.0 }] } {
	putloglev o * "\00304\[Oracle - Erreur\]\003 Oracle n�cessite que le script HaploPhone v3.0 (ou sup�rieur) soit charg� pour fonctionner."
	return
}
if { [catch { package require Related_Differential_Report 1.2 }] } {
	putloglev o * "\00304\[Oracle - Erreur\]\003 Oracle n�cessite que le script Related Differential Report v1.1 (ou sup�rieur) soit charg� pour fonctionner."
	return
}
namespace eval ::Oracle {



 ############################################################################
### Configuration
 ############################################################################

	# Commande utilis�e pour questionner l'oracle
	variable oracle_cmd "!oracle"

	# Autorisations pour la commande
	variable oracleauth "-|-"

	# Activer le contr�le de flood ? (0 = d�sactiv� / 1 = activ�)
	variable antiflood 1

	# Seuil de d�clenchement de l'antiflood.
	# Exemple : "6:60" = 6 requ�tes maximum en 60 secondes.
	variable flood_threshold "6:60"

	# Intervalle de temps minimum (en secondes) entre l'affichage de 2 messages
	# avertissant que l'antiflood a �t� d�clench� (ne r�glez pas cette valeur
	# trop bas afin de ne pas �tre flood� par les messages d'avertissement de
	# l'antiflood...)
	variable antiflood_msg_interval 30

	# Filtrer les codes de styles (couleurs, gras, ...) dans l'affichage des
	# messages du script ? (0 = non / 1 = oui)
	# Remarque : le filtrage s'active automatiquement si le mode +c est mis sur
	# le chan.
	variable monochrome 0

	# Pourcentage de chances de retourner une r�ponse neutre (neutral_response)
	variable neutral_rate 10

	# Tol�rance maximum pour le rapport de relation diff�rentielle (ne touchez pas
	# � cette valeur sans savoir ce que vous faites)
	variable RDR_tolerance 20

	# Nombre maximum de questions m�moris�es par l'Eggdrop (si une question
	# m�moris�e est pos�e plusieurs fois par la m�me personne, elle donnera
	# toujours la m�me r�ponse).
	# Afin de ne pas encombrer excessivement la m�moire, on stocke au maximum
	# $max_memory associations nick/question->r�ponse.
	variable max_memory 50

	# Types de r�ponse activ�s, � l'exeption des types "yesno" et "notaquestion"
	# L'ordre est important et d�termine la priorit�. 
	# Ne touchez pas � cette variable � moins de savoir ce que vous faites.
	variable enabledTypes {howmuchtime howmany howis howare howgoodis howgoodare howto withwhat howshould when why who where neutral}

	# Expressions r�guli�res utilis�es pour la d�tection du type de la question.
	# N'y touchez pas si vous n'�tes pas familier avec �a.
	array set ::Oracle::regexpTypes {
		howmuchtime {(^|[^[:alpha:]]+)(co[mn]bien|cb(ien)?)\s+de\s+temps?[^[:alpha:]]}
		howmany {(^|[^[:alpha:]]+)co[mn]bien|cb(ien)?[^[:alpha:]]}
		howis {(^|[^[:alpha:]]+)((com+[ea]nt?\s+([e�](st|[st])(ait?)?|suis?|sera(i[ts]?)?))|(([e�](st|[st])(ait?)?|suis?|sera(i[ts]?)?)\s+com+[ea]nt?))[^[:alpha:]]}
		howare {(^|[^[:alpha:]]+)((com+[ea]nt?\s+(s(er)?ont|seraient|[�e]taient))|((s(er)?ont?|seraient|[�e]taient)\s+com+[ea]nt?))[^[:alpha:]]}
		howgoodis {(^|[^[:alpha:]]+)com+[ea]nt?\s+va[ts]?[^[:alpha:]]}
		howgoodare {(^|[^[:alpha:]]+)com+[ea]nt?\s+vont?[^[:alpha:]]}
		howto {com+[ea]nt?\s+([�e]tre?|f(ai|e|�)r+e?|pour+(a|e|io|on)[[:alpha:]]|peut?|puis?j?e?|doi[st]?|on)[^[:alpha:]]}
		withwhat {(^|[^[:alpha:]]+)(par|ave[ck])\s+(qu?|k)oi[^[:alpha:]]}
		howshould {(^|[^[:alpha:]]+)(com+[ea]nt?|de\s+(qu?|k)el+e?s?\s+(fa([�c]|s+)on|mani[�e]r+e?))[^[:alpha:]]}
		when {(^|[^[:alpha:]]+)(qu?|k)and?[^[:alpha:]]}
		why {(^|[^[:alpha:]]+)(pour(\s+)?(qu?|k)oi|pk(oi)?)[^[:alpha:]]}
		who {(^|(^([a�]|[e�](st|[st])(ait?)?|avec|par|pour|sur|sous|de|en)[^[:alpha:]])|([^[:alpha:]](est?|[e�]t(ai[st]?|�)?|avec|par|pour|sur|sous|de|en)[^[:alpha:]]))(qu?|k)i[^[:alpha:]]}
		where {((^|[^[:alpha:]]+)(o�|(qu?|k)el+e?s?\s+([ea]ndroit?|coin|lieu|place|zon+e)|(dans?|vers?)\s+(qu?|k)el+e?)|^ou)[^[:alpha:]]}
		neutral {(^|[^[:alpha:]]+)((qu?|k)[e'](l+e?s?)?\s+([e�](st|[st])(ait?)?|s(er)?(ont?|a(i[ts]?|ient)?))|^(qu?|k)e|(qu?|k)el+e?s?|qu'est?(-?ce)?|(qu?|k)es(qu?|k)e?|(qu?|k)oi)[^[:alpha:]]}
	}
	# Pour ceux qui ne savent pas lire les expressions r�guli�res, voici en clair
	# la liste des mod�les pris en charge class�s par type.
	# Remarque : cette liste n'est pas exhaustive car elle ne comprend pas les
	# variantes orthographiques que permet l'utilisation des expressions
	# r�guli�res.
	#		TYPE				MODELE DE QUESTION
	#		howmuchtime	combien de temps
	#		howmany			combien
	#		howis				comment est/�tait/suis/sera/serait | est/�tait/suis/sera/serait comment
	#		howare			comment sont/seront/seraient/�taient | sont/seront/seraient/�taient comment
	#		howgoodis		comment va
	#		howgoodare	comment vont
	#		howto				comment �tre/faire/pourrais/pourrions/pourrons/peut/puis/doit/on
	#		withwhat		par/avec quoi
	#		howshould		comment | de quelle fa�on/mani�re
	#		when				quand
	#		why					pourquoi
	#		who					�/est/�tait/avec/par/pour/sur/sous/de/en qui
	#		where				o� | quel endroit/coin/lieu/place/zone | dans/vers quel
	#		neutral			quel est/�tait/sera/serait/sont/seront | qu'est-ce | quoi


	###  BIBLIOTHEQUE DE REPONSES

	# Vous pouvez utiliser des variables dans les r�ponses, elles seront
	# substitu�es par leur valeur au moment de l'affichage. Exemples :
	#		$nick = nick de la personne qui a pos� la question
	#		$chan = chan sur lequel la question a �t� pos�e
	#		$question = la question qui a �t� pos�e
	#		$randnick =	nick d'une personne choisie al�atoirement sur le chan
	#								(ne peut pas �tre le nom de l'Eggdrop ni le nick de
	#								la personne qui a pos� la question)
	# Vous pouvez aussi utiliser des couleurs (selon la syntaxe habituelle),
	# du gras, du soulignement, ...

	# R�ponses si la question n'en est pas une
	set ::Oracle::replyTypes(notaquestion) {
		{si tu le dis...}
		{ok, c'est not�}
		{tr�s int�ressant, mais tu n'avais pas une question � poser ?}
		{ok, mais tu n'avais pas une question ?}
		{c'est bien, mais tu n'avais pas une question � poser ?}
		{c'est cool, mais tu n'avais pas une question � poser ?}
		{tant mieux, mais tu n'avais pas une question � poser ?}
		{chouette alors}
		{quelle bonne nouvelle !}
		{waw, c'est super int�ressant ce que tu nous racontes l�}
		{c'est fou}
		{waw ! mais tu n'avais pas une question � poser ?}
		{mon boulot est de r�pondre aux questions, pas d'�couter tes certitudes}
		{et la question est ... ?}
		{et � part �a, t'avais pas une question � me poser ?}
		{rappelle-moi quelle �tait la question d�j� ?}
		{c'est pas moi qui te dirai le contraire}
		{c'est une affirmation ?}
		{c'est une question �a ?}
		{mais o� est la question ?}
		{o� est la question dans tout �a ?}
		{super, raconte-moi ta vie...}
		{c'est comme tu le sens}
		{�a ressemble � une affirmation}
		{tu sembles bien s�r de toi}
		{tu es s�r ?}
		{ah bon ?}
	}
	# R�ponses aux questions de type "combien de temps"
	set ::Oracle::replyTypes(howmuchtime) {
		{quelques secondes}
		{quelques secondes, tout au plus}
		{une minute}
		{quelques minutes}
		{3 minutes}
		{5 minutes}
		{10 minutes}
		{une dizaine de minutes}
		{20 minutes}
		{1 heure}
		{quelques heures}
		{5 heures}
		{10 heures}
		{une journ�e enti�re}
		{2 jours}
		{2 ou 3 jours}
		{quelques jours}
		{une semaine}
		{2 semaines}
		{2 ou 3 semaines}
		{quelques semaines}
		{un mois}
		{2 mois}
		{2 ou 3 mois}
		{quelques mois}
		{6 mois}
		{1 an}
		{2 ans}
		{5 ans}
		{10 ans}
		{50 ans}
		{un si�cle}
		{un million d'ann�es}
		{quelques millions d'ann�es � 10mn pr�s}
		{�a d�pend de toi}
	}
	# R�ponses aux questions de type "combien"
	set ::Oracle::replyTypes(howmany) {
		{aucun}
		{pas un seul}
		{un seul}
		{juste un}
		{environ 2 ou 3}
		{7 ou 8}
		{une bonne dizaine}
		{je dirais 10 au moins}
		{13 � mon avis}
		{pas plus de 15}
		{environ 20}
		{� peu pr�s 25}
		{presque 30}
		{une quarantaine}
		{42}
		{pas loin de 50}
		{une bonne centaine � vue de nez}
		{plus de 1000 !}
		{des tonnes}
		{une quantit� non n�gligeable}
		{beaucoup}
		{peu}
		{tr�s peu}
		{une quantit� n�gligeable}
		{un chouia}
		{�norm�ment}
		{pas beaucoup}
		{un certain nombre}
		{quelques uns}
		{un bon paquet}
	}
	# R�ponses aux questions de type "comment est"
	set ::Oracle::replyTypes(howis) {
		{tr�s joli}
		{de la bonne taille}
		{adorable}
		{cuit � point}
		{vert � pois jaunes}
		{grand avec une moustache}
		{petit et trappu}
		{trop court}
		{trop long}
		{�norme}
		{minuscule}
		{tout bleu}
		{�trange}
		{m�morable}
		{magnifique}
		{superbe}
		{horrible}
		{impronon�able}
		{peu recommandable}
		{trop petit}
		{trop gros}
		{pas assez gros}
		{pas assez long}
		{pas assez petit}
		{velu}
		{poilu}
		{malodorant}
		{mignon}
		{exquis}
		{ridicule}
		{rigolo}
		{int�ressant}
		{inint�ressant}
		{effrayant}
		{rassurant}
	}
	# # R�ponses aux questions de type "comment sont"
	set ::Oracle::replyTypes(howare) {
		{tr�s jolis}
		{de la bonne taille}
		{adorables}
		{cuits � point}
		{verts � pois jaunes}
		{grands avec une moustache}
		{petits et trappus}
		{trop courts}
		{trop longs}
		{�normes}
		{minuscules}
		{tout bleus}
		{�tranges}
		{m�morables}
		{magnifiques}
		{superbes}
		{horribles}
		{impronon�ables}
		{peu recommandables}
		{trop petits}
		{trop gros}
		{pas assez gros}
		{pas assez longs}
		{pas assez petits}
		{velus}
		{poilus}
		{malodorants}
		{mignons}
		{exquis}
		{ridicules}
		{rigolos}
		{int�ressants}
		{inint�ressants}
		{effrayants}
		{rassurants}
	}
	# R�ponses aux questions de type "comment va"
	set ::Oracle::replyTypes(howgoodis) {
		{tr�s bien}
		{pas trop bien}
		{je ne sais pas}
		{aucune id�e}
		{ne demande pas}
		{demande-lui}
		{bien}
		{mal}
		{couci-cou�a}
		{demande � $randnick}
	}
	# R�ponses aux questions de type "comment vont"
	set ::Oracle::replyTypes(howgoodare) {
		{tr�s bien}
		{pas trop bien}
		{je ne sais pas}
		{aucune id�e}
		{ne demande pas}
		{demande-leur}
		{bien}
		{mal}
		{couci-cou�a}
		{demande � $randnick}
	}
	# R�ponses aux questions de type "comment faire"
	set ::Oracle::replyTypes(howto) {
		{en y passant plus de temps}
		{en changeant de main de temps en temps}
		{en travaillant dur}
		{en demandant de l'aide � un ami}
		{en y mettant les doigts}
		{avec les doigts}
		{en te sortant les doigts du nez}
		{en arr�tant de croire qu'un bot d�tient la v�rit�}
		{en mangeant des quenelles}
		{en arr�tant d'�tre un boulet}
		{en y pensant tr�s fort}
		{en y croyant tr�s fort}
		{en chatouillant $randnick}
		{en demandant � $randnick}
		{en sautillant sur place}
		{en se roulant par terre}
		{en n'y allant pas par quatre chemins}
		{en prenant un air d�cid�}
		{en prenant beaucoup de pr�cautions}
		{en prenant son temps}
		{tout seul}
		{aussi rapidement que possible}
		{lentement et consciencieusement}
		{en utilisant un trombone et un chewing-gum}
		{avec beaucoup de courage}
		{� mains nues}
		{en appelant des renforts}
		{librement, sans se poser de questions}
		{avec l'aide de $randnick}
		{avec beaucoup d'enthousiasme}
		{sans beaucoup de conviction}
		{en �vitant les obstacles}
		{avec l'aide d'un super-h�ros}
		{en se tapant la t�te contre un mur}
		{en s'organisant}
		{en arr�tant de faire n'importe quoi}
		{en se munissant d'une bo�te � outils}
		{en utilisant assez d'explosif pour raser tout le quartier}
		{en utilisant de la colle extra-forte}
		{avec l'aide d'un truc en mousse}
		{en faisant de ton mieux}
		{en y allant doucement}
		{avec les outils adapt�s}
		{en allumant un cierge}
		{en criant et en tapant du pied}
	}
	# R�ponses aux questions de type "avec quoi"
	set ::Oracle::replyTypes(withwhat) {
		{un pot de cornichons}
		{une petite cuiller}
		{un caillou}
		{une p�niche}
		{une crotte de bantha}
		{un tuyau perc�}
		{de la cr�me pour les pieds}
		{du viagra}
		{du talc}
		{de la vaseline}
		{une fourchette}
		{un d�monte-pneu}
		{une grue de chantier}
		{une pelle � neige}
		{des bretelles}
		{une roue de v�lo}
		{du cirage noir}
		{un chausse-pied}
		{une batte de baseball}
		{un tournevis}
		{un couteau}
		{du fard � paupi�res}
		{de la sauce piment�e}
		{un moule � gauffres}
		{une tartine beurr�e}
		{un balai � chiottes}
		{un air innocent}
		{une pelleteuse}
		{un parachute}
		{les doigts}
		{une pince � �piler}
		{un objet inconnu}
		{une chaussette}
		{de bonnes intentions}
		{de l'humour}
		{une bo�te � outils}
		{assez d'explosif pour raser tout le quartier}
		{de la colle extra-forte}
		{un truc en mousse}
		{une d�claration d'amour}
		{une bonne dose d'humour}
		{du papier recycl�}
		{un pied de biche}
	}
	# R�ponses aux questions de type "comment"
	set ::Oracle::replyTypes(howshould) {
		{en mettant tous tes doigts dans ton nez en m�me temps}
		{en prenant beaucoup de pr�cautions}
		{en prenant ton temps}
		{en �vitant les obstacles}
		{tout seul}
		{un ouvre-bo�te}
		{un taille-crayon}
		{aussi rapidement que possible}
		{lentement et consciencieusement}
		{avec un ami}
		{avec quelqu'un que tu aimes bien}
		{ne le fais pas, c'est mieux}
		{fais-le simplement}
		{pas tout seul}
		{avec de l'aide}
		{en utilisant un trombone et un chewing-gum}
		{en y pensant tr�s fort}
		{avec beaucoup de courage}
		{sans beaucoup de conviction}
		{� mains nues}
		{je ne sais pas comment faire �a}
		{en appelant des renforts}
		{avec l'aide de tes parents}
		{librement, sans te poser de questions}
		{avec l'aide de $randnick}
		{avec un solide sens de l'humour}
		{avec beaucoup d'enthousiasme}
		{en tapant tout ce qui bouge}
		{en prenant un marteau plus gros}
		{avec de la d�licatesse}
		{vite et bien}
		{avec des gants}
		{avec du tact}
		{avec de la subtilit�}
	}
	# R�ponses aux questions de type "quand"
	set ::Oracle::replyTypes(when) {
		{�a s'est d�j� produit dans le pass�, tu n'avais qu'� �tre l�}
		{tu l'as manqu�, c'�tait il y a 1 heure}
		{maintenant ! ah trop tard}
		{pourquoi pas maintenant ?}
		{maintenant}
		{aujourd'hui}
		{dans 1 minute}
		{dans 3 minutes}
		{dans 5 minutes}
		{dans 5mn, si $randnick ne nous retarde pas...}
		{dans 10 minutes}
		{dans 15 minutes}
		{dans 20 minutes}
		{dans 30 minutes}
		{dans une heure}
		{dans moins de 2 heures}
		{dans 2 heures}
		{cette nuit}
		{demain}
		{demain matin � 6h}
		{demain apr�s-midi}
		{dans 2 jours}
		{dans 3 jours}
		{dans 4 jours}
		{dans 5 jours}
		{dans 6 jours}
		{dans 1 semaine}
		{la semaine prochaine}
		{le mois prochain}
		{dans 2 mois}
		{dans 3 mois}
		{dans 6 mois}
		{dans 1 an}
		{dans le courant de l'ann�e prochaine}
		{dans 2 ans}
		{dans 3 ans}
		{dans 5 ans}
		{dans 10 ans}
		{dans 20 ans}
		{dans 50 ans}
		{dans quelques ann�es}
		{dans 1 si�cle}
		{dans 1000 ans}
		{dans 1 million d'ann�es}
		{dans quelques millions d'ann�es � 10mn pr�s}
		{en janvier}
		{en f�vrier}
		{en mars}
		{en avril}
		{en mai}
		{en juin}
		{en juillet}
		{en ao�t}
		{en septembre}
		{en octobre}
		{en novembre}
		{en d�cembre}
		{cet �t�}
		{cet hiver}
		{au printemps}
		{en automne}
		{trois jours avant la 2�me pleine lune apr�s ton prochain anniversaire}
		{le jour de ton anniversaire}
		{d�s qu'il se mettra � pleuvoir}
		{d�s qu'il se mettra � neiger}
		{quand les poules auront des dents}
		{� la saint Glinglin}
		{apr�s le d�luge}
		{� la prochaine pleine lune}
		{�a n'arrivera pas � moins que tu ne quittes d�s maintenant ton �cran pour agir}
		{jamais}
		{jamais}
		{jamais}
		{jamais}
		{jamais}
	}
	# R�ponses aux questions de type "pourquoi"
	set ::Oracle::replyTypes(why) {
		{pourquoi pas ?}
		{parce que c'est comme �a et puis c'est tout}
		{parce que c'est comme �a}
		{pour te donner l'air intelligent}
		{pour te ridiculiser}
		{parce que c'est beaucoup plus marrant comme �a}
		{parce qu'on lui a demand� de le faire}
		{pour te faire parler}
		{parce que tu le vaux bien}
		{parce que t'es un boulet}
		{parce que t'es un marrant}
		{parce que t'es un winner}
		{parce que sinon, �a ne serait pas dr�le}
		{parce que :)}
		{parce que $randnick l'a dit}
		{parce que $randnick l'a pr�dit}
		{parce que $randnick a insist� pour �a}
		{� l'origine, c'�tait pour faire plaisir � $randnick}
		{parce que Nostradamus l'a pr�dit}
		{parce que le monde est injuste}
		{parce que c'est ainsi que vont les choses}
		{pour te faire plaisir}
		{pour t'emmerder}
		{pour te faire taper "!oracle $question"}
		{parce que l'�quilibre de l'univers en d�pend}
		{parce que t'as pas de chance}
		{parce que le hasard en a d�cid� ainsi}
		{je t'en pose des questions ?}
	}
	# R�ponses aux questions de type "qui"
	set ::Oracle::replyTypes(who) {
		{quelqu'un de bien}
		{quelqu'un qui pose moins de questions que toi}
		{un mutant avec des tentacules}
		{un homme d�guis� en femme}
		{le plus gros boulet connu}
		{un illustre inconnu}
		{ta soeur}
		{un malade mental}
		{$randnick}
		{$randnick}
		{$randnick}
		{ton p�re}
		{ta m�re}
		{un pote de ta soeur}
		{une amie de ta m�re}
		{un voisin}
		{un ami qui te veut du bien}
		{ton meilleur ami}
		{D�d� le Cochon}
		{un fuyard recherch� par la police}
		{un emmerdeur de premi�re}
		{quelqu'un qui ne veut pas �tre reconnu}
		{un animal de compagnie}
		{un psychopathe}
		{personne d'autre que toi}
		{toi-m�me}
		{toi}
		{moi}
		{c'est pas moi}
	}
	# R�ponses aux questions de type "o�"
	set ::Oracle::replyTypes(where) {
		{dans la for�t}
		{dans la cuisine}
		{dans un lit}
		{dans ton lit}
		{sous le lit}
		{dehors}
		{� l'int�rieur}
		{en Italie}
		{au V�n�zuela}
		{en Suisse}
		{en Australie}
		{pr�s de ton meilleur ami}
		{pr�s de ton pire ennemi}
		{chez toi}
		{sur ton lieu de travail}
		{dans le placard}
		{dans la rue}
		{dans la cave}
		{dans une voiture}
		{sur le tapis}
		{sous le tapis}
		{accroch� au mur}
		{dans un couloir}
		{devant ton ordinateur}
		{sur une chaise}
		{dans le r�frig�rateur}
		{attach� � un monument}
		{dans la maison d'un ami}
		{dans la main de quelqu'un que tu aimes bien}
		{au fond de l'oc�an}
		{� DisneyLand}
		{au McDo}
		{dans les toilettes}
		{dans une baignoire}
		{dans l'herbe d'un pr�}
		{derri�re des portes ferm�es}
		{dans la 4�me dimension}
		{� c�t� de toi}
		{sur la lune}
		{quelque part dans la galaxie}
		{quelque part o� tu ne peux pas le voir}
		{par l� -->}
		{ici}
		{tu as regard� sur www.perdu.com ?}
		{sur ce chan}
		{chez $randnick}
		{dans le frigo de $randnick}
		{sur les genoux de $randnick}
		{sur une autre plan�te}
		{DTC}
		{DTC}
		{DTC}
		{DTC}
	}
	# R�ponses neutres. Attention � ce que vous mettez dans cette cat�gorie, �a
	# doit �tre le plus neutre possible afin de convenir � tous les types de
	# questions.
	set ::Oracle::replyTypes(neutral) {
		{oh regarde l� bas ! une diversion !}
		{ne parlons pas des choses qui f�chent}
		{mieux vaut changer de sujet}
		{la r�ponse est : 42}
		{il faudrait �tre vraiment d�rang� pour r�pondre � �a}
		{c'est une question que tu devrais te poser � toi-m�me}
		{je ne sais pas}
		{si tu savais...}
		{tu as de ces questions...}
		{*Joker*}
		{je ne peux pas avoir r�ponse � tout}
		{demande � quelqu'un d'autre}
		{tu n'as pas besoin de le savoir}
		{TUUUT TUUUT TUUUT TUUUT}
		{il y a des questions qu'il vaut mieux ne pas poser}
		{je ne sais pas \00313*rougit*\003}
		{...}
		{je ne r�pondrai pas � �a}
		{il y a des choses qu'il vaut mieux ne pas savoir}
		{c'est quoi ces questions ?  \037oO\037'}
		{on t'a pay� pour m'emmerder ?}
		{va savoir...}
		{je pourrais te r�pondre mais apr�s cela je serais oblig� de te tuer}
		{comment suis-je sens� savoir �a ? je suis une fonction al�atoire dans un bot, tu sais ?}
		{tu es trop intelligent pour demander �a}
		{donne moi de l'argent et je verrai ce que je peux faire}
		{plus de donn�es sont requises pour r�pondre pr�cis�ment � cette question}
		{merci de reformuler votre question}
		{erreur de syntaxe}
		{Cette fonction sonne occup�. Merci de r�essayer dans quelques minutes...}
		{d�sol�, je n'�coutais pas}
		{il est totalement impossible de r�pondre objectivement � cette question}
		{je ferais mieux de ne pas te r�pondre maintenant}
		{et toi tu en penses quoi ?}
		{oublie �a}
		{qui s'en soucie ?}
		{on s'en fout}
		{osef}
		{je m'en fous un peu en fait}
		{question stupide, au suivant}
		{crois-moi, tu ne veux pas vraiment le savoir}
		{tu n'aimerais pas conna�tre la r�ponse}
		{la r�ponse ne va pas te plaire}
		{demande donc � $randnick}
		{$randnick pourrait t'en parler...}
		{je suis vraiment oblig� de r�pondre � toutes les questions idiotes ?}
		{tu connais d�j� la r�ponse}
	}
	# R�ponses de type oui/non
	set ::Oracle::replyTypes(yesno) {
		{oui}
		{oui}
		{oui}
		{oui}
		{oui}
		{oui}
		{oui}
		{oui}
		{non}
		{non}
		{non}
		{non}
		{non}
		{non}
		{non}
		{non}
		{pas forc�ment}
		{peut-�tre dans un futur proche}
		{peut-�tre}
		{je ne parierais pas l� dessus}
		{oui, absolument}
		{pas n�cessairement}
		{oh que oui !}
		{oui, peut-�tre}
		{�a se pourrait}
		{les rumeurs disent que oui}
		{�videmment pas, cesse de poser des questions stupides}
		{oui : 78 | non : 93 | votes blancs : 4 | abstention : 15}
		{�a va pas non ?}
		{bien s�r}
		{il y a des chances}
		{il y a peu de chances}
		{ne dis pas n'importe quoi}
		{sois-en s�r}
		{pas du tout}
		{t'as qu'� compter l� dessus}
		{tr�s certainement, oui}
		{absolument pas}
		{�videmment, quelle question !}
		{qui t'a racont� �a ?!}
		{ouais et y'a ptet des pingouins sur Mars aussi...}
		{oui mais non}
		{c'est possible en effet}
		{la probabilit� est de 1/9702831101}
		{bien s�r, �a a m�me �t� pr�dit par l'Institut des Risques Majeurs}
		{ben oui, tu es bien le seul � en douter encore}
		{et pas qu'un peu !}
		{non, pas du tout... ah... on me dit que si dans mon oreillette...}
		{si je te dis que non, tu vas pas aller te suicider ou un autre truc dingue ?}
		{ah non pas du tout}
		{si �a te fait plaisir d'y croire, alors oui}
		{ouais}
		{seulement si tu y crois tr�s fort}
		{mmh je dirais que oui}
		{d�sol�, rien n'est moins s�r}
		{La r�ponse m'appara�t un peu floue mais on dirait que c'est oui}
		{La r�ponse est non seulement si Saturne est align�e avec Pluton et Neptune}
		{nop :(}
		{yep :)}
		{il semblerait que non mais c'est peut-�tre un bug}
		{si mes sources sont fiables, oui}
		{c'est certain}
		{j'en doute}
		{tel que je le vois, ma r�ponse est oui}
		{ouais, et moi je suis le Pape}
		{c'est ridicule !}
		{tu aimerais, hein ?}
		{ouep ^^}
		{s�r !}
		{j'esp�re que tu plaisantes...}
		{m�me pas en r�ve}
		{seulement dans ton imagination}
		{on dirait bien que oui}
		{je crois que oui}
		{grave !}
		{bah, c'est n'importe quoi}
		{c'est incroyable le nombre de rumeurs qui peuvent circuler sur ce chan...}
		{$randnick ne pourra pas dire le contraire}
		{ou pas}
	}

 ############################################################################
### Fin de la configuration
 ############################################################################




 ##############################################################################
### initialisation
 ##############################################################################
	variable scriptname "Oracle"
	variable version "2.31.20170914"
	variable DEBUGMODE 0
	setudef flag oracle
	scan $flood_threshold "%d:%d" ::Oracle::antiflood_max_instances ::Oracle::antiflood_instance_length
	array set ::Oracle::instance {}
	array set ::Oracle::antiflood_msg {}
	array set ::Oracle::phonetics_table {}
	# Proc�dure de d�sinstallation (le script se d�sinstalle totalement avant
	# chaque rehash ou � chaque relecture au moyen de la commande "source" ou
	# autre)
	proc uninstall {args} {
		putlog "D�sallocation des ressources de ${::Oracle::scriptname}..."
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		foreach running_utimer [utimers] {
			if { [::tcl::string::match "*[namespace current]::*" [lindex $running_utimer 1]] } { killutimer [lindex $running_utimer 2] }
		}
		namespace delete ::Oracle
	}
}

 ##############################################################################
### proc�dure principale
 ##############################################################################
#proc ::Oracle::ask_oracle {nick host handle chan question} {
proc ::Oracle::ask_oracle {nick chan question} {
	if { [set question [::tcl::string::trim $question]] eq "" } {
		puthelp "PRIVMSG $chan :!$nick"
		return
	} elseif { $question eq "?" } {
		puthelp "PRIVMSG $chan :!$nick ?"
		return
	} else {
		# Si la question pos�e... n'est pas une question.
		if { ![::tcl::string::match "*\\?*" $question] } {
			set detected_question_type "notaquestion"
			set answer [::Oracle::process_answer $nick $chan $question [lindex $::Oracle::replyTypes($detected_question_type) [set answer_index [rand [llength $::Oracle::replyTypes($detected_question_type)]]]]]
		} else {
			set nick_hash [md5 $nick]
			set phonetics [::HaploPhone::process [::tcl::string::map {"�" "<" "�" ">" "�" "\"" "�" "\"" "�" "..."} $question]]
			set known_question 0
			# On d�finit le type de question par d�faut si aucun type n'est reconnu.
			set detected_question_type "yesno"
			# On tente de reconnaitre le type de question.
			foreach currentType $::Oracle::enabledTypes {
				if { [regexp -nocase $::Oracle::regexpTypes($currentType) $question] } {
					set detected_question_type $currentType
					break
				}
			}
			# On d�finit que, par d�faut, le type de r�ponse sera li� au type de
			# question d�tect�.
			set applied_question_type $detected_question_type
			# Si la question a d�j� �t� pos�e, on retrouve la r�ponse qui a �t� donn�e.
			if { [set array_entry [::Oracle::compare_RDR $nick_hash $detected_question_type $phonetics]] != -1 } {
				set known_question 1
				lassign [split $::Oracle::phonetics_table($array_entry) "�"] applied_question_type answer_index
			# Al�atoirement, on obtient une r�ponse neutre quelle que soit la
			# question.
			} elseif { [expr ([clock clicks -milliseconds] % 100) + 1] <= $::Oracle::neutral_rate } {
				set applied_question_type "neutral"
			}
			# On choisit une r�ponse au hasard.
			if { ![::tcl::info::exists answer_index] } { 
				set answer_index [rand [llength $::Oracle::replyTypes($applied_question_type)]]
			}
			set answer [::Oracle::process_answer $nick $chan $question [lindex $::Oracle::replyTypes($applied_question_type) $answer_index]]
			# Si cette question n'a jamais �t� pos�e auparavant, on la m�morise.
			if { !$known_question } {
				# Si le nombre de questions stock�es en m�moire atteint la limite
				# autoris�e ($max_memory), on supprime la plus ancienne.
				if { [array size ::Oracle::phonetics_table] >= $::Oracle::max_memory } {
					unset ::Oracle::phonetics_table([lindex [lsort [array names ::Oracle::phonetics_table]] 0])
				}
				# On stocke la valeur phon�tique de la question, ainsi que la r�ponse
				# associ�e.
				set ::Oracle::phonetics_table([unixtime]�${nick_hash}�${phonetics}�$detected_question_type) "${applied_question_type}�$answer_index"
			}
		}
		::Oracle::output_message "$nick > $answer"
		# On ajoute manuellement aux logs puisque le logger interne ne le fait pas
		# avec les commandes et les r�ponses de l'Eggdrop.
		#putloglev p $chan "<$nick> $::Oracle::oracle_cmd $question"
		#putloglev p $chan "<$::botnick> $nick > $answer"
	}
}

 ##############################################################################
### Neutralisation des antislashes (sauf codes de contr�le \002 \003 \022
### \037 \026 \017) et substitution des variables dans les r�ponses.
 ##############################################################################
proc ::Oracle::process_answer {nick chan question answer} {
	# set randnick [::Oracle::randnick $nick $chan]
	set randnick "TEMP"
	return [subst -nocommands [regsub -all {(?!\\002|\\003|\\022|\\037|\\026|\\017)(\\)} $answer {\\\\}]]
}

 ##############################################################################
### Recherche de correspondances ayant un rapport de relation diff�rentielle
### inf�rieur � la tol�rance d�finie dans la table phon�tique.
 ##############################################################################
proc ::Oracle::compare_RDR {nick_hash detected_question_type phonetics} {
	if { [::tcl::info::exists ::Oracle::phonetics_table] } {
		foreach array_entry [array names ::Oracle::phonetics_table] {
			lassign [split $array_entry "�"] {} stored_nick_hash stored_phonetics stored_question_type
			if {
				($nick_hash eq $stored_nick_hash)
				&& ($detected_question_type eq $stored_question_type)
				&& ([::RDR::RDR $stored_phonetics $phonetics] <= $::Oracle::RDR_tolerance)
			} then {
				return $array_entry
			}
		}
		return -1
	}
}

 ##############################################################################
### Retourne un nick al�atoire parmi les users pr�sents sur le chan (sauf
### l'Eggdrop, sauf les autres Eggdrops du botnet, sauf l'user qui a pos� la
### question).
 ##############################################################################
proc ::Oracle::randnick {nick chan} {
	set users_list [lreplace [set users [chanlist $chan -b|]] [set index [lsearch $users $nick]] $index]
	set users_list [lreplace $users_list [set index [lsearch $users_list $::nick]] $index]
	if {![llength $users_list]} {
		return "quelqu'un"
	}
	return [lindex $users_list [rand [llength $users_list]]]
}

 ##############################################################################
### Accord au singulier ou au pluriel.
 ##############################################################################
proc ::Oracle::plural {value singular plural} {
	if {
		($value >= 2)
		|| ($value <= -2)
	} then {
		return $plural
	} else {
		return $singular
	}
}

 ###############################################################################
### Affichage d'un message.
 ###############################################################################
proc ::Oracle::output_message {data} {
	# Filtrage des styles si n�cessaire.

	return $data
	#if { ($::Oracle::monochrome == 1)
	#	|| ([::tcl::string::match *c* [lindex [split [getchanmode $chan]] 0]])
	#} then {
	#	put$queue "PRIVMSG $chan :[regsub -all "\017" [stripcodes abcgru $data] ""]"
	#} else {
	#	put$queue "PRIVMSG $chan :$data"
	#}
	#return
}

 ###############################################################################
### Test de l'existence d'un utimer, renvoi de son ID.
 ###############################################################################
proc ::Oracle::utimerexists {command} {
	foreach utimer_ [utimers] {
		if { ![::tcl::string::compare $command [lindex $utimer_ 1]] } then {
			return [lindex $utimer_ 2]
		}
	}
	return
}

 ##############################################################################
### Commande !oracle_db_size : affiche le nombre de r�ponses dans la base
### de donn�es.
 ##############################################################################
proc ::Oracle::show_db_size {nick host handle chan arg} {
	set total 0
	foreach currentType $::Oracle::enabledTypes {
		if { [::tcl::info::exists output] } {
			append output " \00307|\003 "
		}
		append output "$currentType :\00314 [set num_answers [llength $::Oracle::replyTypes($currentType)]]\003"
		incr total $num_answers
	}
	append output " \00307|\003 notaquestion :\00314 [set num_answers1 [llength $::Oracle::replyTypes(notaquestion)]]\003 \00307|\003 yesno :\00314 [set num_answers2 [llength $::Oracle::replyTypes(yesno)]]\003"
	set total [expr $total + $num_answers1 + $num_answers2]
	append output " \00304|\003 nombre total de r�ponses dans la base de donn�es :\00314 $total\003"
	::Oracle::output_message $chan help "$output"	
}

 ###############################################################################
### Contr�le du flood.
 ###############################################################################

##### INTERNE A CHAMOT: LA FONCTION N4AURAIS PAS ETE APPELLE ######

 ##############################################################################
### Binds
 ##############################################################################
bind pub $::Oracle::oracleauth $::Oracle::oracle_cmd ::Oracle::ask_oracle
bind pub n !oracle_db_size ::Oracle::show_db_size
bind evnt - prerehash ::Oracle::uninstall


putlog "$::Oracle::scriptname v$::Oracle::version (�2009-2017 MenzAgitat) a �t� charg�."
