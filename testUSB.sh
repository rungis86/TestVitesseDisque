#! /bin/bash

DroitsRoot(){
	echo 
	echo "Une commande du script nécessite les droits root"
	echo 
	sudo -v
}

ListePeripheriques(){
	lsblk
}

ChoixDisque(){
	echo
	echo "$(tput setaf 2)Entrez le périphérique au format /dev/XXX$(tput setaf 15)"

	read disque

	echo
	echo "$(tput setaf 2)Voulez-vous lancer le test avec le disque $disque ? (O/N)$(tput setaf 15)"
	
	read ReponseTest

	if [[ $ReponseTest != "O" ]]; then
		echo "Fin du programme"
		exit
	else
		echo
	fi
}

ModeleCleUSB(){
	echo "$(tput setaf 2)Quel est le nom ou le modèle de la clé USB ?$(tput setaf 15)"
	read NomModeleCleUSB
	echo
}

TestEcriture(){
	NbTest=3
	PointDeMontage=$(lsblk -o MOUNTPOINTS $disque | tail -n 1)

	echo "Démarrage du test d'écriture"
	echo

	for i in $(seq $NbTest); do
		dd if=/dev/zero of="$PointDeMontage/tempfile" bs=1M count=1024 2>> /tmp/TestEcriture
	done

	VitesseEcritureMoyenne=$(grep MB /tmp/TestEcriture | sed -e 's/,/./g' | awk '{sum+=$9} END {print sum/3}')

	rm /tmp/TestEcriture
	sudo -v
}

TestLecture(){
	echo "Démarrage du test de lecture"

	sudo /sbin/sysctl -w vm.drop_caches=3 > /dev/null

	for i in $(seq $NbTest); do
		dd if="$PointDeMontage/tempfile" of=/dev/null bs=1M count=1024 2>> /tmp/TestLecture
	done	

	VitesseLectureMoyenne=$(grep MB /tmp/TestLecture | sed -e 's/,/./g' | awk '{sum+=$9} END {print sum/3}')

	rm /tmp/TestLecture
	echo
}

SuppressionTempfile(){
	rm "$PointDeMontage/tempfile"
}

AffichageResultats(){
	echo "Résultats des tests ($NomModeleCleUSB) :"
	echo "Vitesse d'écriture : $VitesseEcritureMoyenne MB/s"
	echo "Vitesse de lecture : $VitesseLectureMoyenne MB/s"
}

RemplissageFichierBDDTests(){
	DateHeure=$(date)
	echo $DateHeure >> FichierBDDTest
	echo $NomModeleCleUSB >> FichierBDDTest
	echo "Vitesse d'écriture : $VitesseEcritureMoyenne MB/s" >> FichierBDDTest
        echo "Vitesse de lecture : $VitesseLectureMoyenne MB/s" >> FichierBDDTest
	echo "" >> FichierBDDTest
}

main(){
	DroitsRoot
	ListePeripheriques
	ChoixDisque
	ModeleCleUSB
	TestEcriture
	TestLecture
	SuppressionTempfile
	AffichageResultats
	RemplissageFichierBDDTests
}

main