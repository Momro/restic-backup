# restic-backup

First, we need restic as backup program
```
$ sudo apt update && sudo apt upgrade -y && sudo apt install restic
```

Then create folders:

```
$ sudo su
# cd 
# mkdir backup
# mkdir -P /mnt/backup-share/backup
```

Either clone my config files or create new ones

## clone

```
git clone https://github.com/Momro/restic-backup /tmp/restic
mv /tmp/restic/backup.sh /root/backup/.
mv /tmp/restic/exclude.txt /root/backup/.
mv /tmp/restic/include.txt /root/backup/.
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
echo "Enter Restic password"
read -p RESTICPASSWORD
echo
sed -i "s|enter your password here|${RESTICPASSWORD}|g" backup.sh
```

Finally, set up a cron tab that mounts your backup share:

```
# crontab -e
@reboot sleep 60 && mount -t cifs //qnap/backup/pi /mnt/backup-share -o username=backup,password="******"
0 3 * * * /root/backup/backup.sh do-backup && /root/backup/backup.sh do-forget
```
