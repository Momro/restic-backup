# restic-backup

## tl;dr

```
sudo su
curl -s https://raw.githubusercontent.com/Momro/restic-backup/refs/heads/main/install.sh | bash
```

You will have to install the cron tab manually, though.

## The long way

First, we need restic as backup program
```
$ sudo apt update && sudo apt upgrade -y && sudo apt install restic
```

Then create folders:

```
$ sudo su
# cd 
# mkdir restic
# mkdir -P /mnt/restic-restore // debian
# mkdir -p /mnt/restic-restore // ubuntu
```

Either clone my config files or create new ones

## clone

```
git clone https://github.com/Momro/restic-backup /tmp/restic
mv /tmp/restic/backup.sh /root/restic/.
mv /tmp/restic/exclude.txt /root/restic/.
mv /tmp/restic/include.txt /root/restic/.
```

## create

```
# cd backup
# touch backup.sh
# touch exclude.txt
# touch include.txt
```

## replace password

Replace your restic password in the config

```
echo "Enter Restic repo password "
read -p "" RESTICPASSWORD
echo
sed -i "s|enter your password here|${RESTICPASSWORD}|g" backup.sh
```

## Adjust include/exclude

**Note**: If you exclude `/mnt` and include `/mnt/some-folder`, it will be **excluded**.

## set your home folder

```
echo "/home/<home folder>" >> include.txt
```

Finally, set up a cron tab that mounts your backup share. Must be run as `root`!

```
# sudo apt install cron
# sudo su
# crontab -e
@reboot sleep 60 && mount -t cifs //qnap/backup/<device name> /mnt/restic-backup-target -o credentials=/root/smbcred/<device name>,uid=1000,gid=1000,file_mode=0775,dir_mode=0775,noperm,forceuid,forcegid,vers=3.0
0 3 * * * /root/restic/backup.sh do-backup && /root/restic/backup.sh do-forget
```

# initialize

```
restic -r <backup location> init
enter secure password twice
```

# backup

```
sudo su
cd
cd restic
./backup.sh do-backup
```

# restore

```
sudo su
cd /root/restic
screen -S mount
./backup.sh do-mount
<ctrl+a d>
cd mount/snapshots/latest
<do your thing>
screen -r mount
<ctrl+c>
exit
```
