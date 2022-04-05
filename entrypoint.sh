#!/bin/bash

# set timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/$LOCALTIME /etc/localtime

# make sure we are running the latest version of jotta-cli
apt-get update
apt-get install jotta-cli
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/lists/*

# set the jottad user and group id
usermod -u $PUID jottad
usermod --gid $PGID jottad
usermod -a -G $JOTTAD_USER $JOTTAD_GROUP

# start the service
/etc/init.d/jottad start

# wait for service to fully start
sleep 5

if [[ "$(jotta-cli status)" =~ ERROR.* ]]; then

  echo "First time login"

  # Login user
  /usr/bin/expect -c "
  set timeout 20
  spawn jotta-cli login
  expect \"accept license (yes/no): \" {send \"yes\n\"}
  expect \"Personal login token: \" {send \"$JOTTA_TOKEN\n\"}
  expect \"Devicename*: \" {send \"$JOTTA_DEVICE\n\"}
  expect \"*device*: \" {send \"$JOTTA_DEVICE_FOUND\n\"}
  expect eof
  "

# add backup volume
  jotta-cli add /backup
  jotta-cli add /backup

else

  echo "User is logged in"

fi

  # load ignore file
  if [ -f /config/ignorefile ]; then
    echo "loading ignore file"
    jotta-cli ignores set /config/ignorefile
  fi

  # set scan interval
  echo "Setting scan interval"
  jotta-cli config set scaninterval $JOTTA_SCANINTERVAL

  # set download channels
  echo "Setting download channels"
  jotta-cli config set maxdownloads $JOTTA_MAXDOWNLOADS

  # set upload slots
  echo "Setting upload channels"
  jotta-cli config set maxuploads $JOTTA_MAXUPLOADS

  # set download rate
  echo "Setting download rate"
  jotta-cli config set downloadrate $JOTTA_DOWNLOADRATE

  # set upload rate
  echo "Setting upload rate"
  jotta-cli config set uploadrate $JOTTA_UPLOADRATE

  R=0
  while [[ $R -eq 0 ]]
  do
    sleep 15
    jotta-cli status >/dev/null 2>&1
          R=$?
  done

  echo "Exiting:"
  jotta-cli status
  exit 1