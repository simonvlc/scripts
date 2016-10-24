#!/bin/bash

# bash_script_template.sh
#
# Just one base script template
#
# Usage: Put your usage here.
#
# Author: Name, Date

# VARS
ARGUMENTS_NUMBER=1
PROGNAME=$(basename $0)
REQUIRED_COMMAND_LINE_TOOLS=(eybackup pg_restore)

# FUNCTIONS
function usage {
	echo "Usage: $PROGNAME database_name" 1>&2
}

function clean_up {
  # do this on clean up
	exit $1
}

function error_exit {
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

function check_number_of_arguments {
  if [ $# -eq $ARGUMENTS_NUMBER ]
  then
    usage
    error_exit "Bad number of arguments."
  fi
}

function check_command_line_tools_installed {
  for COMMAND in "${REQUIRED_COMMAND_LINE_TOOLS[@]}"
	do
    command -v $COMMAND >/dev/null 2>&1 ||
      error_exit "$COMMAND not installed."
  done
}

# TRAP
trap clean_up SIGHUP SIGINT SIGTERM

# EXECUTION
check_number_of_arguments $@
check_command_line_tools_installed
clean_up
