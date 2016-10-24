#!/bin/bash

# import_db_from_ey.sh
#
# Script to download and import a pgsql db from EY.
#
# Simón Muñoz, Oct 24, 2016

# VARS
DB=$1
PROGNAME=$(basename $0)

# FUNCTIONS
function usage {
	echo "Usage: $PROGNAME database_name" 1>&2
}

function clean_up {
  [ -f /mnt/tmp/*.dump ] && sudo rm /mnt/tmp/*.dump
  exit $1
}

function error_exit {
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

function check_arguments {
  if [ $# -lt 1 ]
  then
    usage
    error_exit "Bad arguments. Your must provide the database name to import."
  fi
}

function download_database {
  sudo -i eybackup -e postgresql -d 9:$DB ||
    error_exit "Cannot download the DB"
}

function get_database_name {
  DB_DUMP_FILENAME=`ls /mnt/tmp/*.dump | xargs basename` ||
    error_exit "Cannot get db name"
}

function set_site_offline {
  echo '<h1>Updating Database</h1>' > /data/$DB/shared/system/maintenance.html ||
    error_exit "Cannot set the site offline"
}

function import_database {
  pg_restore -d $DB -c -U postgres /mnt/tmp/$DUMP_FILENAME ||
    error_exit "Cannot import the database"
}

function set_site_online {
  rm /data/$DB/shared/system/maintenance.html ||
    error_exit "Cannot set the site back online"
}

# TRAP
trap clean_up SIGHUP SIGINT SIGTERM

# EXECUTION
check_arguments $@
download_database
get_database_name
set_site_offline
import_database
set_site_online
clean_up
