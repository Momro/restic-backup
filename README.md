# restic installation

## Install required packets

```
# everything will run as sudo, so we can su anyway
sudo su
# First, we need restic as backup program
apt update && sudo apt upgrade -y && sudo apt install -y restic cifs-utils cron screen
```

## clone, files, folders
```
# clone repo
git clone https://github.com/Momro/restic-backup /root/restic

# cp sample files to actual config location
cp config.sample config && cp exclude.txt.sample exclude.txt && cp include.txt.sample include.txt && cp kuma_push_url.sample kuma_push_url && cp .restic-pass.sample .restic-pass

# mkdir mount point for a) backup, b) restore
mkdir /mnt/restic-restore
mkdir /mnt/restic-backup-target
```

## config starts here

```
# generate random password
generate-password 20 > .restic-pass


# add credentials file for SMB connection
CREDENTIAL_FILE_LOCATION="/root/smbcreds/backup"
touch "${CREDENTIAL_FILE_LOCATION}"

# insert your backup user's account name
echo "username=<USERNAME> >> "${CREDENTIAL_FILE_LOCATION}"
echo "password=<password> >> "${CREDENTIAL_FILE_LOCATION}"


# add kuma url
KUMA_PUSH_URL=""
echo "${KUMA_PUSH_URL}" > kuma_push_url
```

now edit the `config` file. this cannot be automated. mainly, remove SMB or SFTP depending on what you are going to do

Then edit the `include.txt` -> I mostly use `/home/user/docker/`

The `exclude` file is ok in the default for me.

## cronjob

Time to set up the cronjob -> `crontab -e`

```
# mount backup repository
# Example:
# @reboot sleep 60 && mount -t cifs //<IP>/<FOLDER> /mnt/restic-backup-target -o credentials=/root/smbcred/backup,uid=1000,gid=1000,file_mode=0775,dir_mode=0775,noperm,forceuid,forcegid,vers=3.0
@reboot sleep 60 && mount -t cifs //<TARGET IP>/<TARGET FOLDER> /mnt/<MOUNT POINT> -o credentials=<CREDENTIAL FILE>,uid=1000,gid=1000,file_mode=0775,dir_mode=0775,noperm,forceuid,forcegid,vers=3.0

# perform backup at 3am
0 3 * * * /root/restic/backup.sh do-backup && /root/restic/backup.sh do-forget
```

## mount
mount the backup destination
```
mount ... whatever your cronjob says
```

Everything is set up now:
* backup.sh is downloaded
* Folders for backup and restore were created
* Password for repo is set
* kuma is set
* smb credentials are stored
* `config` file points to correct protocol -> `smb` or `sftp`
* included and excluded files were set
* You have mounted the backup repository

Time to do the first backup!

## initialize

```
# init
./backup.sh init
# backup
./backup.sh do-backup
```


# restore
if you need to restore file,s this is the way to go:
```
# go root
sudo su
# go to restic folder
cd /root/restic
# start screen session in which we mount the backup
screen -S mount
# mount the backup
./backup.sh do-mount
# leave screen session
<ctrl+a d>
# go to latest backup
cd /mnt/restic-restore/snapshots/latest

#################
# <do your thing>
#################

# once you're done, go back to the mount-screen
screen -r mount
# quit the mounting
<ctrl+c>
# quit the screen session
exit
```

Enjoy!
