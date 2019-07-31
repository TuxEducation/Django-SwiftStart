#! /bin/bash
set -e

default_env_name=$(basename $PWD)

function create_env_file() {
    sample_env=".env.sample"
    env_file=".env"
    if [ -f "$env_file" ]; then
        echo -e "·· \033[33mFile \033[32m$env_file\033[33m already exist\033[0m ··"
        echo -e "\n·· Do you want to recopy \033[32m$sample_env\033[0m file data to \033[32m$env_file\033[0m file? [y/n] (Default is \033[31mn\033[0m): \c"
        read recopy_dot_env_file
        recopy_dot_env_file=${recopy_dot_env_file:-"n"}

        if [ "${recopy_dot_env_file}" != "y" -a "${recopy_dot_env_file}" != "Y" ]; then
            return 0
        fi
    fi
    if [ -f "$sample_env" ]; then
        cp $sample_env $env_file
        echo -e "\n·· copied \033[32m$sample_env\033[0m file data to \033[32m$env_file\033[0m file ··"
        echo -e "\n·· Do you want to modify \033[32m$env_file\033[0m file now? [y/n] (Default is \033[32my\033[0m): \c"
        read modify_dot_env_file
        modify_dot_env_file=${modify_dot_env_file:-"y"}

        if [ "${modify_dot_env_file}" == "y" -o "${modify_dot_env_file}" == "Y" ]; then
            vi $env_file
        fi
    else
        echo -e "·· \033[31mFailed to create \033[4m$env_file\033[0m\033[31m file, because \033[4m$sample_env\033[0m\033[31m file is not present\033[0m ··"
    fi
}

function check_homebrew() {
    if command -v brew &>/dev/null; then
        echo -e "\n·· \033[32mFound Homebrew in your system\033[0m ··\n\n"
    else
        echo -e "\n>>>> \033[31mPlease install \033[4mHomebrew\033[0m\033[31m and try again...\033[0m <<<<"
        homebrew_menu
    fi
}

function install_homebrew() {
    if [[ $(command -v brew) == "" ]]; then
        echo -e "\n·· \033[32mInstalling Homebrew in your system\033[0m ··\n\n"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi
}

function check_python3() {
    if command -v python3 &>/dev/null; then
        echo -e "\n·· \033[32mFound $(python3 --version) in your system\033[0m ··\n\n"
    else
        echo -e "\n>>>> \033[31mPlease install \033[4mPython 3\033[0m\033[31m and try again...\033[0m <<<<"
        python_menu
    fi
}

function install_python3() {
    check_homebrew
    brew install python3
    export PATH=/usr/local/bin:$PATH
    check_python3
}

function check_openssl() {
    if command -v openssl &>/dev/null; then
        echo -e "\n·· \033[32mFound $(openssl version) in your system\033[0m ··\n\n"
        echo -e "\n·· Exporting OpenSSL path ··\n\n"
        OPENSSL_FULL_PATH="$(which openssl)"
        OPENSSL_PATH="${OPENSSL_FULL_PATH%%bin*}"
        export PATH="${OPENSSL_PATH}bin:$PATH"
        export LDFLAGS="-L${OPENSSL_PATH}lib"
        export CPPFLAGS="-I${OPENSSL_PATH}include"
    else
        echo -e "\n>>>> \033[31mAbsence of \033[4mOpenSSL\033[0m\033[31m may cause some requirement installation issue...\033[0m <<<<\n"
        echo -e "\n>>>> \033[31mIn case of any error/issue please check Troubleshooting at \033[4mhttps://github.com/TuxEducation/django_rest_scaffolding#troubleshooting\033[0m <<<<\n"
    fi
}

function check_virtualenvwrapper() {
    echo -e "\n·· Checking for \033[32mvirtualenvwrapper.sh\033[0m file ··"
    export VIRTUALENVWRAPPER_PYTHON="$(which python3)"
    virtualenvwrapper_file='/usr/local/bin/virtualenvwrapper.sh'
    while :; do
        if [ -f "$virtualenvwrapper_file" -a "$(basename $virtualenvwrapper_file)" == "virtualenvwrapper.sh" ]; then
            echo -e "\n·· \033[32mSuccessfully located \033[4mvirtualenvwrapper.sh\033[0m \033[32mfile\033[0m ··"
            source $virtualenvwrapper_file
            return 0
        else
            echo -e "\n·· \033[31mFailed to locate \033[4mvirtualenvwrapper.sh\033[0m\033[31m file at path $virtualenvwrapper_file\033[0m ··"
            echo -e "\npress \033[31mCTRL+C\033[0m to terminate OR enter \033[32mvirtualenvwrapper.sh\033[0m file path: \c"
            read virtualenvwrapper_file
        fi
    done
}

function remove_virtual_env() {
    check_virtualenvwrapper
    rmvirtualenv $1
}

