#!/bin/bash
#871314, Martínez Giménez, Carlos Tristán, M, 3, B
#873338, Mateo Lorente, Diego, M, 3, B

OLDIFS="$IFS"
if [ "$#" -eq 2 ]
then
	if [ "$EUID" -ne 0 ]
	then
		echo "Este script necesita privilegios de administracion" 1>&2
		exit 1
	else
		IFS=","
		if [ "$1" = "-a" ]
		then
			cat "$2" | while read logname passwd nombre
			do
				if [ -z "$logname" -o -z "$passwd" -o -z "$nombre" ]
				then
					echo Campo invalido
				else
					IFS=":"
					yaUsuario=0
					cat "/etc/passwd/" | while read nomUser
					do
						if [ nomUser -eq logname -a yaUsuario -eq 0 ]
						then
							yaUsuario=1
							echo El usuario $logname ya existe
						fi
					done
					if [ yaUsuario -eq 0 ]
					then
						useradd -m -U -c "$nombre" -K PASS_MAX_DAYS=30 -K UID_MIN=1815 "$logname"
						echo $nombre ha sido creado
						echo "$logname:$passwd" | chpasswd
						usermod -U "$logname"
					fi
					IFS=","
				fi
			done
		elif [ "$1" = "-s" ]
		then
			if [ ! -d "/extra" ]
			then
				mkdir /extra/
			fi
			if [ ! -d "/extra/backup" ]
			then
				mkdir /extra/backup
			fi
			cat "$2" | while read logname resto
			do
				if [ -z "$logname" ]
				then
					echo Campo invalido
				elif [ $(cat /etc/passwd | grep "$logname" | wc -l) -ne 0 ]
				then
					if [ tar cfP "/extra/backup/$nombre.tar" "$(cat /etc/passwd | grep "$nombre:" | cut -d':' -f6)"
					then
						userdel -r "$nombre"
					fi
				fi
			done
		else
			echo "Opcion invalida" 1>&2
		fi
	fi
else
	echo Numero incorrecto de parametros
