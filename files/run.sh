#!/bin/bash

# MONGODUMP
if [[ -z "${MONGO_URI}" ]]; then
	echo "MONGO_URI not set, sleeping to leave the container running"
	sleep 900000000
else
  cd /data
  CMD="mongodump --uri=\"$MONGO_URI\" $MONGO_DUMP_OPTIONS"
  DSTR=$(date -u +%Y-%m-%d_%H-%M-%S)_UTC
  BACKUP_NAME="$DSTR"

  if [[ -n "${MONGODUMP_GZIP}" ]]; then
    CMD="$CMD --gzip"
  fi

  # can only enable --oplog of backing up all databases
  if [[ -z "${MONGODUMP_DB}" ]]; then  
    if [[ -n "${MONGODUMP_OPLOG}" ]]; then
      CMD="$CMD --oplog"
    fi
  fi

  if [[ -n "${MONGO_READPREFERENCE}" ]]; then
    CMD="$CMD --readPreference=$MONGO_READPREFERENCE"
  fi

  if [[ -n "${MONGODUMP_DB}" ]]; then
    BACKUP_NAME="$BACKUP_NAME-$MONGODUMP_DB"
    CMD="$CMD --db=$MONGODUMP_DB"
  fi

  if [[ -n "${MONGODUMP_COLLECTION}" ]]; then
    CMD="$CMD --collection=$MONGODUMP_COLLECTION"
    BACKUP_NAME="$BACKUP_NAME-$MONGODUMP_COLLECTION"
  fi

  if [[ -n "${MONGODUMP_ARCHIVE}" ]]; then
    if [[ -n "${MONGODUMP_ARCHIVE_FILENAME}" ]]; then
      BACKUP_NAME=$MONGODUMP_ARCHIVE_FILENAME
    else 
      DSTR=$(date -u +%Y-%m-%d_%H-%M-%S)_UTC
      BACKUP_NAME="$BACKUP_NAME.archive"
    fi
    CMD="$CMD --archive=$BACKUP_NAME"
  else
    BACKUP_NAME="$BACKUP_NAME.tar"
  fi

  #echo "Running: $CMD"
  echo "Running mongodump"
  echo "Backup name: $BACKUP_NAME"
  date
  $CMD
  date
  
  # not archive, need to tar up files
  if [[ -z "${MONGODUMP_ARCHIVE}" ]]; then
    echo "tar -cvzf \"${BACKUP_NAME}\" dump"
    tar -cvzf "${BACKUP_NAME}" dump
  fi
  date
  # copy to S3 bucket
  if [[ -n "${AWS_S3_BUCKET}" ]]; then 
    S3_PATH="s3://${AWS_S3_BUCKET}${AWS_S3_PATH}/${BACKUP_NAME}"
    echo "S3 object: $S3_PATH"
    CMD="aws s3 cp \"${BACKUP_NAME}\" \"${S3_PATH}\""
    echo "Running: $CMD"
    aws s3 cp "${BACKUP_NAME}" "${S3_PATH}"
  fi
fi

echo "finished"
date
