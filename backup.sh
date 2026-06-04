#!/bin/bash

set -euo pipefail

CONFIG_FILE="/root/restic/config"
[ -f "$CONFIG_FILE" ] || { echo "Config fehlt: $CONFIG_FILE" >&2; exit 1; }

# shellcheck source=/root/restic/config
source "$CONFIG_FILE"

#####################################
# DO NOT CHANGE ANYTHING BELOW THIS #
#####################################

START=$(date '+%s')

function isMounted {
        # if remote is SFTP
        if [[ $(echo $RESTIC_REPOSITORY | cut -d ":" -f 1) == "sftp" ]] ; then
                # set default to "not mounted"
                isMountedRemotely=1
                # see if drive is mounted on remote host
                isMountedRemotely=$(ssh ${SFTP_TARGETNAME} "mountpoint -q ${SFTP_REPOSITORY_MOUNTPOINT} && echo '0'")
                # return 1 (not mounted) or 0 (mounted)
                return $isMountedRemotely
        elif [[ $(mount | grep $RESTIC_REPOSITORY | wc -l) > 0 ]] ; then
                return 0
        else
                return 1
        fi
}

function performBackup {
        echo "[#] #####################################"
        echo "[+] Backup to ${RESTIC_REPOSITORY}"
        echo "[+] Includes:"
        cat "$INCLUDE_FILE"
        echo "[#] #####################################"
        /usr/bin/restic backup \
                --verbose \
                --password-file="${RESTIC_PASSWORD_FILE}" \
                --exclude-file="${EXCLUDE_FILE}" \
                --files-from="${INCLUDE_FILE}"
}

function performPurge {
        echo "[#] #####################################"
        echo "[+] Purging now"
        /usr/bin/restic forget \
                --prune \
                --password-file="${RESTIC_PASSWORD_FILE}" \
                --keep-daily $KP_DAILY \
                --keep-weekly $KP_WEEKLY \
                --keep-monthly $KP_MONTHLY \
                --keep-yearly $KP_YEARLY
        echo "[#] #####################################"
        echo "[+] Purge is done"
}

case "$1" in
        "do-backup")
                if isMounted ; then
                        performBackup

                        END=$(date '+%s')
                        DURATION=$((END - START))

                        if [[ $KUMA_ENABLED == 1 ]] ; then
                                curl -s -o /dev/null "$(cat ${KUMA_PUSH_URL_FILE} | sed "s/OK/${DURATION}/g" )"
                                echo "kuma sent"
                        fi
                        echo "[#] #####################################"
                        echo "Backup finished in ${DURATION} seconds."
                else
                        echo "[#] #####################################"
                        echo "there is no mount at ${RESTIC_REPOSITORY}"
                        exit 1
                fi
        ;;
        "do-forget")
                if isMounted ; then
                        performPurge
                else
                        echo "[#] #####################################"
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
