#!/usr/bin/env bash

# File executable on UNIX (755): chmod +x tools.sh
# apt-get install dos2unix
# and run : dos2unix tools.sh
# start run : ./tools.sh

# Prompt
PS3='Selected : '

# List of available choices :
LISTE=( "Reset (with cache)"
        "Reset (without cache)"
        "Clean cache"
        "Clean cache (with the rm command and the -Rf argument)"
        "Update projet (Composer + Bower + BDD)"
        "Remove media files" )

# Choices available
select CHOIX in "${LISTE[@]}" ; do
    case $REPLY in
        1)
        echo ""
        echo "------------------------"
        echo "Start reset (with cache)"
        echo "------------------------"
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo -e "\033[42;30m ----------------------- \033[0m"
        echo -e "\033[42;30m [OK] Reset (with cache) \033[0m"
        echo -e "\033[42;30m ----------------------- \033[0m"
        break
        ;;

        2)
        echo ""
        echo "---------------------------"
        echo "Start reset (without cache)"
        echo "---------------------------"
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load
        echo -e "\033[42;30m -------------------------- \033[0m"
        echo -e "\033[42;30m [OK] Reset (without cache) \033[0m"
        echo -e "\033[42;30m -------------------------- \033[0m"
        break
        ;;

        3)
        echo ""
        echo "-----------------"
        echo "Start clean cache"
        echo "-----------------"
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo -e "\033[42;30m ---------------- \033[0m"
        echo -e "\033[42;30m [OK] Clean cache \033[0m"
        echo -e "\033[42;30m ---------------- \033[0m"
        break
        ;;

        4)
        echo ""
        echo "-----------------------------------------------------------"
        echo "Start clean cache (with the rm command and the -Rf argument)"
        echo "-----------------------------------------------------------"
        rm -Rf var/cache/*
        rm -Rf var/sessions/*
        rm -Rf var/logs/*

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo -e "\033[42;30m ----------------------------------------------------------- \033[0m"
        echo -e "\033[42;30m [OK] Clean cache (with the rm command and the -Rf argument) \033[0m"
        echo -e "\033[42;30m ----------------------------------------------------------- \033[0m"
        break
        ;;

        5)
        echo ""
        echo "--------------------------------------------"
        echo "Start update projet (Composer + Bower + BDD)"
        echo "--------------------------------------------"
        composer update
        bower update
        php bin/console doctrine:schema:update --force

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo -e "\033[42;30m ------------------------------------------- \033[0m"
        echo -e "\033[42;30m [OK] Update projet (Composer + Bower + BDD) \033[0m"
        echo -e "\033[42;30m ------------------------------------------- \033[0m"
        break
        ;;

        6)
        echo ""
        echo "------------------------"
        echo "Start remove media files"
        echo "------------------------"
        rm -Rf web/uploads/files/*
        rm -Rf web/uploads/users/avatars/*
        rm -Rf web/uploads/wysiwyg/source/*
        rm -Rf web/uploads/wysiwyg/thumbs
        echo -e "\033[42;30m ----------------------- \033[0m"
        echo -e "\033[42;30m [OK] Remove media files \033[0m"
        echo -e "\033[42;30m ----------------------- \033[0m"
        break
        ;;
    esac
done
