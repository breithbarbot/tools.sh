#!/usr/bin/env bash

##########################################################
# Copyright (c) 2018 Breith Barbot <b.breith@gmail.com>. #
# Source : https://gitlab.com/breithbarbot/tools.sh      #
# For : Symfony 3.4 and later                            #
##########################################################


##########################################################
#                        README                          #
##########################################################
#
# Step 1 - File executable on UNIX (755) :
#=========================================
#
# `chmod +x tools.sh`
#
#
# Step 2 (Optional) - Convert file dos to unix :
#===============================================
#
# > If you have a message "No file or folder of this type"
#
# Install : `apt-get install dos2unix`
# Run : `dos2unix tools.sh`
#
#
# Step 3 - Execute :
#===================
# `./tools.sh`
#
##########################################################


# tools.sh should not be run as root to prevent Symfony's cache fails with wrong permissions on /var folders
if [[ "$OSTYPE" == linux* ]]; then
    USER="`whoami`"
    if [[ "$USER" == 'root' ]]; then
        echo -e '\033[1;31m------------------------------------\x1b[m'
        echo -e '\033[1;31mWarning ! You run the script as root\x1b[m'
        echo -e '\033[1;31m------------------------------------\x1b[m'
    fi
fi


# Prompt
PS3='Selected : '

# List of available commands :
LIST=('Install project'
      'Clean cache'
      'Update project (Composer + yarn + DB)'
      'Reset project')

# Commands available
select CHOICE in "${LIST[@]}" ; do
    case $REPLY in
        1)
        echo ''
        echo '---------------'
        echo 'Install project'
        echo '---------------'
        cp ./.env.dist ./.env

        if [ -x "$(command -v editor)" ] || [ -x "$(command -v nano)" ]; then
            echo -n 'Edit .env? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                if [ -x "$(command -v editor)" ]; then
                    editor ./.env
                else
                    nano ./.env
                fi
            fi
        else
            echo 'Edit your .env file if necessary'
        fi

        composer install
        php bin/console assets:install --symlink

        yarn install
        yarn run encore production

        chmod -R 775 public/uploads/
        chmod 777 public/uploads/
        chown -R root:www-data public/uploads/

        php bin/console doctrine:database:drop --force

        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        php bin/console cache:clear

        cp ./.sources/config.ini.dist ./.sources/config.ini
        echo -e '\033[42;30m -------------------- \033[0m'
        echo -e '\033[42;30m [OK] Install project \033[0m'
        echo -e '\033[42;30m -------------------- \033[0m'
        break
        ;;

        2)
        echo ''
        echo '-----------'
        echo 'Clean cache'
        echo '-----------'
        echo -n 'Clean the var folder? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then
            rm -Rf var/*
        fi

        php bin/console cache:clear
        echo -e '\033[42;30m ---------------- \033[0m'
        echo -e '\033[42;30m [OK] Clean cache \033[0m'
        echo -e '\033[42;30m ---------------- \033[0m'
        break
        ;;

        3)
        echo ''
        echo '-------------------------------------'
        echo 'Update project (Composer + yarn + DB)'
        echo '-------------------------------------'
        rm -Rf public/bundles/*

        composer update
        php bin/console assets:install --symlink

        yarn upgrade

        php bin/console doctrine:schema:update --force
        echo -e '\033[42;30m ------------------------------------------ \033[0m'
        echo -e '\033[42;30m [OK] Update project (Composer + yarn + DB) \033[0m'
        echo -e '\033[42;30m ------------------------------------------ \033[0m'
        break
        ;;

        4)
        echo ''
        echo '-------------'
        echo 'Reset project'
        echo '-------------'
        php bin/console doctrine:database:drop --force

        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        echo -n 'Clean cache? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then
            php bin/console cache:clear
        fi
        echo -e '\033[42;30m ------------------ \033[0m'
        echo -e '\033[42;30m [OK] Reset project \033[0m'
        echo -e '\033[42;30m ------------------ \033[0m'
        break
        ;;
    esac
done
