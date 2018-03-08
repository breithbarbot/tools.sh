#!/usr/bin/env bash

##########################################################
# Copyright (c) 2018 Breith Barbot <b.breith@gmail.com>. #
# Source : https://gitlab.com/breithbarbot/tools.sh      #
# Tools.sh for Symfony Flex                              #
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
echo -e '\r'


# tools.sh should not be run as root to prevent Symfony's cache fails with wrong permissions on /var folders
if [[ "$OSTYPE" == linux* ]]; then
    USER="`whoami`"
    if [[ "$USER" == 'root' ]]; then
        echo -e '\033[1;31m------------------------------------\033[0m'
        echo -e '\033[1;31mWarning ! You run the script as root\033[0m'
        echo -e '\033[1;31m------------------------------------\033[0m'
    fi
fi


# #########
# Functions
# #########

# Request if you want edit .env file
editEnv() {
    cp ./.env.dist ./.env
    if [ -x "$(command -v editor)" ] || [ -x "$(command -v nano)" ]; then

        echo -n 'Edit .env? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then
            # cp ./.env.dist ./.env
            if [ -x "$(command -v editor)" ]; then
                editor ./.env
            else
                nano ./.env
            fi
        fi

    else

        echo 'Edit your .env file if necessary'

    fi
}

# Install and update packages from composer
installComposer() {
    rm -fr ./vendor/*

    if [ false ] && [ "$1" = 'prod' ]; then

        composer install --no-dev --optimize-autoloader
        composer update --no-dev --optimize-autoloader

    else

        composer install
        composer update

    fi

    php bin/console assets:install --symlink
}

# Update packages from composer
updateComposer() {
    if [ false ] && [ "$1" = 'prod' ]; then

        composer install --no-dev --optimize-autoloader
        composer update --no-dev --optimize-autoloader

    else

        composer install
        composer update

    fi

    php bin/console assets:install --symlink
}

# Set permission on upload folder
permissionUploadFolder() {
    UPLOAD_FOLDER='public/uploads/'
    if [ -d "$UPLOAD_FOLDER" ]; then
        chmod -R 775 "$UPLOAD_FOLDER"
        chmod 777 "$UPLOAD_FOLDER"
        chown -R root:www-data "$UPLOAD_FOLDER"
    fi
}

# Clean cache and set permission on cache folder
cleanCacheFolder() {
    if [ false ] && [ "$1" = 'prod' ]; then

        php bin/console cache:clear --env=prod --no-debug

    else

        php bin/console cache:clear

    fi

    CACHE_PROD_FOLDER='var/cache/'
    if [ -d "$CACHE_PROD_FOLDER" ]; then
        chmod 775 "$CACHE_PROD_FOLDER"
    fi
    CACHE_PROD_FOLDER2='var/log/'
    if [ -d "$CACHE_PROD_FOLDER2" ]; then
        chmod 775 "$CACHE_PROD_FOLDER2"
    fi
    php bin/console cache:warmup
}


# ########
# Selector
# ########

# Prompt
PS3='Selected : '

# List of available commands :
LIST=('Install project'
      'Update project (Composer + yarn + DB)'
      'Reset project'
      'Clean cache'
      'Update tools.sh')

# Commands available
select CHOICE in "${LIST[@]}" ; do
    case $REPLY in
        1)
        echo ''
        echo '---------------'
        echo 'Install project'
        echo '---------------'

        echo -n 'In a production environment? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then

            echo '\r'
            echo -e '\033[0;34mSee :\033[0m https://symfony.com/doc/current/deployment.html'
            echo '\r'

            # Request if you want edit .env file
            editEnv

            # Install and update packages from composer
            installComposer 'prod'

            yarn install --production

            # Set permission on upload folder
            permissionUploadFolder

            # Clean cache and set permission on cache folder
            cleanCacheFolder 'prod'

            php bin/console doctrine:database:create
            php bin/console doctrine:schema:update --force

            echo -e '\033[42;30m ----------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Install project in production environement \033[0m'
            echo -e '\033[42;30m ----------------------------------------------- \033[0m'

        else

            # Request if you want edit .env file
            editEnv

            # Install and update packages from composer
            installComposer

            yarn install

            # Set permission on upload folder
            permissionUploadFolder

            # Clean cache and set permission on cache folder
            cleanCacheFolder

            php bin/console doctrine:database:drop --force
            php bin/console doctrine:database:create
            php bin/console doctrine:schema:update --force
            php bin/console doctrine:fixtures:load

            cp ./.sources/config.ini.dist ./.sources/config.ini

            echo -e '\033[42;30m ------------------------------------------------ \033[0m'
            echo -e '\033[42;30m [OK] Install project in development environement \033[0m'
            echo -e '\033[42;30m ------------------------------------------------ \033[0m'

        fi
        break
        ;;

        2)
        echo ''
        echo '-------------------------------------'
        echo 'Update project (Composer + yarn + DB)'
        echo '-------------------------------------'

        echo -n 'In a production environment? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then

            # Update packages from composer
            updateComposer 'prod'

            yarn upgrade --production

            php bin/console doctrine:schema:update --force

            echo -e '\033[42;30m ---------------------------------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Update project (Composer + yarn + DB) in development environement \033[0m'
            echo -e '\033[42;30m ---------------------------------------------------------------------- \033[0m'

        else

            # Update packages from composer
            updateComposer

            yarn upgrade

            php bin/console doctrine:schema:update --force

            echo -e '\033[42;30m ---------------------------------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Update project (Composer + yarn + DB) in development environement \033[0m'
            echo -e '\033[42;30m ---------------------------------------------------------------------- \033[0m'

        fi
        break
        ;;

        3)
        echo ''
        echo '-------------'
        echo 'Reset project'
        echo '-------------'

        echo -en '\033[31mYour database will be emptied! \033[34mAre you sure? \033[0m(y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then
            php bin/console doctrine:database:drop --force
            php bin/console doctrine:database:create
            php bin/console doctrine:schema:update --force
            php bin/console doctrine:fixtures:load

            echo -n 'Clean cache? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then

                echo -n 'In a production environment? (y/N)'
                read answer
                if echo "$answer" | grep -iq '^y' ;then

                    # Clean cache and set permission on cache folder
                    cleanCacheFolder 'prod'

                else

                    # Clean cache and set permission on cache folder
                    cleanCacheFolder

                fi

            fi

            echo -e '\033[42;30m ------------------ \033[0m'
            echo -e '\033[42;30m [OK] Reset project \033[0m'
            echo -e '\033[42;30m ------------------ \033[0m'

        else

            echo -e '\033[41;30m -------------------------- \033[0m'
            echo -e '\033[41;30m [KO] Reset project aborted \033[0m'
            echo -e '\033[41;30m -------------------------- \033[0m'

        fi
        break
        ;;

        4)
        echo ''
        echo '-----------'
        echo 'Clean cache'
        echo '-----------'

        echo -n 'In a production environment? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then

            echo -n 'Clean the var folder? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                rm -fr var/*
            fi

            # Clean cache and set permission on cache folder
            cleanCacheFolder 'prod'

            echo -e '\033[42;30m ------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Clean cache in production environement \033[0m'
            echo -e '\033[42;30m ------------------------------------------- \033[0m'

        else

            echo -n 'Clean the var folder? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                rm -fr var/*
            fi

            # Clean cache and set permission on cache folder
            cleanCacheFolder

            echo -e '\033[42;30m ------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Clean cache in production environement \033[0m'
            echo -e '\033[42;30m ------------------------------------------- \033[0m'

        fi
        break
        ;;

        5)
        echo ''
        echo '---------------'
        echo 'Update tools.sh'
        echo '---------------'

		curl https://gitlab.com/breithbarbot/tools.sh/raw/master/tools.sh > tools.sh

        echo -e '\033[42;30m -------------------- \033[0m'
        echo -e '\033[42;30m [OK] Update tools.sh \033[0m'
        echo -e '\033[42;30m -------------------- \033[0m'
		exit
        break
        ;;
    esac
done

#############################################################
# Base for colouring                                        #
# https://misc.flogisoft.com/bash/tip_colors_and_formatting #
#############################################################
