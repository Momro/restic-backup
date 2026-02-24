#!/bin/bash
INCLUDE_FILE='/root/restic/include.txt'
EXCLUDE_FILE='/root/restic/exclude.txt'
MOUNT_POINT='/mnt/restic-restore'

export RESTIC_REPOSITORY='/mnt/restic-backup-target'
export RESTIC_PASSWORD='enter your password here'

KUMA_PUSH_URL="http://<kuma ip>:<port>/api/push/<token>?status=up&msg=backup&ping=1234"
KUMA_ENABLED=1 # 1 == False, 0 == True

START=$(date '+%s')

function isMounted {
        if [[ $(mount | grep $RESTIC_REPOSITORY | wc -l) > 0 ]] ; then
                return 0
        else
                return 1
        fi
}

case "$1" in
        "do-backup")
                if isMounted ; then
                        /usr/bin/restic \
                        --verbose \
                        backup \
                        --exclude-file=$EXCLUDE_FILE \
                        --files-from=$INCLUDE_FILE

                        END=$(date '+%s')
                        DURATION=$((END - START))

                        if [[ $KUMA_ENABLED == 0 ]] ; then
                                curl -s -o /dev/null "$KUMA_PUSH_URL"
                        else
                                echo "Backup finished in ${DURATION} seconds."
                        fi
                else
                        echo "there is no mount at ${RESTIC_REPOSITORY}"
                        exit 1
                fi
        ;;
        "do-forget")
                if isMounted ; then
                        /usr/bin/restic \
                        forget \
                        --prune \
                        --keep-daily 30 \
                        --keep-weekly 10 \
                        --keep-monthly 12 \
                        --keep-yearly 75
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
