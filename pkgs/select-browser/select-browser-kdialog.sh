#!/bin/sh

APP=`which select-browser`
if [ "${APP}" = "" ]; then
    echo "Select-browser is not installed or not in your \$PATH"
    read -r -p " Do you want to install select-browser [Y/n] " RESPONSE
    case "${RESPONSE}" in
        [yY][eE][sS]|[yY]|"" )
            echo "Installing..."
            SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
            echo "${SCRIPTPATH}"
            sudo cp "${SCRIPTPATH}"/select-browser-kdialog.sh /usr/local/bin/select-browser
        ;;
        [nN][oO]|[nN])
            echo "ok :'("
        ;;
        *)
            echo "Invalid input..."
            exit 1
        ;;
    esac
    exit
fi

BROWSER=$(kdialog --title "Select your browser" --radiolist "Choose a browser" \
    1 "Chrome - Main" off \
    2 "Firefox - Trustsoft" off \
    3 "Chrome - Trustsoft" off \
    4 "Chrome - OpenVPN" off )


case "${BROWSER}" in
    "1")
        exec google-chrome-stable --profile-directory="Default" "$@"
    ;;
    "2")
        exec firefox "$@"
    ;;
    "3")
        exec google-chrome-stable --profile-directory="Profile 1" "$@"
    ;;
    "4")
        exec google-chrome-stable --profile-directory="Profile 2" "$@"
    ;;
    *)
        exit 1
    ;;
esac
