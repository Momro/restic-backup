#!/bin/bash
INCLUDE_FILE='/root/restic/include.txt'
EXCLUDE_FILE='/root/restic/exclude.txt'
MOUNT_POINT='/mnt/restic-restore'

export RESTIC_REPOSITORY='/mnt/restic-backup-target'

KUMA_ENABLED=0

START=$(date '+%s')

function isMounted {
        if [[ $(mount | grep $RESTIC_REPOSITORY | wc -l) > 0 ]] ; then
                return 0
        else
                return 1
        fi
}

function performBackup {
        /usr/bin/restic \
        --verbose \
        --password-file=/root/restic/.restic-pass \
        backup \
        --exclude-file=$EXCLUDE_FILE \
        --files-from=$INCLUDE_FILE
}

function performPurge {
        /usr/bin/restic \
        forget \
        --prune \
        --keep-daily 30 \
        --keep-weekly 10 \
        --keep-monthly 12 \
        --keep-yearly 75
}

case "$1" in
        "do-backup")
                if isMounted ; then
                        performBackup

                        END=$(date '+%s')
                        DURATION=$((END - START))

                        if [[ $KUMA_ENABLED == 0 ]] ; then
                                curl -s -o /dev/null "$(cat ./kuma_push_url)"
                        fi
                        echo "Backup finished in ${DURATION} seconds."
                else
                        echo "there is no mount at ${RESTIC_REPOSITORY}"
                        exit 1
                fi
        ;;
        "do-forget")
                if isMounted ; then
                        performPurge
                else
                        echo "there is no mount at ${RESTIC_REPOSITORY}"
                        exit 1
                fi
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
