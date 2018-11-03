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

    else

        composer install

    fi

    php bin/console assets:install --symlink
}

# Set permission on upload folder [unused]
permissionUploadFolder() {
    UPLOAD_FOLDER='public/uploads/'
    if [ -d "$UPLOAD_FOLDER" ]; then
        sudo chmod -R 775 "$UPLOAD_FOLDER"
        sudo chmod 777 "$UPLOAD_FOLDER"
        sudo chown -R root:www-data "$UPLOAD_FOLDER"
    fi
}

# Clean cache and set permission on cache folder
cleanCacheFolder() {
    if [ false ] && [ "$1" = 'prod' ]; then

        php bin/console cache:clear --env=prod --no-debug
        CACHE_PROD_FOLDER='var/'
        if [ -d "$CACHE_PROD_FOLDER" ]; then
            sudo chmod 775 -R "$CACHE_PROD_FOLDER"
        fi
        php bin/console cache:warmup --env=prod --no-debug

    else

        php bin/console cache:clear --env=dev
        CACHE_PROD_FOLDER='var/'
        if [ -d "$CACHE_PROD_FOLDER" ]; then
            sudo chmod 775 -R "$CACHE_PROD_FOLDER"
        fi
        php bin/console cache:warmup --env=dev

    fi
}


# ########
# Selector
# ########

# Prompt
PS3='Selected : '

# List of available commands :
LIST=('Install project'
      'Update project (Composer + yarn -> from .lock) + DB'
      'Reset project (only for dev)'
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

            # Configure your Environment Variables
            echo '\r'
            echo -e '\033[0;34m/!\ \033[0m Rememmber to configure your Environment Variables \033[0;34m/!\'
            echo '\r'

            # Install and update packages from composer
            installComposer 'prod'

            # Clean cache and set permission on cache folder
            cleanCacheFolder 'prod'

            echo -n 'Creation of a database (deletion if already existing)? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                php bin/console doctrine:database:drop --if-exists --force
                php bin/console doctrine:database:create --if-not-exists
            fi
            php bin/console doctrine:migrations:migrate

            yarn install
            yarn build
            yarn install --production

            echo -e '\033[42;30m ----------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Install project in production environement \033[0m'
            echo -e '\033[42;30m ----------------------------------------------- \033[0m'

        else

            # Request if you want edit .env file
            editEnv

            # Install and update packages from composer
            installComposer

            # Clean cache and set permission on cache folder
            cleanCacheFolder

            echo -n 'Creation of a database (deletion if already existing)? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                php bin/console doctrine:database:drop --if-exists --force
                php bin/console doctrine:database:create --if-not-exists
            fi
            php bin/console doctrine:migrations:migrate
            echo -n 'Run the fixtures? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                php bin/console doctrine:fixtures:load
            fi

            yarn install
            yarn dev

            echo -e '\033[42;30m ------------------------------------------------ \033[0m'
            echo -e '\033[42;30m [OK] Install project in development environement \033[0m'
            echo -e '\033[42;30m ------------------------------------------------ \033[0m'

        fi
        break
        ;;

        2)
        echo ''
        echo '---------------------------------------------------'
        echo 'Update project (Composer + yarn -> from .lock) + DB'
        echo '---------------------------------------------------'

        echo -n 'In a production environment? (y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then

            # Update packages from composer.lock
            installComposer 'prod'

            php bin/console doctrine:migrations:migrate

            # Update packages from yarn.lock
            yarn install
            yarn build
            yarn install --production

            echo -e '\033[42;30m ----------------------------------------------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Update project (Composer + yarn -> from .lock) + DB in production environement \033[0m'
            echo -e '\033[42;30m ----------------------------------------------------------------------------------- \033[0m'

        else

            # Update packages from composer.lock
            installComposer

            php bin/console doctrine:migrations:migrate

            # Update packages from yarn.lock
            yarn install
            yarn dev

            echo -e '\033[42;30m ------------------------------------------------------------------------------------ \033[0m'
            echo -e '\033[42;30m [OK] Update project (Composer + yarn -> from .lock) + DB in development environement \033[0m'
            echo -e '\033[42;30m ------------------------------------------------------------------------------------ \033[0m'

        fi
        break
        ;;

        3)
        echo ''
        echo '----------------------------'
        echo 'Reset project (only for dev)'
        echo '----------------------------'

        echo -en '\033[31mYour database will be emptied! \033[34mAre you sure? \033[0m(y/N)'
        read answer
        if echo "$answer" | grep -iq '^y' ;then
            php bin/console doctrine:database:drop --if-exists --force
            php bin/console doctrine:database:create --if-not-exists
            php bin/console doctrine:migrations:migrate
            php bin/console doctrine:fixtures:load

            echo -n 'Clean cache? (y/N)'
            read answer
            if echo "$answer" | grep -iq '^y' ;then
                # Clean cache and set permission on cache folder
                cleanCacheFolder
            fi

            echo -e '\033[42;30m --------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Reset project (only for dev) \033[0m'
            echo -e '\033[42;30m --------------------------------- \033[0m'

        else

            echo -e '\033[41;30m ----------------------------------------- \033[0m'
            echo -e '\033[41;30m [KO] Reset project (only for dev) aborted \033[0m'
            echo -e '\033[41;30m ----------------------------------------- \033[0m'

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

            echo -e '\033[42;30m -------------------------------------------- \033[0m'
            echo -e '\033[42;30m [OK] Clean cache in development environement \033[0m'
            echo -e '\033[42;30m -------------------------------------------- \033[0m'

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
