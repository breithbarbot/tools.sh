#!/usr/bin/env bash

# File executable on UNIX (755): chmod +x tools.sh
# apt-get install dos2unix
# and run : dos2unix tools.sh
# start run : ./tools.sh

PS3='Selected : ' # le prompt

# liste de choix disponibles
LISTE=( "[1] Reset (sans vider le cache)"
        "[2] Reset"
        "[3] Vider le cache"
        "[4] Vider le cache (Avec du 'Rm')"
        "[5] Mise à jour du projet" )

select CHOIX in "${LISTE[@]}" ; do
    case $REPLY in
        1)
        echo ""
        echo "Start reset"
        echo "-----------"
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load
        rm -Rf web/uploads/wysiwyg/source/*
        rm -Rf web/uploads/wysiwyg/thumbs
        rm -Rf web/uploads/users/avatars/*
        echo "Reset (sans vider le cache) OK"
        break
        ;;

        2)
        echo ""
        echo "Start reset"
        echo "-----------"
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load
        rm -Rf web/uploads/wysiwyg/source/*
        rm -Rf web/uploads/wysiwyg/thumbs
        rm -Rf web/uploads/users/avatars/*
        echo ""
        echo "Start cache:clear (dev & prod)"
        echo "------------------------------"
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "Reset OK"
        break
        ;;

        3)
        echo ""
        echo "Start cache:clear (dev & prod)"
        echo "------------------------------"
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "Vider le cache OK"
        break
        ;;

        4)
        echo ""
        echo "Start cache:clear (dev & prod) + 'Rm'"
        echo "-------------------------------------"
        rm -Rf var/cache/*
        rm -Rf var/sessions/*
        rm -Rf var/logs/*
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "Vider le cache (Avec du 'Rm') OK"
        break
        ;;

        5)
        echo ""
        echo "Start update projet"
        echo "-------------------------------------"
        php composer update
        php bin/console doctrine:schema:update --force
        echo ""
        echo "Start cache:clear (dev & prod) + 'Rm'"
        echo "-------------------------------------"
        rm -Rf var/cache/*
        rm -Rf var/sessions/*
        rm -Rf var/logs/*
        php bin/console cache:clear
        php bin/console cache:clear --env=prod --no-debug
        echo "Vider le cache (Avec du 'Rm') OK"
        break
        ;;
    esac
done

echo Close in 5 secondes...
sleep 5