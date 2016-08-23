#!/bin/bash -eu

log() {
  local LEVEL=$1
  shift
  local MESSAGE=$*
  local DATE=$(date +%Y-%m-%d\ %H:%M:%S)
  echo "${DATE} ${LEVEL} ${MESSAGE}"
}

log_error() {
  log_info Checking environment...
  if [ $LOG -le 3 ]; then
    log ERROR $*
  fi
}

log_info() {
  if [ $LOG -le 2 ]; then
    log INFO $*
  fi
}

log_debug() {
  if [ $LOG -le 1 ]; then
    log DEBUG $*
  fi
}

check_env() {
  set +eu
  local error=false

  if [ -z "${LOG_LEVEL}" -o "${LOG_LEVEL}" == "ERROR" ]; then
    LOG=3
  elif [ "${LOG_LEVEL}" == "INFO" ]; then
    LOG=2
  elif [ "${LOG_LEVEL}" == "DEBUG" ]; then
    LOG=1
  else 
    log_error "Unknown log level ${LOG_LEVEL}"
    error=true
  fi

  if [ -z "${HOST}" ]; then
    HOST="db"
  fi

  USER="${USER:-root}"

  if [ -z "${PASSWORD}" ]; then
    log_error "PASSWORD is mandatory"
    error=true
  fi

  if [ -z "${DATABASE}" ]; then
    log_error "DATABASE is mandatory"
    error=true
  fi

  NAME="${NAME:-$DATABASE}"

  BACKUP_DIR="/backups"

  if ${error}; then
    exit 1
  fi
  
  set -eu
  log_info Environment checked
}

backup_sql() {
  local DATE=$(date +%Y%m%d-%H%M%S)
  local DUMP_NAME="${NAME}_${DATE}.sql.bz2"
  local FILE_NAME="/backups/${FULLNAME:-$DUMP_NAME}"

  log_info Backuping mysql into ${FILE_NAME} ...

  mysqldump -q -h ${HOST} --single-transaction --user=${USER} --password=${PASSWORD} ${DATABASE} | pbzip2 > ${FILE_NAME}

  log_info Backup done
}

PARAMS=$*

check_env
backup_sql
