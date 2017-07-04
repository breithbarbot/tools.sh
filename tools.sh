#!/usr/bin/env bash

# Copyright (c) 2017 Breith Barbot <b.breith@gmail.com>.
# For Symfony version >= 3.3.3

# Change the rights for scripts to be executable (755): chmod +x tools.sh
# Execute : ./tools.sh

# For convert...
# apt-get install dos2unix
# and run : dos2unix tools.sh

# Windows user, start in *admin* : php bin/console assets:install --symlink


# Prompt
PS3='Selected : '

# List of available choices :
LISTE=( 'Reset (with cache)'
        'Reset (without cache)'
        'Clean cache'
        'Clean cache (with the rm command and the -Rf argument)'
        'Update projet (Composer + yarn + BDD)'
        'Remove media files'
        'Start empty project' )

# Choices available
select CHOIX in "${LISTE[@]}" ; do
    case $REPLY in
        1)
        echo ''
        echo '------------------------'
        echo 'Start reset (with cache)'
        echo '------------------------'
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        php bin/console cache:clear --no-warmup
        php bin/console cache:clear --no-warmup -e prod
        echo -e '\033[42;30m ----------------------- \033[0m'
        echo -e '\033[42;30m [OK] Reset (with cache) \033[0m'
        echo -e '\033[42;30m ----------------------- \033[0m'
        break
        ;;

        2)
        echo ''
        echo '---------------------------'
        echo 'Start reset (without cache)'
        echo '---------------------------'
        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load
        echo -e '\033[42;30m -------------------------- \033[0m'
        echo -e '\033[42;30m [OK] Reset (without cache) \033[0m'
        echo -e '\033[42;30m -------------------------- \033[0m'
        break
        ;;

        3)
        echo ''
        echo '-----------------'
        echo 'Start clean cache'
        echo '-----------------'
        php bin/console cache:clear --no-warmup
        php bin/console cache:clear --no-warmup -e prod
        echo -e '\033[42;30m ---------------- \033[0m'
        echo -e '\033[42;30m [OK] Clean cache \033[0m'
        echo -e '\033[42;30m ---------------- \033[0m'
        break
        ;;

        4)
        echo ''
        echo '-----------------------------------------------------------'
        echo 'Start clean cache (with the rm command and the -Rf argument)'
        echo '-----------------------------------------------------------'
        rm -Rf var/cache/*
        rm -Rf var/sessions/*
        rm -Rf var/logs/*

        php bin/console cache:clear --no-warmup
        php bin/console cache:clear --no-warmup -e prod
        echo -e '\033[42;30m ----------------------------------------------------------- \033[0m'
        echo -e '\033[42;30m [OK] Clean cache (with the rm command and the -Rf argument) \033[0m'
        echo -e '\033[42;30m ----------------------------------------------------------- \033[0m'
        break
        ;;

        5)
        echo ''
        echo '--------------------------------------------'
        echo 'Start update projet (Composer + yarn + BDD)'
        echo '--------------------------------------------'
        rm -Rf web/bundles/*

        composer update
        yarn upgrade --modules-folder ./web/assets/node_modules

        php bin/console doctrine:schema:update --force

        php bin/console cache:clear --no-warmup
        php bin/console cache:clear --no-warmup -e prod
        echo -e '\033[42;30m ------------------------------------------- \033[0m'
        echo -e '\033[42;30m [OK] Update projet (Composer + yarn + BDD) \033[0m'
        echo -e '\033[42;30m ------------------------------------------- \033[0m'
        break
        ;;

        6)
        echo ''
        echo '------------------------'
        echo 'Start remove media files'
        echo '------------------------'
        rm -Rf web/uploads/files/*
        rm -Rf web/uploads/users/avatars/*
        rm -Rf web/uploads/wysiwyg/source/*
        rm -Rf web/uploads/wysiwyg/thumbs
        echo -e '\033[42;30m ----------------------- \033[0m'
        echo -e '\033[42;30m [OK] Remove media files \033[0m'
        echo -e '\033[42;30m ----------------------- \033[0m'
        break
        ;;

        7)
        echo ''
        echo '-------------------'
        echo 'Start empty project'
        echo '-------------------'
        yarn install --modules-folder ./web/assets/node_modules

        composer update
        php bin/console cache:clear --no-warmup

        HTTPDUSER=`ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1`
        setfacl -R -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX var
        setfacl -dR -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX var

        chmod -R 757 web/uploads/
        chmod 777 web/uploads/
        chown -R "$HTTPDUSER":"$HTTPDUSER" web/uploads/

        php bin/console doctrine:database:drop --force
        php bin/console doctrine:database:create
        php bin/console doctrine:schema:update --force
        php bin/console doctrine:fixtures:load

        php bin/console cache:clear --no-warmup
        php bin/console cache:clear --no-warmup -e prod

        cp ./.sources/config.ini.dist ./.sources/config.ini
        echo -e '\033[42;30m ------------------------ \033[0m'
        echo -e '\033[42;30m [OK] Start empty project \033[0m'
        echo -e '\033[42;30m ------------------------ \033[0m'
        echo ''
        echo 'Edit config file (Optional) : .sources/config.ini'
        echo ''
        break
        ;;
    esac
done
