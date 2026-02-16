#!/bin/bash
INCLUDE_FILE='/root/restic/include.txt'
EXCLUDE_FILE='/root/restic/exclude.txt'
MOUNT_POINT='/mnt/restic-restore'

export RESTIC_REPOSITORY='/mnt/restic-backup-target'
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