function create_virtual_env() {
    check_python3
    check_openssl
    echo '·······························································································'
    echo -e '·· \033[33mPlease make sure that \033[4mVirtual Environment Wrapper\033[0m\033[33m is install before continuing this step\033[0m ··'
    echo '·······························································································'
    echo -e "\nDo you want to continue? [y/n] (Default is \033[32my\033[0m): \c"
    read user_choice
    user_choice=${user_choice:-"y"}

    if [ "${user_choice}" != "y" -a "${user_choice}" != "Y" ]; then
        echo -e "\n\033[31mExiting...\033[0m"
        exit 0
    fi

    check_virtualenvwrapper

    echo -e "\nVirtual Environment Name (Default is \033[32m\033[1m$default_env_name\033[0m]): \c"
    read env_name
    env_name=${env_name:-$default_env_name}
    env_name="${env_name// /-}"
    default_env_name=$env_name

    echo -e "\nDo you want to install requirements? [y/n] (Default is \033[31mn\033[0m): \c"
    read install_requirements_approval
    install_requirements_approval=${install_requirements_approval:-"n"}

    echo -e '\n\n·· creating virtual environment >>>> \033[32m'$env_name'\033[0m ··'

    if [ "${install_requirements_approval}" == "y" -o "${install_requirements_approval}" == "Y" ]; then
        cmd='mkvirtualenv --python='$(which python3)' '$env_name' -r requirements.pip'
    else
        cmd='mkvirtualenv --python='$(which python3)' '$env_name
    fi
    echo -e "\n\033[32m$cmd\033[0m\n"
    $cmd || true # TODO: Find out why script is terminating at this point (Applied Hack to fix)
    deactivate
    echo -e "\n\033[32mSuccessfully created python virtual environment\033[0m\n"
}

function main() {
    create_env_file
    create_virtual_env
}

function install_requirements() {
    check_virtualenvwrapper
    echo -e "\nEnter Virtual Environment Name (Default is \033[32m\033[1m$default_env_name\033[0m]): \c"
    read env_name
    env_name=${env_name:-$default_env_name}
    env_name="${env_name// /-}"
    default_env_name=$env_name
    workon $env_name || true # TODO: Find out why script is terminating at this point (Applied Hack to fix)
    echo -e "Activated virtual enviroment : \033[32m$env_name\033[0m"
    pip install -r requirements.pip
    deactivate
}

function menu() {
    while :; do
        clear
        echo '········································'
        echo -e '··                \033[32mMENU\033[0m                ··'
        echo '········································'
        echo '··                                    ··'
        echo '·· 1. Run Steps [2,4,5]               ··'
        echo '·· 2. Create Virtual Env              ··'
        echo '·· 3. Remove Virtual Env              ··'
        echo '·· 4. Create .env file                ··'
        echo '·· 5. Install Requirements            ··'
        echo '·· 6. Install Python                  ··'
        echo '·· 7. Install/Update Homebrew         ··'
        echo '·· 8. Exit                            ··'
        echo '··                                    ··'
        echo '········································'
        echo -e 'Enter Your Choice : \c'
        read menu_option
        case $menu_option in
        1)
            echo "Initial Setup"
            main
            ;;
        2)
            echo "Create Virtual Env"
            create_virtual_env
            ;;
        3)
            echo "Remove Virtual Env"
            echo -e "\nVirtual Environment Name (Default is \033[32m\033[1m$default_env_name\033[0m]): \c"
            read env_name
            env_name=${env_name:-$default_env_name}
            env_name="${env_name// /-}"
            echo -e '\n\nRemoving Virtual Environment >>>> \033[32m'$env_name'\033[0m'
            echo -e '\nDo you want to continue? [y/n] (default is \033[32my\033[0m): \c'
            read approval
            approval=${approval:-"y"}

            if [ "${approval}" == "y" -o "${approval}" == "Y" ]; then
                remove_virtual_env $env_name
            fi
            ;;
        4)
            echo "Create .env file"
            create_env_file
            ;;
        5)
            echo "Install Requirements"
            install_requirements
            ;;
        6)
            echo "Install Python"
            install_python3
            ;;
        7)
            echo "Install Homebrew"
            install_homebrew
            ;;
        8)
            echo "Exit"
            exit 0
            ;;
        *)
            echo -e "\n\033[31mSorry, I don't understand\033[0m\n"
            ;;
        esac
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

function homebrew_menu() {
    while :; do
        echo '········································'
        echo -e '··              \033[32mHOMEBREW\033[0m              ··'
        echo '········································'
        echo '··                                    ··'
        echo '·· 1. Install Homebrew                ··'
        echo '·· 2. Main Menu                       ··'
        echo '·· 3. Exit                            ··'
        echo '··                                    ··'
        echo '········································'
        echo -e 'Enter Your Choice : \c'
        read menu_option
        case $menu_option in
        1)
            echo "Install Homebrew"
            install_homebrew
            ;;
        2)
            menu
            ;;
        3)
            echo "Exit"
            exit 0
            ;;
        *)
            echo -e "\n\033[31mSorry, I don't understand\033[0m\n"
            ;;
        esac
        read -n 1 -s -r -p "Press any key to continue..."
        clear
    done
}

function python_menu() {
    while :; do
        echo '········································'
        echo -e '··               \033[32mPYTHNN\033[0m               ··'
        echo '········································'
        echo '··                                    ··'
        echo '·· 1. Install Python                  ··'
        echo '·· 2. Main Menu                       ··'
        echo '·· 3. Exit                            ··'
        echo '··                                    ··'
        echo '········································'
        echo -e 'Enter Your Choice : \c'
        read menu_option
        case $menu_option in
        1)
            echo "Install Python"
            install_python3
            ;;
        2)
            menu
            ;;
        3)
            echo "Exit"
            exit 0
            ;;
        *)
            echo -e "\n\033[31mSorry, I don't understand\033[0m\n"
            ;;
        esac
        read -n 1 -s -r -p "Press any key to continue..."
        clear
    done
}

menu
