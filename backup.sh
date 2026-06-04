#!/bin/bash
INCLUDE_FILE='/root/restic/include.txt'
EXCLUDE_FILE='/root/restic/exclude.txt'
MOUNT_POINT='/mnt/restic-restore'

#####################################
# TARGET DEFINITION
# can either be SFTP or SMB

## SFTP details
SFTP_USER="mySftpUser"
SFTP_TARGETNAME="resticBackupTarget"
SFTP_REPOSITORY_MOUNTPOINT="/media/backup-usb-drive" # the remote mount point where the backup shall be stored
RESTIC_REPOSITORY="sftp:${SFTP_USER}@${SFTP_TARGETNAME}:${SFTP_REPOSITORY_MOUNTPOINT}"

## SMB mount point
RESTIC_REPOSITORY='/mnt/restic-backup-target'

export RESTIC_REPOSITORY
#####################################

#####################################
# KEEPERS
# How long do you want each backup to remain?
KP_DAILY=7
KP_WEEKLY=5
KP_MONTHLY=12
KP_YEARLY=3
#####################################

#####################################
# KUMA REPORTING
# set to 1 to enable
KUMA_ENABLED=0
## if the URL contains an "OK", the script will insert there the time it took to take the backup
KUMA_PUSH_URL_FILE="/root/restic/kuma_push_url"
#####################################

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
        echo "[#] #####################################"
        /usr/bin/restic \
        --verbose \
        --password-file=/root/restic/.restic-pass \
        --exclude-file=$EXCLUDE_FILE \
        --files-from=$INCLUDE_FILE \
        backup
}

function performPurge {
        echo "[#] #####################################"
        echo "[+] Purging now"
        /usr/bin/restic \
        --prune \
        --keep-daily $KP_DAILY \
        --keep-weekly $KP_WEEKLY \
        --keep-monthly $KP_MONTHLY \
        --keep-yearly $KP_YEARLY
        forget
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
