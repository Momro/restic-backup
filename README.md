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
# mkdir backup
# mkdir backup/mount
# mkdir -P /mnt/backup-share/backup // debian
# mkdir -p /mnt/backup-share/backup // ubuntu
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
echo "Enter Restic repo password "
read -p "" RESTICPASSWORD
echo
sed -i "s|enter your password here|${RESTICPASSWORD}|g" backup.sh
```

## set your home folder

```
echo "/home/<home folder>" >> include.txt
```

Finally, set up a cron tab that mounts your backup share:

```
# sudo apt install cron
# crontab -e
@reboot sleep 60 && mount -t cifs //qnap/backup/pi /mnt/backup-share -o username=backup,password="******"
0 3 * * * /root/backup/backup.sh do-backup && /root/backup/backup.sh do-forget
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
cd backup
./backup.sh do-backup
```

# restore

```
sudo su
cd /root/backup
screen -S mount
./backup.sh do-mount
<ctrl+a d>
cd mount/snapshots/latest
<do your thing>
screen -r mount
<ctrl+c>
exit
```
