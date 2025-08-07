echo "This will install restic with momro default. Continue?"
read
if [[ $(whoami) == "root" ]] ; then 
  echo "Install restic"
  read
  apt update && apt upgrade -y && apt install restic
  clear

  echo "Create folder structure"
  mkdir /root/backup
  mkdir -P /mnt/backup-share/backup
  
  echo "Clone repo and move files"
  read
  git clone https://github.com/Momro/restic-backup /tmp/restic
  mv /tmp/restic/backup.sh /root/backup/.
  mv /tmp/restic/exclude.txt /root/backup/.
  mv /tmp/restic/include.txt /root/backup/.

  echo "Enter Restic password"
  read -p RESTICPASSWORD
  echo
  sed -i "s|enter your password here|${RESTICPASSWORD}|g" backup.sh

  echo "Now you need to create the crontab. i cannot help you with that"
  echo "exit 0"
else
  echo "you are not running as root. exit"
fi
