#! /bin/bash

fichier="resty" #Nom du fichier pour RESTY
freebox="XXX.XXX.XXX.XXX:port" #IP de la freebox
app_id="votre app id" #Valeur indiqu� lors de la premi�re authentification en local
app_token="votre app token" #Valeur retourn� par la freebox lors de la premi�re authentification en local
version=1 #Version de l'api

#V�rification de la pr�sence du fichier pour RESTY, le t�l�charge s'il n'est pas pr�sent
if ! [ -f $fichier ]; then
    echo "Telechargement de RESTY"
    curl -L http://github.com/micha/resty/raw/master/resty > $fichier
fi

#Mise en source du fichier RESTY
. ./$fichier

#Host de RESTY
resty $freebox

###########################################################
################## D�but de la connexion ##################
###########################################################

    #Cr�ation d'un fichier temporaire pour y stocker la chaine de caract�re contenant la r�ponse de la freebox pour le login
    login=$( mktemp )

    #Demande de login
    GET /api/v$version/login >& $login

    echo -ne "\nDemande de challenge pour connexion"

    #V�rification de la r�ponse positive de la freebox, arrêt du script si ce n'est pas le cas
    if grep -q "\"success\":true" $login; then
        echo -e "\t\t< OK >"
    else
        echo -e "\t\t<ERREUR>"
        echo -e "\nImpossible de joindre la freebox"
        rm $login > /dev/null 2>&1 #Suppression du fichier temporaire contenant la r�ponse de la freebox pour le login
        exit 1
    fi

    #R�ccup�ration du "$challenge" parmis la chaine retourn�e par la freebox
    challenge=`grep "challenge" $login | cut -f 5 -d ':' | cut -f 1 -d ',' | sed 's/\\\//g' | sed "s/\"//g" | sed "s/\r//g" | sed "s/\n//g"`

    #Cr�ation du password = hash($challenge,$app_token)
    password=`echo -n  $challenge | openssl dgst -sha1 -hmac $app_token`

    #Envoie du mot de passe pour se connecter
    POST /api/v$version/login/session '{"app_id": "'$app_id'","password": "'$password'"}' -Q >& $login

    #V�rification de la connexion sur la freebox, arrêt du script si ce n'est pas le cas
    echo -en "\nConnexion sur la freebox"
    if grep -q "\"success\":true" $login; then
        echo -e "\t\t\t< OK >"
    else
        echo -e "\t\t\t<ERREUR>"
        echo -e "\nImpossible de se connecter sur la freebox"
        rm $login > /dev/null 2>&1 #Suppression du fichier temporaire contenant la r�ponse de la freebox pour le login
        exit 1
    fi

    #R�ccup�ration du "$session_token" parmis la chaine retourn�e par la freebox
    session_token=`grep "session_token" $login | cut -f 3 -d ':' | cut -f 1 -d ',' | sed 's/\\\//g' | sed "s/\"//g" | sed "s/\r//g" | sed "s/\n//g"`

    #Suppression du fichier temporaire contenant la r�ponse de la freebox pour le login
    rm $login > /dev/null 2>&1

###########################################################
################### fin de la connexion ###################
###########################################################

#Cr�ation d'un fichier temporaire pour y stocker la chaine de caract�re contenant la r�ponse de la freebox pour l'envoi d'un t�l�chargement
download=$( mktemp )

#Envoie le fichier en t�l�chargement par url sur la freebox grâce au lien mis en param�tre du script en pr�cisant le "$session_token"
POST /api/v$version/downloads/add download_url=$1 -H "X-Fbx-App-Auth: $session_token" >& $download

#V�rification du succ�s de la demande de t�l�chargement, arrêt du script si ce n'est pas le cas
echo -en "\nAjout du telechargement la freebox"
if grep -q "\"success\":true" $download; then
    echo -e "\t\t< OK >"
else
    echo -e "\t\t<ERREUR>"
    echo -e "\nImpossible de rajouter le telechargement"
    rm $download > /dev/null 2>&1 #Suppression du fichier temporaire contenant la r�ponse de la freebox pour le t�l�chargement  
    exit 1
fi

#Suppression du fichier temporaire contenant la r�ponse de la freebox pour le t�l�chargement
rm $download > /dev/null 2>&1

#FIN DE SCRIPT DE TELECHARGEMENT
echo -e "\nFin du script de telechargement\t\t\t< OK >\n"