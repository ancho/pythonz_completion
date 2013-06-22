_pythonz_complete()
{
    local commands

    COMPREPLY=()

    commands="cleanup help install list uninstall update"

    if [ $COMP_CWORD -eq 1 ]; then

        _pythonz_compreply $commands

    elif [ $COMP_CWORD -eq 2 ]; then

        case "${COMP_WORDS[COMP_CWORD-1]}" in

            help)
                commands=$( echo $commands | sed -e "s/help//g" )
                _pythonz_compreply $commands
                ;;

            install)
                _pythonz_available_versions
                _pythonz_compreply $available_versions
                ;;
            uninstall)
                _pythonz_installed_versions
                _pythonz_compreply $installed_versions
                ;;
            *)
                ;;
        esac

    elif [ $COMP_CWORD -eq 3 ]; then


        case "${COMP_WORDS[COMP_CWORD-1]}" in
            use|delete|rename|clone|print_activate)
                _pythonz_venv_current
                _pythonz_compreply $venv_current
                ;;

            *)
                ;;
        esac
    fi


    return 0
}

_pythonz_available_versions()
{
    _pythonz_installed_regex
    _pythonz_known_versions

    if [ -n "$installed_regex" ];then
        available_versions=$( echo $known_versions | sed -e "s/$installed_regex//g" )
    else 
        available_versions=$known_versions
    fi 

}

_pythonz_installed_versions()
{
    installed_versions=$( pythonbrew list |grep -v ^# | awk '{print $1}' )
}

_pythonz_installed_regex()
{
    _pythonz_installed_versions

    installed_regex=""
    if [ -n "$installed_versions" ];then
        installed_regex=$( echo $installed_versions |sed -e "s/\n\| /|/g" -e "s/|$//" -e "s/|/\\\|/g") 
    fi
}

_pythonz_known_versions()
{
    known_versions=$( pythonbrew list -k |grep -v ^# )
}

_pythonz_compreply()
{
    COMPREPLY=( $( compgen -W "$*" -- ${COMP_WORDS[COMP_CWORD]}) )
}

complete -F _pythonz_complete pythonz
