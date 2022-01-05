#!/bin/bash

###################################################################
#Script Name	: brodooinstall/dev_env/install.sh
#Description	: Instalando o Odoo em ambiente de desenvolvimento.
#Author       	: Renan Teixeira
#Email         	: contato@renanteixeira.com.br
#Version        : 0.1 - 04/01/2022
#Language		: pt-BR
###################################################################

# Cores para os comandos
GREEN="\e[92m"
RED="\e[31m"
END="\e[0m"
BLUE="\e[34m"
YELLOW="\e[33m"

# Valores Padrões
ODOO_INSTALL_DIR=~/Development/Odoo

# Centralizar mensagem
center() {
	termwidth="$(tput cols)"
	padding="$(printf '%0.1s' ={1..500})"
	printf '%*.*s %s %*.*s\n' 0 "$(((termwidth - 2 - ${#1}) / 2))" "$padding" "$1" 0 "$(((termwidth - 1 - ${#1}) / 2))" "$padding"
}

# Verificando a permissão do usuário
checkUserPermission() {
	clear
	if [ ! "$(id -u)" -ne 0 ]; then
		printf "${RED}"
		center "Não execute este script com o usuário root!"
		printf "${END}"
		exit 1
	else
		updateSystem
	fi
}

# Atualizando o sistema.
updateSystem() {
	clear
	printf "${BLUE}"
	center "Atualizando o sistema"
	printf "${END}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt dist-upgrade -y
	sudo apt autoremove -y

	printf "${GREEN}"
	center "Sistema atualizado"
	basicAptDependencies
	printf "${END}"
}

# Instalando as dependências apt iniciais
basicAptDependencies() {
	clear
	printf "${BLUE}"
	center "Instalando dependências básicas do linux"
	printf "${END}"
	sudo apt install git wget curl vim python3-pip python3-venv -y

	checkEnvFile
}

# Verificando arquivo .env
checkEnvFile() {
	if [ ! -f .env ]; then
		notEnvFile
	else
		printf ${BLUE}
		echo "Encontramos o arquivo (${PWD}/.env), deseja tentar utilizar ele?"
		printf ${GREEN}
		echo
		cat .env
		echo
		printf ${END}
		echo "[1] Sim, utilizar este arquivo"
		echo "[2] Não, cancelar processo"
		echo
		echo -n "Escolha uma opção: "
		read optionCheckEnvFile
		case $optionCheckEnvFile in
		1) printf ${GREEN}; echo "Ok, vamos seguir"; printf ${END}; set -o allexport; source .env; set +o allexport; echo ${TEST_ENV} ;;
		2) printf ${RED}; echo "Processo cancelado"; printf ${END}; exit 1 ;;
		*) checkEnvFile ;;
		esac
	fi
}

notEnvFile() {
	printf ${YELLOW}
	echo "Arquivo (${PWD}/.env) não encontrado, o que deseja fazer?"
	printf ${END}
	printf ${BLUE}
	echo
	echo "Valores padrões:"
	echo "Local de instalação:" ${ODOO_INSTALL_DIR}
	printf ${END}
	echo
	echo "[1] Seguir com valores padrões"
	echo "[2] Baixar e editar o arquivo de ambiente (.env)"
	echo "[3] Vou decidir depois, cancelar processo"
	echo
	echo -n "Escolha uma opção: "
	read optionEnvFile
	case $optionEnvFile in
	1) defaultEnvFile ;;
	2) editEnvFile ;;
	3) printf ${RED}; echo "Processo cancelado"; printf ${END}; exit 1 ;;
	*) notEnvFile ;;
	esac
}

defaultEnvFile() {
	printf ${GREEN}
	center "Configurações padrões"
	printf ${END}
}

editEnvFile() {
	printf ${YELLOW}
	echo "[1] Baixar arquivo no diretório atual (${PWD})"
	echo "[2] Baixar em outro diretório"
	echo
	echo -n "Escolha uma opção: "
	read optionEditEnvFile
	case $optionEditEnvFile in
	1) wget -c https://raw.githubusercontent.com/renanteixeira/brodooinstall/dev_env/.env.example -O .env && vi .env;;
	2) echo "outro diretório" ;;
	esac
	printf ${END}
}

# Diretório de instalação do Odoo
chooseInstallDir() {
	printf "${GREEN}"
	echo "Local de instalação do Odoo e seus addons"
	printf "${END}"
	echo
	echo "[1] Usar caminho padrão - "$DEFAULT_DIR
	echo "[2] Digitar um caminho diferente"
	echo
	echo -n "Escolha uma opção: "
	read optionInstallDir
	case $optionInstallDir in
	1) cd ${DEFAULT_DIR} && exit 1 ;;
	2) echo "Digite o caminho completo do diretório de instalação, exemplo: /opt/odoo" && customInstallDir ;;
	esac
}

customInstallDir() {
	printf "${BLUE}"
	read odooInstallDir
	printf "${END}"
	if [ -z "${odooInstallDir}" ]; then
		printf "${YELLOW}"
		echo "Você precisa informar o diretório de instalação do Odoo e seus Addons!"
		printf "${END}"
		customInstallDir
	else
		if [ ! -d "${odooInstallDir}" ]; then
			printf "${GREEN}"
			{
				sudo mkdir -p $odooInstallDir
				cd $odooInstallDir
				# echo "O Odoo será instalado no diretório:" ${INSTALL_DIR}
			} || {
				printf "${RED}"
				echo "Falha ao criar diretório"
				printf "${END}"
			}
			printf "${END}"
		else
			printf "${RED}"
			echo "O diretório ${odooInstallDir} já"
			printf "${END}"
		fi
	fi
}

# Comando a ser executado quando rodar o script.
checkUserPermission
