#!/usr/bin/env bash

##########################################################
# Copyright (c) 2018 Breith Barbot <b.breith@gmail.com>. #
# Source : https://gitlab.com/breithbarbot/tools.sh      #
# For Symfony Flex                                       #
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


# Basic information
echo -e '\033[0;36m*****************************************\033[0m'
echo -e '\033[0;36m*****************************************\033[0m'
echo -e '\033[0;36m**                                     **\033[0m'
echo -e '\033[0;36m**\033[0m      \033[1;37mTools.sh for Symfony Flex\033[0m      \033[0;36m**\033[0m'
echo -e '\033[0;36m**                                     **\033[0m'
echo -e '\033[0;36m*****************************************\033[0m'
echo -e '\033[0;36m*****************************************\033[0m'
echo -e '\n'


# tools.sh should not be run as root to prevent Symfony's cache fails with wrong permissions on /var folders
if [[ "$OSTYPE" == linux* ]]; then
    USER="`whoami`"
    if [[ "$USER" == 'root' ]]; then
        echo -e '\033[1;31m------------------------------------\033[0m'
        echo -e '\033[1;31mWarning ! You run the script as root\033[0m'
        echo -e '\033[1;31m------------------------------------\033[0m'
    fi
fi


# Prompt
PS3='Selected : '

# List of available commands :
LIST=('Install project'
      'Clean cache'
      'Update project (Composer + yarn + DB)'
      'Reset project'
      'Install project in production environement')

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

        rm -fr ./vendor/*
        composer install
        composer update
        php bin/console assets:install --symlink

        yarn install
        yarn build

        UPLOAD_FOLDER='public/uploads/'
        if [ -d "$UPLOAD_FOLDER" ]; then
            chmod -R 775 "$UPLOAD_FOLDER"
            chmod 777 "$UPLOAD_FOLDER"
            chown -R root:www-data "$UPLOAD_FOLDER"
        fi

        php bin/console doctrine:database:drop --force

        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug

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
            rm -fr var/*
        fi

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
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
        rm -fr public/bundles/*

        composer update
        php bin/console assets:install --symlink

        yarn upgrade
        yarn build

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
            php bin/console cache:clear --env=prod --no-debug
        fi
        echo -e '\033[42;30m ------------------ \033[0m'
        echo -e '\033[42;30m [OK] Reset project \033[0m'
        echo -e '\033[42;30m ------------------ \033[0m'
        break
        ;;

        5)
        echo ''
        echo '------------------------------------------'
        echo 'Install project in production environement'
        echo '------------------------------------------'
        echo '\n'
        echo -e '\033[0;34mSee :\033[0m https://symfony.com/doc/current/deployment.html'
        echo '\n'

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

        rm -fr ./vendor/*
        composer install --no-dev --optimize-autoloader
        composer update --no-dev --optimize-autoloader
        php bin/console assets:install --symlink

        yarn install
        yarn build

        UPLOAD_FOLDER='public/uploads/'
        if [ -d "$UPLOAD_FOLDER" ]; then
            chmod -R 775 "$UPLOAD_FOLDER"
            chmod 777 "$UPLOAD_FOLDER"
            chown -R root:www-data "$UPLOAD_FOLDER"
        fi

        php bin/console cache:clear --env=prod --no-debug

        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force

        php bin/console assetic:dump --env=prod --no-debug
        echo -e '\033[42;30m ----------------------------------------------- \033[0m'
        echo -e '\033[42;30m [OK] Install project in production environement \033[0m'
        echo -e '\033[42;30m ----------------------------------------------- \033[0m'
        break
        ;;
    esac
done
