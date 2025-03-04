#!/usr/bin/env bash

ROOTPROJECTPATH="$(
    cd -- "$(dirname "$0")/.." >/dev/null 2>&1
    pwd -P
)"

echo $ROOTPROJECTPATH

function install {
    path=$1
    if [ -z "$1" ]; then
        path="/lib/systemd/system"
    fi

    if [ -e "$path/threeal-bot.service" ]; then
        echo "Service is already installed"
        exit
    fi

    workdir=$ROOTPROJECTPATH

    execstart="go run $workdir/cmd/backend/main.go"

    echo "Installing service..."

    sed -e "s@<user>@$USER@" -e "s@<group>@$USER@" -e "s@<workdir>@$workdir@" -e "s@<pathexists>@$workdir@" -e "s@<execstart>@$execstart@" service/threeal-bot.service >threeal-bot.service

    mv threeal-bot.service $path

    echo "Done installing service"
}

function uninstall {
    path=$1
    if [ -z "$1" ]; then
        path="/lib/systemd/system/threeal-bot.service"
    fi

    if [ -e "$path" ]; then
        echo "Uninstalling service..."
        rm $path
        echo "Done uninstalling service"
        exit
    fi

    echo "Service is not installed"
}

function help {
    cat <<EOF
This is a script for managing threeal bot service

Usage: 

        ./svc.sh <command> [arguments]

The commands are:

        install     install threeal bot service
        uninstall   uninstall threeal bot service

Use "./svc.sh help <command>" for more information about a command.
EOF
}

function help_install {
    cat <<EOF
Usage: ./svc.sh install [config path]

This command installs the bot's configuration to system.

If config path is given, the configuration files is copied to that path.

If no config path given, the configuration file will be copied to /lib/systemd/system
EOF
}

function help_uninstall {
    cat <<EOF
Usage: ./svc.sh uninstall [config path]

This command removes the bot's configuration from system.

If config path is given, the configuration files is removed from the given path.

If no config path given, the configuration file will be removed from /lib/systemd/system
EOF
}

case "$1" in
install) install $2 ;;
uninstall) uninstall $2 ;;
help) case $2 in
    install) help_install ;;
    uninstall) help_uninstall ;;
    *) help ;;
    esac ;;
*) help ;;
esac
