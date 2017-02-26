#!/usr/bin/env bash

# File executable on UNIX (755): chmod +x tools.sh
# apt-get install dos2unix
# and run : dos2unix tools.sh
# start run : ./tools.sh

# Prompt
PS3='Selected : '

# List of available choices :
LISTE=( "[1] Reset (with cache)"
        "[2] Reset (without cache)"
        "[3] Clean cache"
        "[4] Clean cache (with the -Rf argument)"
        "[5] Update projet (Composer + Bower + BDD)"
        "[6] Remove media files" )

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
        echo "-----------------------"
        echo "Reset (with cache) [OK]"
        echo "-----------------------"
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
        echo "--------------------------"
        echo "Reset (without cache) [OK]"
        echo "--------------------------"
        break
        ;;

        3)
        echo ""
        echo "-----------------"
        echo "Start clean cache"
        echo "-----------------"
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "----------------"
        echo "Clean cache [OK]"
        echo "----------------"
        break
        ;;

        4)
        echo ""
        echo "-----------------------------------------"
        echo "Start clean cache (with the -Rf argument)"
        echo "-----------------------------------------"
        rm -Rf var/cache/*
        rm -Rf var/sessions/*
        rm -Rf var/logs/*

        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "----------------------------------------"
        echo "Clean cache (with the -Rf argument) [OK]"
        echo "----------------------------------------"
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
        echo "-------------------------------------------"
        echo "Update projet (Composer + Bower + BDD) [OK]"
        echo "-------------------------------------------"
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
        echo "-----------------------"
        echo "Remove media files [OK]"
        echo "-----------------------"
        break
        ;;
    esac
done

echo ""
echo ""
echo "********************************"
echo "********************************"
echo "Close in less than 5 secondes..."
echo "********************************"
echo "********************************"
sleep 5
