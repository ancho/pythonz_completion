_pythonz_complete()
{
    local commands

    COMPREPLY=()
    
    type="cpython"

    types="cpython stackless pypy jython"
    commands="cleanup help install list uninstall update"

    if [ $COMP_CWORD -eq 1 ]; then #pythonz

        _pythonz_compreply $commands

    elif [ $COMP_CWORD -eq 2 ]; then #pythonz commands and options

        case "${COMP_WORDS[COMP_CWORD-1]}" in

            help)
                commands=$( echo $commands | sed -e "s/help//g" )
                _pythonz_compreply $commands
                ;;

            install)
                options="-t"
                _pythonz_available_versions
                _pythonz_compreply $options $available_versions
                ;;
            uninstall)
                options="-t"
                _pythonz_installed_versions
                _pythonz_compreply $options $installed_versions
                ;;
            *)
                ;;
        esac

    elif [ $COMP_CWORD -eq 3 ]; then #command-options


        case "${COMP_WORDS[COMP_CWORD-1]}" in
          -t)
            _pythonz_compreply $types
            ;;

          *)
            ;;
        esac

    elif [ $COMP_CWORD -eq 4 ];then #handle commands after commands-options

      type=${COMP_WORDS[COMP_CWORD-1]}
      command=${COMP_WORDS[COMP_CWORD-3]}
      
      case "$command" in
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
    fi
    return 0
}

_pythonz_available_versions()
{
    _pythonz_installed_regex
    _pythonz_known_versions

    if [ -n "$installed_regex" ];then
        available_versions=$( echo $known_versions | sed -e "s/$installed_regex/ /g" )
    else 
        available_versions=$known_versions
    fi 

}

_pythonz_installed_versions()
{
    if [ -n "$1" ];then
      type=$1
    fi

    installed_versions=$( pythonz list |egrep -i $type | sed -e "s/^.*$type-//gI" )
}

_pythonz_installed_regex()
{
    _pythonz_installed_versions

    installed_regex=""
    if [ -n "$installed_versions" ];then
        unique_versions=$( echo $installed_versions | sed -e 's/ /\n/g'| sed -e 's/\(.*\)/ \1 /g' )
        installed_regex=$( echo $unique_versions |sed -e "s/ /|/g" -e "s/|$//" -e "s/|/ \\\| /g" -e "s/^/ /" -e "s/$/ /") 
    fi
}

_pythonz_known_versions()
{
    if [ -n "$1" ];then
      type=$1
    fi

    known_versions=$( pythonz list -a |sed -n -e "/$type/,/#.*:/p" |sed  -e "/#.*:/d" |awk '{print $1}' )
}

_pythonz_compreply()
{
    COMPREPLY=( $( compgen -W "$*" -- ${COMP_WORDS[COMP_CWORD]}) )
}

complete -F _pythonz_complete pythonz
