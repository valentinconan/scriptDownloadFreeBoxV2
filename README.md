scriptDownloadFreeBoxV2
=====================

SHELL> Un petit script permettant de lancer à distance, un téléchargement sur sa FreeBox v6 (firmware 2.0.1). Conçu pour fonctionner avec la nouvelle api FreeboxOS

Versions des outils utilisés : 
- FreeBox v6 (firmware 2.0.1) 
- resty https://github.com/micha/resty
- OpenSSL/0.9.8o 

Configuration : Editez le scriptDownloadFreeBoxV2 et modifiez les trois variables suivantes avec vos données:

Afin de récupérer les informations ci dessous, consulter la documentation Free : http://dev.freebox.fr/sdk/os/

- freebox="XXX.XXX.XXX.XXX:port" #IP de la freebox avec le port de l'interface web (par défaut 80)
- app_id="votre app id" #Valeur indiqué lors de la première authentification en local
- app_token="votre app token" #Valeur retourné par la freebox lors de la première authentification en local

Utilisation : "bash scriptDownloadFreeBoxV2 \<lien [HTTP]|[FTP]|[HTTPS]>"

=====================
