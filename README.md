# restic-backup

First, we need restic as backup program
$ sudo apt install restic

$ sudo su
# cd 
# mkdir backup
# mkdir -P /mnt/backup-share/backup
# touch backup.sh
# touch exclude.txt
# touch include.txt

# crontab -e
@reboot sleep 60 && mount -t cifs //qnap/backup/pi /mnt/backup-share -o username=backup,password="******"
0 3 * * * /root/backup/backup.sh do-backup && /root/backup/backup.sh do-forget
