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
    2 "Chrome - OpenVPN" off \
    3 "Chrome - Kupoprodaja" off \
    4 "Firefox - Main" off \
    5 "Firefox - OpenVPN" off \
    6 "Chrome - Trustsoft" off \
    7 "Firefox - Trustsoft" off
)


case "${BROWSER}" in
    "1")
        exec google-chrome-stable --profile-directory="Default" "$@"
    ;;
    "2")
        exec google-chrome-stable --profile-directory="Profile 2" "$@"
    ;;
    "3")
        exec google-chrome-stable --profile-directory="Profile 3" "$@"
    ;;
    "4")
        exec firefox -P Main "$@"
    ;;
    "5")
        exec firefox -P OpenVPN "$@"
    ;;
    "6")
        exec google-chrome-stable --profile-directory="Profile 1" "$@"
    ;;
    "7")
        exec firefox -P Trustsoft "$@"
    ;;
    *)
        exit 1
    ;;
esac
