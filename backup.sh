#!/bin/bash
INCLUDE_FILE='/root/backup/include.txt'
EXCLUDE_FILE='/root/backup/exclude.txt'
MOUNT_POINT='/root/backup/mount'

export RESTIC_REPOSITORY='/mnt/backup-share/backup'
export RESTIC_PASSWORD='enter your password here'

case "$1" in
        "do-backup")
                /usr/bin/restic \
                --verbose \
                backup \
                --exclude-file=$EXCLUDE_FILE \
                --files-from=$INCLUDE_FILE
        ;;
        "do-forget")
                /usr/bin/restic \
                forget \
                --prune \
                --keep-daily 30 \
                --keep-weekly 10 \
                --keep-monthly 12 \
                --keep-yearly 75
        ;;
        "do-mount")
                /usr/bin/restic \
                mount \
                $MOUNT_POINT
        ;;
        *)
                /usr/bin/restic "$@"
        ;;
esac
